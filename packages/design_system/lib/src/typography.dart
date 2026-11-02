import 'package:flutter/material.dart';

import 'palette.dart';

/// Familias incluidas en el paquete (SIL OFL 1.1). No se descargan en tiempo
/// de ejecución: la app funciona sin conexión.
abstract final class LudixaFonts {
  static const package = 'design_system';

  /// Interfaz y grillas: legible, con dígitos anchos.
  static const body = 'Lexend';

  /// Títulos y cifras grandes.
  static const display = 'BricolageGrotesque';
}

/// Las fuentes son variables: el peso se aplica también como eje `wght`
/// para que el motor de texto no dependa de sintetizar negritas.
TextStyle _lexend(double size, FontWeight weight, {double? height, double? letterSpacing}) => TextStyle(
  fontFamily: LudixaFonts.body,
  package: LudixaFonts.package,
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation.weight(weight.value.toDouble())],
  height: height,
  letterSpacing: letterSpacing,
);

TextStyle _bricolage(double size) => TextStyle(
  fontFamily: LudixaFonts.display,
  package: LudixaFonts.package,
  fontSize: size,
  fontWeight: FontWeight.w800,
  fontVariations: [const FontVariation.weight(800), FontVariation.opticalSize(size.clamp(12, 96).toDouble())],
  height: 1.15,
  letterSpacing: -0.01 * size,
);

/// Escala tipográfica del sistema visual.
abstract final class LudixaTypography {
  static TextTheme textTheme(LudixaPalette p) {
    final base = TextTheme(
      displayLarge: _bricolage(44),
      displayMedium: _bricolage(38),
      displaySmall: _bricolage(34),
      headlineLarge: _bricolage(34),
      headlineMedium: _bricolage(28),
      headlineSmall: _bricolage(24),
      titleLarge: _lexend(20, FontWeight.w600, height: 1.3),
      titleMedium: _lexend(17, FontWeight.w600, height: 1.3),
      titleSmall: _lexend(15, FontWeight.w600, height: 1.3),
      bodyLarge: _lexend(16, FontWeight.w400, height: 1.5),
      bodyMedium: _lexend(15, FontWeight.w400, height: 1.5),
      bodySmall: _lexend(13, FontWeight.w400, height: 1.4),
      labelLarge: _lexend(15, FontWeight.w600),
      labelMedium: _lexend(13, FontWeight.w500),
      labelSmall: _lexend(12, FontWeight.w600, letterSpacing: 0.96),
    );
    return base
        .apply(bodyColor: p.ink, displayColor: p.ink)
        .copyWith(bodySmall: base.bodySmall!.copyWith(color: p.inkMuted));
  }

  /// Dígitos de la grilla de Sudoku (23 px). Los fijos van en 500 y los del
  /// jugador en 600.
  static TextStyle gridDigit({required bool entered}) =>
      _lexend(23, entered ? FontWeight.w600 : FontWeight.w500, height: 1);

  /// Letras de la Sopa y números del Buscaminas (19 px, 600).
  static TextStyle gridLetter() => _lexend(19, FontWeight.w600, height: 1);

  /// Candidatos (notas) del Sudoku.
  static TextStyle gridNote() => _lexend(9.5, FontWeight.w500, height: 1);
}
