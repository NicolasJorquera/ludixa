import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el tema incluye la paleta y las extensiones de cada juego', () {
    for (final brightness in Brightness.values) {
      for (final variant in PaletteVariant.values) {
        final theme = buildLudixaTheme(brightness: brightness, variant: variant);
        final colors = theme.extension<LudixaColors>()!;
        expect(colors.palette.brightness, brightness);
        expect(colors.variant, variant);
        expect(theme.extension<SudokuColors>(), isNotNull);
        expect(theme.extension<MinesweeperColors>()!.numbers, hasLength(8));
        expect(theme.extension<WordSearchColors>(), isNotNull);
        expect(theme.scaffoldBackgroundColor, colors.palette.background);
        expect(theme.colorScheme.primary, colors.palette.primary);
      }
    }
  });

  test('las fuentes salen del paquete y aplican el eje de peso', () {
    final text = buildLudixaTheme(brightness: Brightness.light).textTheme;
    expect(text.bodyMedium!.fontFamily, 'packages/design_system/Lexend');
    expect(text.headlineSmall!.fontFamily, 'packages/design_system/BricolageGrotesque');
    expect(text.titleMedium!.fontVariations, contains(const FontVariation.weight(600)));
    expect(text.headlineSmall!.fontVariations, contains(const FontVariation.weight(800)));
  });

  testWidgets('context.palette entrega la paleta activa', (tester) async {
    late LudixaPalette seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLudixaTheme(brightness: Brightness.dark),
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen.brightness, Brightness.dark);
  });

  testWidgets('las licencias OFL de las fuentes quedan registradas', (tester) async {
    registerDesignSystemLicenses();
    final packages = <String>{};
    await tester.runAsync(() async {
      await for (final entry in LicenseRegistry.licenses) {
        packages.addAll(entry.packages);
      }
    });
    expect(packages, containsAll(['Lexend', 'Bricolage Grotesque']));
  });
}
