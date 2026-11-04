import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Consentimiento de anuncios. Se pide en cada arranque, como exige Google, y
/// la app no lo espera para mostrarse.
abstract interface class ConsentService {
  /// Actualiza el consentimiento y, si corresponde (EEE, Reino Unido, Suiza,
  /// estados de EE. UU.), muestra el formulario. No lanza: sin red se sigue
  /// con lo que ya había.
  Future<void> gather();

  /// Si ya se pueden pedir anuncios.
  Future<bool> canRequestAds();

  /// Si Ajustes debe mostrar "Opciones de privacidad".
  Future<bool> privacyOptionsRequired();

  /// Formulario para cambiar el consentimiento.
  Future<void> showPrivacyOptions();
}

/// Consentimiento con UMP (User Messaging Platform de Google).
final class UmpConsentService implements ConsentService {
  /// [debugEea] y [testDeviceIds] solo en desarrollo: simulan estar en el
  /// EEE en los dispositivos de prueba para ver el formulario.
  const UmpConsentService({this.debugEea = false, this.testDeviceIds = const []});

  final bool debugEea;
  final List<String> testDeviceIds;

  @override
  Future<void> gather() {
    final done = Completer<void>();
    void finish([Object? _]) {
      if (!done.isCompleted) done.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: debugEea
            ? ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: testDeviceIds)
            : null,
      ),
      () => unawaited(ConsentForm.loadAndShowConsentFormIfRequired(finish).catchError(finish)),
      finish,
    );
    return done.future;
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() {
    final done = Completer<void>();
    unawaited(
      ConsentForm.showPrivacyOptionsForm((_) {
        if (!done.isCompleted) done.complete();
      }),
    );
    return done.future;
  }
}

/// El SDK de anuncios. Las pruebas usan uno falso.
abstract interface class AdsSdk {
  Future<void> initialize();
}

final class MobileAdsSdk implements AdsSdk {
  const MobileAdsSdk({this.testDeviceIds = const []});

  /// Teléfonos de desarrollo que reciben anuncios de prueba.
  final List<String> testDeviceIds;

  /// Clasificación máxima del contenido publicitario: adolescentes (T), sin
  /// marca de público infantil, coherente con un público declarado de 18+.
  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(maxAdContentRating: MaxAdContentRating.t, testDeviceIds: testDeviceIds),
    );
  }
}

/// Arranque de los anuncios: primero el consentimiento y, solo si se pueden
/// pedir anuncios, el SDK. Sin consentimiento no se inicializa ni se pide
/// nada. No lanza: si algo falla, la app sigue sin anuncios.
final class AdsStartup {
  const AdsStartup({required this.consent, required this.sdk});

  final ConsentService consent;
  final AdsSdk sdk;

  /// true si los anuncios quedaron listos para pedirse.
  Future<bool> run() async {
    try {
      await consent.gather();
      if (!await consent.canRequestAds()) return false;
      await sdk.initialize();
      return true;
    } on Object {
      return false;
    }
  }
}
