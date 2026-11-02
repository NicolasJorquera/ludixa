import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/locales.dart';

import 'support/test_app.dart';

Set<String> _keys(String file) {
  final json = jsonDecode(File('lib/l10n/$file').readAsStringSync()) as Map<String, Object?>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  group('archivos ARB', () {
    test('es, en y la pseudolocalización tienen exactamente las mismas claves', () {
      final es = _keys('app_es.arb');
      expect(_keys('app_en.arb'), es, reason: 'faltan o sobran claves en app_en.arb');
      expect(_keys('app_en_XA.arb'), es, reason: 'regenerar con: dart run tool/pseudo_l10n.dart');
    });

    test('cada clave de la plantilla en español tiene descripción', () {
      final json = jsonDecode(File('lib/l10n/app_es.arb').readAsStringSync()) as Map<String, Object?>;
      for (final key in _keys('app_es.arb')) {
        expect(json['@$key'], isA<Map<String, Object?>>(), reason: '@$key sin descripción');
      }
    });
  });

  group('resolución de idioma', () {
    test('usa el idioma del sistema ignorando la región', () {
      expect(resolveLocale(const [Locale('es', 'CL')], releaseLocales), const Locale('es'));
      expect(resolveLocale(const [Locale('en', 'GB')], releaseLocales), const Locale('en'));
    });

    test('recorre la lista de preferidos en orden', () {
      expect(resolveLocale(const [Locale('fr'), Locale('es')], releaseLocales), const Locale('es'));
    });

    test('cae en inglés si ningún idioma está soportado', () {
      expect(resolveLocale(const [Locale('fr', 'FR')], releaseLocales), fallbackLocale);
      expect(resolveLocale(null, releaseLocales), fallbackLocale);
    });

    test('respeta la pseudolocalización cuando está soportada', () {
      expect(resolveLocale(const [pseudoLocale], [...releaseLocales, pseudoLocale]), pseudoLocale);
    });

    testWidgets('con el sistema en francés la app se muestra en inglés', (tester) async {
      await pumpLudixa(tester, deviceLocales: const [Locale('fr', 'FR')]);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('con el sistema en español de Chile la app se muestra en español', (tester) async {
      await pumpLudixa(tester, deviceLocales: const [Locale('es', 'CL')]);
      expect(find.text('Inicio'), findsWidgets);
    });
  });
}
