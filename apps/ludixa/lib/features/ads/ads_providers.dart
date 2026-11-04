import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';

import '../../app/environment.dart';

/// Consentimiento con UMP. En desarrollo se puede simular el EEE:
/// `--dart-define=UMP_DEBUG_EEA=true --dart-define=UMP_TEST_DEVICE=<hash>`
/// (el hash lo escribe UMP en logcat la primera vez).
final consentServiceProvider = Provider<ConsentService>((ref) {
  const debugEea = bool.fromEnvironment('UMP_DEBUG_EEA');
  const testDevice = String.fromEnvironment('UMP_TEST_DEVICE');
  final development = !ref.watch(environmentProvider).isProduction;
  return UmpConsentService(
    debugEea: development && debugEea,
    testDeviceIds: [if (development && testDevice.isNotEmpty) testDevice],
  );
});

final adsSdkProvider = Provider<AdsSdk>((ref) => const MobileAdsSdk());

/// Consentimiento y SDK, en cada arranque y en segundo plano: la app se
/// muestra sin esperarlo. true cuando ya se pueden pedir anuncios.
final adsReadyProvider = FutureProvider<bool>(
  (ref) => AdsStartup(consent: ref.watch(consentServiceProvider), sdk: ref.watch(adsSdkProvider)).run(),
);

/// Si corresponde mostrar "Opciones de privacidad" (se sabe después de
/// pedir el consentimiento).
final privacyOptionsRequiredProvider = FutureProvider<bool>((ref) async {
  await ref.watch(adsReadyProvider.future);
  return ref.watch(consentServiceProvider).privacyOptionsRequired();
});
