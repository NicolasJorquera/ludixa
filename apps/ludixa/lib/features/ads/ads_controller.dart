import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/environment.dart';
import 'ads_providers.dart';

/// Bloques de anuncios de producción. Solo existen en la compilación prod:
/// `--dart-define-from-file=admob_prod.json` (ignorado por git).
const _productionUnits = AdUnits(
  banner: String.fromEnvironment('ADMOB_BANNER'),
  interstitial: String.fromEnvironment('ADMOB_INTERSTITIAL'),
  rewarded: String.fromEnvironment('ADMOB_REWARDED'),
);

/// Bloques de cada entorno. Dev usa siempre los de prueba de Google, aunque
/// reciba otros; prod sin sus identificadores queda sin anuncios (nunca con
/// los de prueba).
AdUnits? adUnitsFor(AppEnvironment environment, {AdUnits production = _productionUnits}) {
  if (!environment.isProduction) return AdUnits.test;
  return production.complete ? production : null;
}

/// Dónde se guardan los contadores de la política (preferencias del
/// dispositivo; no se exportan con el progreso).
abstract interface class AdPolicyStore {
  AdPolicyState load();
  Future<void> save(AdPolicyState state);
}

final class InMemoryAdPolicyStore implements AdPolicyStore {
  AdPolicyState _state = const AdPolicyState();

  @override
  AdPolicyState load() => _state;

  @override
  Future<void> save(AdPolicyState state) async => _state = state;
}

final class PrefsAdPolicyStore implements AdPolicyStore {
  PrefsAdPolicyStore._(this._prefs);

  static const _key = 'ads.policy';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsAdPolicyStore> create() async => PrefsAdPolicyStore._(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key})),
  );

  @override
  AdPolicyState load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AdPolicyState();
    try {
      return AdPolicyState.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
    } on Object {
      return const AdPolicyState();
    }
  }

  @override
  Future<void> save(AdPolicyState state) => _prefs.setString(_key, jsonEncode(state.toJson()));
}

final adPolicyStoreProvider = Provider<AdPolicyStore>((ref) => InMemoryAdPolicyStore());

/// Hora local del dispositivo para la política. Las pruebas la reemplazan.
final adClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Límites de la política. Solo en dev, `--dart-define=ADS_QA=true` los
/// relaja para probar el intersticial a mano (sigue sin haber en la primera
/// sesión). Producción usa siempre los del PRD.
final adLimitsProvider = Provider<AdLimits>((ref) {
  const qa = bool.fromEnvironment('ADS_QA');
  if (!qa || ref.watch(environmentProvider).isProduction) return const AdLimits();
  return const AdLimits(minPuzzlesTotal: 1, puzzlesBetween: 1, minActivePlay: Duration.zero, shortGame: Duration.zero);
});

/// La política, una por proceso: crearla es abrir la app (una sesión más).
final adPolicyProvider = Provider<AdPolicy>((ref) {
  final store = ref.watch(adPolicyStoreProvider);
  final policy = AdPolicy(now: ref.watch(adClockProvider), state: store.load(), limits: ref.watch(adLimitsProvider))
    ..appOpened();
  unawaited(store.save(policy.state));
  return policy;
});

/// AdMob cuando el consentimiento y el SDK están listos y hay bloques para el
/// entorno; si no, sin anuncios.
final adServiceProvider = Provider<AdService>((ref) {
  final ready = ref.watch(adsReadyProvider).value ?? false;
  final units = adUnitsFor(ref.watch(environmentProvider));
  if (!ready || units == null) return const NoAdsService();
  return ref.watch(adMobFactoryProvider)(units)..preload();
});

/// Cómo se crea el servicio de AdMob. Las pruebas ponen uno falso.
final adMobFactoryProvider = Provider<AdService Function(AdUnits units)>((ref) => AdMobAdService.new);

final adsControllerProvider = Provider<AdsController>(
  (ref) => AdsController(
    service: ref.watch(adServiceProvider),
    policy: ref.watch(adPolicyProvider),
    store: ref.watch(adPolicyStoreProvider),
  ),
);

/// Une la política y el servicio. Los anuncios solo aparecen en pausas
/// naturales: el intersticial al salir del Resultado y el video cuando la
/// persona lo pide. Nunca durante una partida ni al abrir la app.
final class AdsController {
  AdsController({required this.service, required this.policy, required this.store});

  final AdService service;
  final AdPolicy policy;
  final AdPolicyStore store;

  void puzzleStarted() => _update(policy.puzzleStarted);

  void played(Duration time) {
    if (time > Duration.zero) _update(() => policy.addActivePlay(time));
  }

  void puzzleCompleted(Duration elapsed) => _update(() => policy.puzzleCompleted(elapsed));

  /// Al salir del Resultado: muestra el intersticial si la política lo
  /// permite y ya está cargado (no espera a que cargue). true si se mostró.
  Future<bool> atResultExit() async {
    final decision = policy.decide(AdExit.result);
    if (kDebugMode) debugPrint('Intersticial al salir del Resultado: ${decision.name}');
    if (decision != AdDecision.show) return false;
    if (!await service.showInterstitial()) return false;
    _update(policy.interstitialShown);
    return true;
  }

  /// Video con recompensa a pedido. Si se llegó a mostrar (completo o no),
  /// al salir de este puzzle no habrá intersticial.
  Future<RewardedOutcome> showRewarded() async {
    final outcome = await service.showRewarded();
    if (outcome != RewardedOutcome.unavailable) _update(policy.rewardedShown);
    return outcome;
  }

  void _update(void Function() change) {
    change();
    unawaited(store.save(policy.state));
  }
}
