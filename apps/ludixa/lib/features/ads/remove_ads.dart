import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Si se compró «Sin anuncios», en las preferencias del dispositivo (no se
/// exporta con el progreso). Play lo reverifica al abrir la app.
final class PrefsRemoveAdsStore implements RemoveAdsStore {
  PrefsRemoveAdsStore._(this._prefs);

  static const _key = 'ads.removed';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsRemoveAdsStore> create() async => PrefsRemoveAdsStore._(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key})),
  );

  @override
  bool load() => _prefs.getBool(_key) ?? false;

  @override
  Future<void> save(bool owned) => _prefs.setBool(_key, owned);
}

final removeAdsStoreProvider = Provider<RemoveAdsStore>((ref) => InMemoryRemoveAdsStore());

/// Google Play Billing. Las pruebas ponen uno falso.
final inAppPurchaseProvider = Provider<InAppPurchase>((ref) => InAppPurchase.instance);

/// La compra, una por proceso. Al crearla escucha las compras y reverifica
/// con Play en segundo plano: la app no la espera.
final removeAdsProvider = Provider<RemoveAds>((ref) {
  final billing = RemoveAds(iap: ref.watch(inAppPurchaseProvider), store: ref.watch(removeAdsStoreProvider));
  ref.onDispose(billing.dispose);
  billing.start().ignore();
  return billing;
});

/// Estado de la compra para la interfaz.
final removeAdsStateProvider = NotifierProvider<RemoveAdsNotifier, RemoveAdsState>(RemoveAdsNotifier.new);

class RemoveAdsNotifier extends Notifier<RemoveAdsState> {
  @override
  RemoveAdsState build() {
    final billing = ref.watch(removeAdsProvider);
    void sync() => state = billing.state.value;
    billing.state.addListener(sync);
    ref.onDispose(() => billing.state.removeListener(sync));
    return billing.state.value;
  }
}

/// La persona compró «Sin anuncios»: ni banners ni intersticiales, y lo que
/// da un video (pistas extra, rescate) se entrega sin video.
final adsRemovedProvider = Provider<bool>((ref) => ref.watch(removeAdsStateProvider.select((s) => s.owned)));
