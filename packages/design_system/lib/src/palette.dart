import 'package:flutter/material.dart';

/// Variante de color elegida en Ajustes.
enum PaletteVariant {
  standard,

  /// Evita depender de la distinción rojo/verde: éxito en azul, conflicto en
  /// naranja y números del Buscaminas basados en Okabe-Ito oscurecidos.
  colorblind,
}

/// Tokens de color de la app. Valores del sistema visual (lámina "Sistema visual").
///
/// Cada color de la interfaz sale de aquí: ningún widget usa colores literales.
@immutable
final class LudixaPalette {
  const LudixaPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.sudoku,
    required this.sudokuSoft,
    required this.minesweeper,
    required this.minesweeperSoft,
    required this.wordSearch,
    required this.wordSearchSoft,
    required this.success,
    required this.successSoft,
    required this.successInk,
    required this.danger,
    required this.dangerSoft,
    required this.dangerInk,
    required this.hintSoft,
    required this.adOutline,
  });

  final Brightness brightness;

  /// Fondo de pantalla.
  final Color background;

  /// Tarjetas, barras y hojas.
  final Color surface;

  /// Zonas apagadas dentro de una superficie (pendientes, pistas de control).
  final Color surfaceMuted;

  /// Texto principal.
  final Color ink;

  /// Texto secundario (≥ 4,5:1 sobre fondo y superficie).
  final Color inkMuted;

  /// Bordes decorativos y separadores.
  final Color line;

  /// Bordes de controles que deben distinguirse (≥ 3:1).
  final Color outline;

  final Color primary;
  final Color onPrimary;
  final Color primarySoft;

  final Color sudoku;
  final Color sudokuSoft;
  final Color minesweeper;
  final Color minesweeperSoft;
  final Color wordSearch;
  final Color wordSearchSoft;

  final Color success;
  final Color successSoft;

  /// Texto sobre [successSoft].
  final Color successInk;

  final Color danger;
  final Color dangerSoft;

  /// Texto sobre [dangerSoft].
  final Color dangerInk;

  /// Fondo de las zonas resaltadas por una pista.
  final Color hintSoft;

  /// Contorno punteado del espacio publicitario.
  final Color adOutline;

  /// Texto e iconos de un control deshabilitado (WCAG no exige contraste).
  Color get inkDisabled => inkMuted.withValues(alpha: 0.5);

  /// Fondo del segmento elegido: en oscuro, el contorno translúcido.
  Color get segmentSelected => brightness == Brightness.light ? surface : outline.withValues(alpha: 0.35);

  static const light = LudixaPalette(
    brightness: Brightness.light,
    background: Color(0xFFF2F4F7),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF2F4F7),
    ink: Color(0xFF141B26),
    inkMuted: Color(0xFF4D5868),
    line: Color(0xFFDCE1E8),
    outline: Color(0xFF7B8697),
    primary: Color(0xFF2B4FD8),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE6ECFC),
    sudoku: Color(0xFF2B4FD8),
    sudokuSoft: Color(0xFFE6ECFC),
    minesweeper: Color(0xFFC4501B),
    minesweeperSoft: Color(0xFFFCEBE2),
    wordSearch: Color(0xFF0F7A6C),
    wordSearchSoft: Color(0xFFE0F2EF),
    success: Color(0xFF1B7F4E),
    successSoft: Color(0xFFE1F2E8),
    successInk: Color(0xFF145C39),
    danger: Color(0xFFC42B2B),
    dangerSoft: Color(0xFFFBE3E3),
    dangerInk: Color(0xFFA32020),
    hintSoft: Color(0xFFFDF1D8),
    adOutline: Color(0xFFAEB7C4),
  );

  static const dark = LudixaPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0F1318),
    surface: Color(0xFF181D24),
    surfaceMuted: Color(0xFF212833),
    ink: Color(0xFFE8ECF2),
    inkMuted: Color(0xFFA3ADBB),
    line: Color(0xFF2C3440),
    outline: Color(0xFF6E7A8A),
    primary: Color(0xFF7D97FF),
    onPrimary: Color(0xFF0F1318),
    primarySoft: Color(0xFF1F2A4D),
    sudoku: Color(0xFF7D97FF),
    sudokuSoft: Color(0xFF1F2A4D),
    minesweeper: Color(0xFFFF8A57),
    minesweeperSoft: Color(0xFF3A2419),
    wordSearch: Color(0xFF4CC7B4),
    wordSearchSoft: Color(0xFF15332E),
    success: Color(0xFF5CC895),
    successSoft: Color(0xFF16302A),
    successInk: Color(0xFF8FE0B8),
    danger: Color(0xFFFF7A7A),
    dangerSoft: Color(0xFF4A1F22),
    dangerInk: Color(0xFFFFA3A3),
    hintSoft: Color(0xFF3A3020),
    adOutline: Color(0xFF4A5462),
  );

  /// Paleta para la combinación de brillo y variante.
  static LudixaPalette of(Brightness brightness, PaletteVariant variant) {
    final base = brightness == Brightness.light ? light : dark;
    if (variant == PaletteVariant.standard) return base;
    return brightness == Brightness.light
        ? base._withSemantic(
            success: const Color(0xFF1F5FBF),
            successSoft: const Color(0xFFE2ECFA),
            successInk: const Color(0xFF164A96),
            danger: const Color(0xFFB04A00),
            dangerSoft: const Color(0xFFFCE9DA),
            dangerInk: const Color(0xFF8F3C00),
          )
        : base._withSemantic(
            success: const Color(0xFF7FB2FF),
            successSoft: const Color(0xFF1B2A44),
            successInk: const Color(0xFFA9CBFF),
            danger: const Color(0xFFFFA05A),
            dangerSoft: const Color(0xFF3D2814),
            dangerInk: const Color(0xFFFFC08F),
          );
  }

  LudixaPalette _withSemantic({
    required Color success,
    required Color successSoft,
    required Color successInk,
    required Color danger,
    required Color dangerSoft,
    required Color dangerInk,
  }) => LudixaPalette(
    brightness: brightness,
    background: background,
    surface: surface,
    surfaceMuted: surfaceMuted,
    ink: ink,
    inkMuted: inkMuted,
    line: line,
    outline: outline,
    primary: primary,
    onPrimary: onPrimary,
    primarySoft: primarySoft,
    sudoku: sudoku,
    sudokuSoft: sudokuSoft,
    minesweeper: minesweeper,
    minesweeperSoft: minesweeperSoft,
    wordSearch: wordSearch,
    wordSearchSoft: wordSearchSoft,
    success: success,
    successSoft: successSoft,
    successInk: successInk,
    danger: danger,
    dangerSoft: dangerSoft,
    dangerInk: dangerInk,
    hintSoft: hintSoft,
    adOutline: adOutline,
  );
}
