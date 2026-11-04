import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:monetization/monetization.dart';

final class _FakeConsent implements ConsentService {
  _FakeConsent({required this.allowed, this.gate, this.fails = false});

  final bool allowed;
  final Completer<void>? gate;
  final bool fails;
  var gathered = 0;

  @override
  Future<void> gather() async {
    gathered++;
    if (fails) throw StateError('sin red');
    await gate?.future;
  }

  @override
  Future<bool> canRequestAds() async => allowed;

  @override
  Future<bool> privacyOptionsRequired() async => allowed;

  @override
  Future<void> showPrivacyOptions() async {}
}

final class _FakeSdk implements AdsSdk {
  var initialized = 0;

  @override
  Future<void> initialize() async => initialized++;
}

void main() {
  test('con consentimiento se inicia el SDK, después de pedirlo', () async {
    final consent = _FakeConsent(allowed: true);
    final sdk = _FakeSdk();
    expect(await AdsStartup(consent: consent, sdk: sdk).run(), isTrue);
    expect((consent.gathered, sdk.initialized), (1, 1));
  });

  test('sin consentimiento no se inicia el SDK ni se piden anuncios', () async {
    final sdk = _FakeSdk();
    expect(await AdsStartup(consent: _FakeConsent(allowed: false), sdk: sdk).run(), isFalse);
    expect(sdk.initialized, 0);
  });

  test('mientras se resuelve el consentimiento, el SDK espera', () async {
    final gate = Completer<void>();
    final sdk = _FakeSdk();
    final running = AdsStartup(
      consent: _FakeConsent(allowed: true, gate: gate),
      sdk: sdk,
    ).run();
    await Future<void>.delayed(Duration.zero);
    expect(sdk.initialized, 0);
    gate.complete();
    expect(await running, isTrue);
    expect(sdk.initialized, 1);
  });

  test('si el consentimiento falla (sin red), la app sigue sin anuncios', () async {
    final sdk = _FakeSdk();
    expect(await AdsStartup(consent: _FakeConsent(allowed: true, fails: true), sdk: sdk).run(), isFalse);
    expect(sdk.initialized, 0);
  });
}
