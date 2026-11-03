import 'package:puzzle_core/puzzle_core.dart';

import '../bit_solver.dart';
import '../generator.dart';
import '../grid.dart';
import '../human/techniques.dart';
import 'bank_data.dart';

/// Banco de Sudokus pregenerados (ADR 0004).
///
/// Lo usa el reto diario, que debe ser idéntico en todos los dispositivos, y la
/// partida libre cuando la generación en el teléfono se pasa de su presupuesto
/// de tiempo o no encuentra un puzzle del nivel.
///
/// Los datos los escribe `tool/generate_bank.dart` y se pueden reproducir:
/// la entrada `i` de un nivel sale de la semilla [keyFor] con el primer índice
/// libre, en orden, saltando los que fallan o repiten un puzzle anterior.
abstract final class SudokuBank {
  /// Versión del banco. Cambiarla cambia todos los puzzles del reto diario.
  static const int version = 1;

  static String keyFor(SudokuDifficulty level, int index) =>
      'sudoku-bank|v$version|g${SudokuGenerator.version}|${level.name}|$index';

  static int sizeOf(SudokuDifficulty level) => sudokuBankData[level]!.length;

  /// Puzzle [index] del nivel, con su solución.
  static SudokuPuzzle at(SudokuDifficulty level, int index) {
    final givens = parseGrid(sudokuBankData[level]![index]);
    return SudokuPuzzle(givens: givens, solution: BitSolver.solve(givens)!, difficulty: level);
  }

  /// Un puzzle del nivel elegido por [random] (determinista para una semilla).
  static SudokuPuzzle pick(SudokuDifficulty level, Pcg32 random) => at(level, random.nextInt(sizeOf(level)));

  /// Recalcula las primeras [count] entradas de un nivel. Es lo que usa el
  /// comando de generación y lo que verifica la prueba de reproducibilidad.
  static List<String> build(SudokuDifficulty level, int count, {SudokuGenerator generator = const SudokuGenerator()}) {
    final entries = <String>[];
    final seen = <String>{};
    for (var index = 0; entries.length < count; index++) {
      try {
        final puzzle = generator.generate(level, PuzzleSeed.fromKey(keyFor(level, index)).createRandom());
        final text = formatGrid(puzzle.givens);
        if (seen.add(text)) entries.add(text);
      } on SudokuGenerationFailed {
        continue;
      }
    }
    return entries;
  }
}

/// Puzzle para partida libre: generado en el momento o, si eso falla o se
/// pasa de [budget], tomado del banco.
({SudokuPuzzle puzzle, bool fromBank}) freePlaySudoku(
  SudokuDifficulty level,
  Pcg32 random, {
  required Duration budget,
  SudokuGenerator generator = const SudokuGenerator(),
}) {
  final watch = Stopwatch()..start();
  try {
    return (puzzle: generator.generate(level, random, expired: () => watch.elapsed >= budget), fromBank: false);
  } on SudokuGenerationFailed {
    return (puzzle: SudokuBank.pick(level, random), fromBank: true);
  }
}
