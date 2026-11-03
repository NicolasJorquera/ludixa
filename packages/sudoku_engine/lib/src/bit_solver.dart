import 'dart:typed_data';

import 'package:puzzle_core/puzzle_core.dart';

import 'grid.dart';

/// Solver por fuerza bruta con máscaras de bits (no es el que razona como un
/// humano). Sirve para contar soluciones, resolver y rellenar grillas al azar.
abstract final class BitSolver {
  /// Cuenta soluciones hasta [limit]. Con `limit: 2` responde si la solución es única.
  static int countSolutions(List<int> grid, {int limit = 2}) {
    final search = _Search.from(grid);
    if (search == null) return 0;
    return search.count(limit);
  }

  /// Primera solución encontrada, o null si no hay.
  static Uint8List? solve(List<int> grid) {
    final search = _Search.from(grid);
    if (search == null) return null;
    return search.count(1) == 1 ? search.firstSolution : null;
  }

  /// Grilla completa válida elegida al azar con [random]. Determinista.
  static Uint8List randomSolution(Pcg32 random) {
    final search = _Search.from(Uint8List(SudokuGrid.cellCount))!..random = random;
    search.count(1);
    return search.firstSolution!;
  }
}

final class _Search {
  _Search._(this.values);

  static _Search? from(List<int> grid) {
    final s = _Search._(Uint8List.fromList(grid));
    for (var i = 0; i < SudokuGrid.cellCount; i++) {
      final d = s.values[i];
      if (d == 0) continue;
      if (d < 1 || d > 9) return null;
      final bit = 1 << d;
      final r = SudokuGrid.rowOf(i), c = SudokuGrid.columnOf(i), b = SudokuGrid.boxOf(i);
      // Una pista repetida en una unidad hace el puzzle imposible.
      if ((s.rows[r] | s.cols[c] | s.boxes[b]) & bit != 0) return null;
      s.rows[r] |= bit;
      s.cols[c] |= bit;
      s.boxes[b] |= bit;
    }
    return s;
  }

  final Uint8List values;
  final rows = Int32List(9);
  final cols = Int32List(9);
  final boxes = Int32List(9);
  Pcg32? random;
  Uint8List? firstSolution;
  int _found = 0;

  int count(int limit) {
    _found = 0;
    _recurse(limit);
    return _found;
  }

  void _recurse(int limit) {
    // Elige la celda vacía con menos candidatos (MRV).
    var best = -1;
    var bestMask = 0;
    var bestCount = 10;
    for (var i = 0; i < SudokuGrid.cellCount; i++) {
      if (values[i] != 0) continue;
      final mask =
          SudokuGrid.allDigits &
          ~(rows[SudokuGrid.rowOf(i)] | cols[SudokuGrid.columnOf(i)] | boxes[SudokuGrid.boxOf(i)]);
      final n = popCount(mask);
      if (n < bestCount) {
        best = i;
        bestMask = mask;
        bestCount = n;
        if (n <= 1) break;
      }
    }
    if (best == -1) {
      _found++;
      firstSolution ??= Uint8List.fromList(values);
      return;
    }
    if (bestCount == 0) return;

    final digits = digitsOf(bestMask);
    random?.shuffle(digits);
    final r = SudokuGrid.rowOf(best), c = SudokuGrid.columnOf(best), b = SudokuGrid.boxOf(best);
    for (final d in digits) {
      final bit = 1 << d;
      values[best] = d;
      rows[r] |= bit;
      cols[c] |= bit;
      boxes[b] |= bit;
      _recurse(limit);
      rows[r] &= ~bit;
      cols[c] &= ~bit;
      boxes[b] &= ~bit;
      values[best] = 0;
      if (_found >= limit) return;
    }
  }
}
