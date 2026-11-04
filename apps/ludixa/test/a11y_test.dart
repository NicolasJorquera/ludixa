import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';

import 'support/a11y.dart';
import 'support/screens.dart';

/// Guías automáticas de accesibilidad (H7-02) en cada pantalla del lienzo,
/// en claro y oscuro: objetivos táctiles (48 dp; 36 dp en las celdas de un
/// tablero), controles con etiqueta y contraste del texto. La pantalla es alta
/// para que nada quede bajo la barra de navegación: la guía de contraste
/// mediría el color de la barra.
/// Una combinación de ajustes con la que se revisa cada pantalla.
typedef _Case = ({String name, AppSettings settings, double textScale});

void main() {
  for (final screen in screens.keys) {
    final cases = <_Case>[
      for (final theme in [ThemePreference.light, ThemePreference.dark])
        (name: theme.name, settings: AppSettings(theme: theme), textScale: 1),
      // Texto del sistema al máximo de Android.
      (name: 'texto al 200 %', settings: const AppSettings(theme: ThemePreference.light), textScale: 2),
      // La paleta para daltonismo solo cambia los colores de los juegos.
      if (screen.startsWith('partida de'))
        for (final theme in [ThemePreference.light, ThemePreference.dark])
          (
            name: 'daltonismo ${theme.name}',
            settings: AppSettings(theme: theme, colorblindPalette: true),
            textScale: 1,
          ),
    ];
    for (final c in cases) {
      testWidgets('$screen · ${c.name}', (tester) async {
        tester.view.physicalSize = const Size(390, 1600) * 3;
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = c.textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final semantics = tester.ensureSemantics();
        await openScreen(tester, screen, settings: c.settings);
        for (final guideline in ludixaTapTargetGuidelines) {
          await expectLater(tester, meetsGuideline(guideline));
        }
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(buttonsCanBeActivated));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }
}
