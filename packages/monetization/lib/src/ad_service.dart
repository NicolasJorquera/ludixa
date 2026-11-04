import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Resultado de ofrecer un video con recompensa.
enum RewardedOutcome {
  /// Se vio completo: se entrega la recompensa.
  earned,

  /// Se cerró antes: no se entrega nada.
  dismissed,

  /// No había video (sin conexión, sin inventario o sin consentimiento).
  unavailable,
}

/// Bloques de anuncios de un entorno.
final class AdUnits {
  const AdUnits({required this.banner, required this.interstitial, required this.rewarded});

  /// Los de prueba de Google. El entorno dev usa siempre estos.
  static const test = AdUnits(
    banner: 'ca-app-pub-3940256099942544/9214589741',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    rewarded: 'ca-app-pub-3940256099942544/5224354917',
  );

  final String banner;
  final String interstitial;
  final String rewarded;

  bool get complete => banner.isNotEmpty && interstitial.isNotEmpty && rewarded.isNotEmpty;
}

/// Un banner ya cargado: su widget y cómo liberarlo.
final class LoadedBanner {
  const LoadedBanner({required this.widget, required this.dispose});

  final Widget widget;
  final VoidCallback dispose;
}

/// Anuncios de la app. Quién decide *cuándo* es [AdPolicy] y la app; esto
/// solo carga y muestra.
abstract interface class AdService {
  /// Precarga un intersticial y un video para que aparezcan sin espera.
  void preload();

  /// Muestra el intersticial si ya está cargado y espera a que se cierre.
  /// Si no hay uno listo no espera ni reintenta: devuelve false.
  Future<bool> showInterstitial();

  /// Muestra un video con recompensa y espera a que se cierre.
  Future<RewardedOutcome> showRewarded();

  /// Banner adaptable en línea de [width] dp, o null si no hay.
  Future<LoadedBanner?> loadBanner(double width);
}

/// Sin anuncios: sin consentimiento, sin identificadores de producción, o
/// la futura compra que los quita.
final class NoAdsService implements AdService {
  const NoAdsService();

  @override
  void preload() {}

  @override
  Future<bool> showInterstitial() async => false;

  @override
  Future<RewardedOutcome> showRewarded() async => RewardedOutcome.unavailable;

  @override
  Future<LoadedBanner?> loadBanner(double width) async => null;
}

/// Anuncios de AdMob. Solo se crea con el consentimiento resuelto y el SDK
/// iniciado (ver AdsStartup).
final class AdMobAdService implements AdService {
  AdMobAdService(this.units);

  /// Alto máximo del banner en línea (dp).
  static const maxBannerHeight = 100;

  final AdUnits units;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;

  @override
  void preload() {
    if (_interstitial == null && !_loadingInterstitial) {
      _loadingInterstitial = true;
      unawaited(
        InterstitialAd.load(
          adUnitId: units.interstitial,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _loadingInterstitial = false;
              _interstitial = ad;
            },
            onAdFailedToLoad: (_) => _loadingInterstitial = false,
          ),
        ),
      );
    }
    if (_rewarded == null && !_loadingRewarded) {
      _loadingRewarded = true;
      unawaited(
        RewardedAd.load(
          adUnitId: units.rewarded,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              _loadingRewarded = false;
              _rewarded = ad;
            },
            onAdFailedToLoad: (_) => _loadingRewarded = false,
          ),
        ),
      );
    }
  }

  @override
  Future<bool> showInterstitial() {
    final ad = _interstitial;
    _interstitial = null;
    if (ad == null) {
      preload();
      return Future.value(false);
    }
    final closed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => _finish(ad, closed, true),
      onAdFailedToShowFullScreenContent: (ad, _) => _finish(ad, closed, false),
    );
    unawaited(ad.show());
    return closed.future;
  }

  @override
  Future<RewardedOutcome> showRewarded() {
    final ad = _rewarded;
    _rewarded = null;
    if (ad == null) {
      preload();
      return Future.value(RewardedOutcome.unavailable);
    }
    var earned = false;
    final closed = Completer<RewardedOutcome>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      // La recompensa solo se entrega si el SDK confirma que se vio completo.
      onAdDismissedFullScreenContent: (ad) =>
          _finish(ad, closed, earned ? RewardedOutcome.earned : RewardedOutcome.dismissed),
      onAdFailedToShowFullScreenContent: (ad, _) => _finish(ad, closed, RewardedOutcome.unavailable),
    );
    unawaited(ad.show(onUserEarnedReward: (_, _) => earned = true));
    return closed.future;
  }

  void _finish<T>(Ad ad, Completer<T> closed, T value) {
    unawaited(ad.dispose());
    if (!closed.isCompleted) closed.complete(value);
    preload();
  }

  @override
  Future<LoadedBanner?> loadBanner(double width) {
    final loaded = Completer<LoadedBanner?>();
    late final BannerAd banner;
    banner = BannerAd(
      adUnitId: units.banner,
      // Alto máximo: sin tope, AdMob entrega banners de ~300 dp que tapan
      // media pantalla.
      size: AdSize.getInlineAdaptiveBannerAdSize(width.truncate(), maxBannerHeight),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) async {
          final size = await banner.getPlatformAdSize();
          if (loaded.isCompleted) return;
          loaded.complete(
            LoadedBanner(
              widget: SizedBox(
                width: (size?.width ?? width).toDouble(),
                height: (size?.height ?? 50).toDouble(),
                child: AdWidget(ad: banner),
              ),
              dispose: () => unawaited(banner.dispose()),
            ),
          );
        },
        onAdFailedToLoad: (ad, _) {
          unawaited(ad.dispose());
          if (!loaded.isCompleted) loaded.complete(null);
        },
      ),
    );
    unawaited(banner.load());
    return loaded.future;
  }
}
