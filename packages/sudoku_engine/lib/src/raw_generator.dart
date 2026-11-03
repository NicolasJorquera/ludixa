import 'dart:typed_data';

import 'package:puzzle_core/puzzle_core.dart';

import 'bit_solver.dart';
import 'grid.dart';

/// Puzzle y su solución.
final class RawPuzzle {
  RawPuzzle(this.givens, this.solution);

  /// Pistas iniciales (0 = vacía).
  final Uint8List givens;
  final Uint8List solution;

  int get givenCount => givens.where((d) => d != 0).length;
}

/// Genera puzzles con solución única quitando celdas en pares simétricos
/// (simetría central: la celda i y la 80 − i) mientras la solución siga
/// siendo única.
///
/// [keep] decide si una remoción se acepta además de la unicidad: lo usa el
/// generador por dificultad para no pasarse del nivel pedido.
abstract final class RawGenerator {
  static RawPuzzle generate(Pcg32 random, {int minGivens = 17, bool Function(Uint8List candidate)? keep}) {
    final solution = BitSolver.randomSolution(random);
    final puzzle = Uint8List.fromList(solution);
    // Una entrada por par simétrico (la celda central va sola).
    final pairs = List<int>.generate(41, (i) => i);
    random.shuffle(pairs);
    var givens = SudokuGrid.cellCount;
    for (final i in pairs) {
      final j = 80 - i;
      final removing = i == j ? 1 : 2;
      if (givens - removing < minGivens) continue;
      final a = puzzle[i], b = puzzle[j];
      puzzle[i] = 0;
      puzzle[j] = 0;
      final ok = BitSolver.countSolutions(puzzle) == 1 && (keep == null || keep(puzzle));
      if (ok) {
        givens -= removing;
      } else {
        puzzle[i] = a;
        puzzle[j] = b;
      }
    }
    return RawPuzzle(puzzle, solution);
  }
}
