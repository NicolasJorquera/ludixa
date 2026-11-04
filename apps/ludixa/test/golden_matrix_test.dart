import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/locales.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';

import 'support/screens.dart';

/// Matriz de goldens (H7-01): cada pantalla del lienzo en claro y oscuro, y
/// en español, inglés y pseudolocalizado. Un teléfono de 390 dp a 1x para que
/// las imágenes pesen poco; los anchos y la escala de texto los cubre
/// `layout_test`.
const _size = Size(390, 844);

const _themes = {'claro': ThemePreference.light, 'oscuro': ThemePreference.dark};
const _locales = {'es': Locale('es', 'CL'), 'en': Locale('en', 'US'), 'pseudo': pseudoLocale};

/// "progreso: buscaminas" → progreso_buscaminas; "día del archivo" → dia_del_archivo.
String _slug(String name) => name
    .toLowerCase()
    .replaceAll(RegExp('[áà]'), 'a')
    .replaceAll(RegExp('[éè]'), 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

void main() {
  group('goldens', skip: goldensSkip, () {
    for (final screen in screens.keys) {
      for (final MapEntry(key: themeName, value: theme) in _themes.entries) {
        for (final MapEntry(key: localeName, value: locale) in _locales.entries) {
          testWidgets('$screen · $themeName · $localeName', (tester) async {
            tester.view.physicalSize = _size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await openScreen(
              tester,
              screen,
              settings: AppSettings(theme: theme, locale: locale),
              deviceLocales: [locale],
            );
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/matrix/${_slug(screen)}_${themeName}_$localeName.png'),
            );
          });
        }
      }
    }
  });

  test('cada pantalla tiene un nombre de archivo propio', () {
    final slugs = screens.keys.map(_slug).toList();
    expect(slugs.toSet(), hasLength(slugs.length), reason: slugs.join(', '));
  });
}
