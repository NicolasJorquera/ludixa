/// Anuncios de Ludixa. [AdPolicy] decide cuándo se puede mostrar un
/// intersticial según los límites del PRD (Dart puro, no conoce AdMob).
/// [AdsStartup] pide el consentimiento con UMP y solo entonces inicia AdMob.
/// [RemoveAds] es la compra única «Sin anuncios» con Google Play Billing.
library;

export 'package:in_app_purchase/in_app_purchase.dart' show InAppPurchase;

export 'src/ad_policy.dart';
export 'src/ad_service.dart';
export 'src/consent.dart';
export 'src/remove_ads.dart';
