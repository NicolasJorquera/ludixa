import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('la app se muestra sin esperar al consentimiento, y no inicia anuncios mientras', (tester) async {
    final gate = Completer<void>();
    final consent = FakeConsent(allowed: true, gate: gate);
    final sdk = FakeAdsSdk();
    await pumpLudixa(tester, consent: consent, adsSdk: sdk);
    expect(find.text('Inicio'), findsWidgets);
    expect(consent.gathered, 1);
    expect(sdk.initialized, 0);
    gate.complete();
    await tester.pumpAndSettle();
    expect(sdk.initialized, 1);
  });

  testWidgets('sin consentimiento no se inicia el SDK de anuncios', (tester) async {
    final sdk = FakeAdsSdk();
    await pumpLudixa(tester, consent: FakeConsent(), adsSdk: sdk);
    expect(sdk.initialized, 0);
  });

  group('opciones de privacidad', () {
    Future<void> openSettings(WidgetTester tester, FakeConsent consent) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpLudixa(tester, consent: consent);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/settings');
      await tester.pumpAndSettle();
    }

    Future<void> scrollTo(WidgetTester tester, String text) =>
        tester.scrollUntilVisible(find.text(text), 200, scrollable: find.byType(Scrollable).first);

    testWidgets('donde la ley lo pide aparecen en Ajustes y abren el formulario', (tester) async {
      final consent = FakeConsent(allowed: true, privacyRequired: true);
      await openSettings(tester, consent);
      await scrollTo(tester, 'Opciones de privacidad');
      await tester.tap(find.text('Opciones de privacidad'));
      await tester.pumpAndSettle();
      expect(consent.privacyFormsShown, 1);
    });

    testWidgets('fuera de esas regiones no aparecen', (tester) async {
      await openSettings(tester, FakeConsent(allowed: true));
      await scrollTo(tester, 'Versión');
      expect(find.text('Opciones de privacidad'), findsNothing);
    });

    testWidgets('el contrato de anuncios enlaza a ellas donde corresponde', (tester) async {
      final consent = FakeConsent(allowed: true, privacyRequired: true);
      await openSettings(tester, consent);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/settings/ads');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Opciones de privacidad'));
      expect(consent.privacyFormsShown, 1);
    });
  });
}
