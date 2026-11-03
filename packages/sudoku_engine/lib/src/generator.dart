import 'dart:typed_data';

import 'package:puzzle_core/puzzle_core.dart';

import 'human/human_solver.dart';
import 'human/techniques.dart';
import 'raw_generator.dart';

/// Puzzle listo para jugar.
final class SudokuPuzzle {
  SudokuPuzzle({required this.givens, required this.solution, required this.difficulty});

  final Uint8List givens;
  final Uint8List solution;
  final SudokuDifficulty difficulty;

  int get givenCount => givens.where((d) => d != 0).length;
}

/// No se logró un puzzle del nivel pedido en los intentos disponibles.
/// Quien llama recurre al banco pregenerado (H3-07).
final class SudokuGenerationFailed implements Exception {
  SudokuGenerationFailed(this.difficulty, this.attempts);

  final SudokuDifficulty difficulty;
  final int attempts;

  @override
  String toString() => 'SudokuGenerationFailed: ${difficulty.name} tras $attempts intentos';
}

/// Genera Sudokus de un nivel exacto.
///
/// En cada intento quita pistas en pares simétricos mientras la solución siga
/// siendo única y el solver humano lo resuelva sin pasarse del nivel; se
/// detiene en una cantidad de pistas orientativa del nivel. Acepta el puzzle
/// solo si la técnica más difícil que exige es justo la del nivel.
final class SudokuGenerator {
  const SudokuGenerator({this.maxAttempts = 40});

  /// Versión del algoritmo; forma parte de la semilla del reto diario.
  static const int version = 1;

  /// Piso de pistas por nivel. El nivel lo define la técnica más difícil que
  /// exige el puzzle, no la cantidad de pistas: estos pisos solo evitan que un
  /// Fácil quede demasiado vacío y dan margen a los niveles altos para que
  /// aparezcan sus técnicas.
  static const givensRange = {
    SudokuDifficulty.easy: (38, 45),
    SudokuDifficulty.medium: (26, 30),
    SudokuDifficulty.hard: (24, 28),
    SudokuDifficulty.expert: (22, 26),
  };

  final int maxAttempts;

  SudokuPuzzle generate(SudokuDifficulty target, Pcg32 random) {
    final (low, high) = givensRange[target]!;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final minGivens = random.nextIntInRange(low, high);
      final raw = RawGenerator.generate(
        random,
        minGivens: minGivens,
        keep: (candidate) => HumanSolver.solve(candidate, limit: target).solved,
      );
      if (HumanSolver.grade(raw.givens) == target) {
        return SudokuPuzzle(givens: raw.givens, solution: raw.solution, difficulty: target);
      }
    }
    throw SudokuGenerationFailed(target, maxAttempts);
  }
}
