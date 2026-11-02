import 'package:flutter/material.dart';

import 'palette.dart';

/// Colores de la grilla de Sudoku.
@immutable
final class SudokuColors extends ThemeExtension<SudokuColors> {
  const SudokuColors({
    required this.cell,
    required this.zone,
    required this.sameNumber,
    required this.selected,
    required this.conflict,
    required this.conflictInk,
    required this.given,
    required this.entered,
    required this.note,
    required this.thickLine,
    required this.thinLine,
  });

  factory SudokuColors.from(LudixaPalette p) {
    final light = p.brightness == Brightness.light;
    return SudokuColors(
      cell: p.surface,
      zone: light ? const Color(0xFFEEF2FC) : const Color(0xFF1C2433),
      sameNumber: light ? const Color(0xFFD6E0FB) : const Color(0xFF26345F),
      selected: light ? const Color(0xFFB9CAF8) : const Color(0xFF34478A),
      conflict: p.dangerSoft,
      conflictInk: p.dangerInk,
      given: p.ink,
      entered: light ? p.sudoku : const Color(0xFFB4C3FF),
      note: p.inkMuted,
      thickLine: light ? p.ink : const Color(0xFF8D97A6),
      thinLine: p.line,
    );
  }

  final Color cell;

  /// Fila, columna y caja de la celda seleccionada.
  final Color zone;

  /// Celdas con el mismo número que la seleccionada.
  final Color sameNumber;
  final Color selected;
  final Color conflict;
  final Color conflictInk;

  /// Números fijos del puzzle.
  final Color given;

  /// Números colocados por el jugador.
  final Color entered;
  final Color note;
  final Color thickLine;
  final Color thinLine;

  @override
  SudokuColors copyWith() => this;

  @override
  SudokuColors lerp(SudokuColors? other, double t) => t < 0.5 || other == null ? this : other;
}

/// Colores del tablero de Buscaminas.
@immutable
final class MinesweeperColors extends ThemeExtension<MinesweeperColors> {
  const MinesweeperColors({
    required this.closed,
    required this.closedEdge,
    required this.open,
    required this.flag,
    required this.fatal,
    required this.onFatal,
    required this.numbers,
  });

  factory MinesweeperColors.from(LudixaPalette p, PaletteVariant variant) {
    final light = p.brightness == Brightness.light;
    final colorblind = variant == PaletteVariant.colorblind;
    final List<Color> numbers;
    if (light) {
      numbers = colorblind
          ? const [
              Color(0xFF0060A0),
              Color(0xFF00785A),
              Color(0xFFB84A00),
              Color(0xFF9E3F7A),
              Color(0xFF7A5A00),
              Color(0xFF006578),
              Color(0xFF141B26),
              Color(0xFF4D5868),
            ]
          : const [
              Color(0xFF2B4FD8),
              Color(0xFF1B7F4E),
              Color(0xFFC42B2B),
              Color(0xFF6B3FB5),
              Color(0xFF8A4B0F),
              Color(0xFF0F7A6C),
              Color(0xFF141B26),
              Color(0xFF4D5868),
            ];
    } else {
      numbers = colorblind
          ? const [
              Color(0xFF7FB8E8),
              Color(0xFF5CC8A8),
              Color(0xFFFF9F5A),
              Color(0xFFE7A0CC),
              Color(0xFFE8C45A),
              Color(0xFF6CC8D8),
              Color(0xFFE8ECF2),
              Color(0xFFA3ADBB),
            ]
          : const [
              Color(0xFF8EA6FF),
              Color(0xFF5CC895),
              Color(0xFFFF7A7A),
              Color(0xFFC3A1FF),
              Color(0xFFE0A66B),
              Color(0xFF4CC7B4),
              Color(0xFFE8ECF2),
              Color(0xFFA3ADBB),
            ];
    }
    return MinesweeperColors(
      closed: light ? const Color(0xFFCFD7E3) : const Color(0xFF323C4B),
      closedEdge: light ? const Color(0xFFB5C0CF) : const Color(0xFF252D39),
      open: light ? const Color(0xFFF4F6F9) : const Color(0xFF12171D),
      flag: p.minesweeper,
      fatal: light ? const Color(0xFFC42B2B) : const Color(0xFFD94848),
      onFatal: const Color(0xFFFFFFFF),
      numbers: numbers,
    );
  }

  /// Celda sin revelar (más clara que la abierta en oscuro: se ve "en relieve").
  final Color closed;
  final Color closedEdge;
  final Color open;
  final Color flag;

  /// Fondo de la mina que terminó la partida.
  final Color fatal;
  final Color onFatal;

  /// Color de los números 1 a 8 (índice 0 = número 1).
  final List<Color> numbers;

  Color number(int n) => numbers[n - 1];

  @override
  MinesweeperColors copyWith() => this;

  @override
  MinesweeperColors lerp(MinesweeperColors? other, double t) => t < 0.5 || other == null ? this : other;
}

/// Colores de la Sopa de letras.
@immutable
final class WordSearchColors extends ThemeExtension<WordSearchColors> {
  const WordSearchColors({
    required this.letter,
    required this.found,
    required this.foundInk,
    required this.selecting,
    required this.onSelecting,
  });

  factory WordSearchColors.from(LudixaPalette p) {
    final light = p.brightness == Brightness.light;
    return WordSearchColors(
      letter: p.ink,
      found: light ? const Color(0xFFD5EEEA) : const Color(0xFF15332E),
      foundInk: light ? const Color(0xFF0A5C51) : const Color(0xFF7FE0D0),
      selecting: p.primary,
      onSelecting: p.onPrimary,
    );
  }

  final Color letter;

  /// Celdas de palabras encontradas.
  final Color found;
  final Color foundInk;

  /// Selección en curso.
  final Color selecting;
  final Color onSelecting;

  @override
  WordSearchColors copyWith() => this;

  @override
  WordSearchColors lerp(WordSearchColors? other, double t) => t < 0.5 || other == null ? this : other;
}
