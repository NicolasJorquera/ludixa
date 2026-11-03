import 'package:flutter/foundation.dart';

/// Cómo se ingresan los números.
enum SudokuInputMode {
  /// Se toca una celda y luego un número (por defecto).
  cellFirst,

  /// Se elige un número y luego se tocan celdas.
  numberFirst,
}

/// Cómo se señalan los errores (PRD). No hay límite de errores.
enum SudokuErrorMode {
  /// Solo números repetidos en su fila, columna o caja (por defecto).
  conflicts,

  /// Números que no coinciden con la solución.
  solution,

  /// Sin indicación.
  none,
}

/// Preferencias de la partida. Se guardan y se editan en H4-02 y H4-09.
@immutable
final class SudokuSettings {
  const SudokuSettings({
    this.inputMode = SudokuInputMode.cellFirst,
    this.errorMode = SudokuErrorMode.conflicts,
    this.removeNotesOnPlace = true,
    this.highlightSameNumber = true,
    this.showTimer = true,
    this.haptics = true,
  });

  final SudokuInputMode inputMode;
  final SudokuErrorMode errorMode;
  final bool removeNotesOnPlace;
  final bool highlightSameNumber;
  final bool showTimer;
  final bool haptics;
}
