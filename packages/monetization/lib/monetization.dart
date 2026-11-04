/// Anuncios de Ludixa. [AdPolicy] decide cuándo se puede mostrar un
/// intersticial según los límites del PRD (Dart puro, no conoce AdMob).
/// [AdsStartup] pide el consentimiento con UMP y solo entonces inicia AdMob.
library;

export 'src/ad_policy.dart';
export 'src/consent.dart';
