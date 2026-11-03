import 'dart:typed_data';

import '../grid.dart';

/// Valores colocados y candidatos de cada celda vacía, como los anotaría un
/// jugador que no se equivoca.
final class CandidateGrid {
  CandidateGrid._(this.values, this.candidates);

  /// Construye los candidatos a partir de los valores colocados.
  factory CandidateGrid.fromValues(List<int> grid) {
    final values = Uint8List.fromList(grid);
    final candidates = Uint16List(SudokuGrid.cellCount);
    for (var i = 0; i < SudokuGrid.cellCount; i++) {
      if (values[i] != 0) continue;
      var mask = SudokuGrid.allDigits;
      for (final p in SudokuGrid.peers[i]) {
        if (values[p] != 0) mask &= ~(1 << values[p]);
      }
      candidates[i] = mask;
    }
    return CandidateGrid._(values, candidates);
  }

  /// Estado con candidatos explícitos. Para pruebas y herramientas que
  /// necesitan construir un patrón concreto.
  factory CandidateGrid.fromCandidates(List<int> values, List<int> candidates) =>
      CandidateGrid._(Uint8List.fromList(values), Uint16List.fromList(candidates));

  final Uint8List values;

  /// Máscara de candidatos (bits 1–9); 0 en celdas con valor.
  final Uint16List candidates;

  bool get isSolved => !values.contains(0);

  bool hasCandidate(int cell, int digit) => candidates[cell] & (1 << digit) != 0;

  /// Coloca [digit] en [cell] y lo quita de los candidatos de sus vecinas.
  void place(int cell, int digit) {
    values[cell] = digit;
    candidates[cell] = 0;
    final bit = 1 << digit;
    for (final p in SudokuGrid.peers[cell]) {
      candidates[p] &= ~bit;
    }
  }

  void eliminate(int cell, int digit) => candidates[cell] &= ~(1 << digit);

  /// Celdas vacías de una unidad que admiten [digit].
  List<int> positions(int unit, int digit) {
    final bit = 1 << digit;
    return [
      for (final c in SudokuGrid.units[unit])
        if (candidates[c] & bit != 0) c,
    ];
  }

  CandidateGrid copy() => CandidateGrid._(Uint8List.fromList(values), Uint16List.fromList(candidates));
}
