import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';

void main() {
  test('300 puzzles por nivel, sin repetir, y menos de 1 MB', () {
    final all = <String>{};
    var chars = 0;
    for (final level in SudokuDifficulty.values) {
      expect(SudokuBank.sizeOf(level), 300);
      for (var i = 0; i < SudokuBank.sizeOf(level); i++) {
        final text = formatGrid(SudokuBank.at(level, i).givens);
        expect(all.add(text), isTrue, reason: '${level.name} $i repetido');
        chars += text.length;
      }
    }
    expect(chars, lessThan(1000000));
  });

  test('cada puzzle tiene solución única y exige justo su nivel', () {
    for (final level in SudokuDifficulty.values) {
      for (var i = 0; i < SudokuBank.sizeOf(level); i++) {
        final puzzle = SudokuBank.at(level, i);
        expect(BitSolver.countSolutions(puzzle.givens), 1, reason: '${level.name} $i');
        expect(HumanSolver.grade(puzzle.givens), level, reason: '${level.name} $i');
        for (var c = 0; c < SudokuGrid.cellCount; c++) {
          if (puzzle.givens[c] != 0) expect(puzzle.solution[c], puzzle.givens[c]);
        }
      }
    }
  });

  test('reproducible: el generador vuelve a dar las primeras entradas del banco', () {
    for (final level in SudokuDifficulty.values) {
      final rebuilt = SudokuBank.build(level, 3);
      expect(rebuilt, [for (var i = 0; i < 3; i++) formatGrid(SudokuBank.at(level, i).givens)], reason: level.name);
    }
  });

  test('la selección es determinista por semilla', () {
    SudokuPuzzle pick(String key) => SudokuBank.pick(SudokuDifficulty.hard, PuzzleSeed.fromKey(key).createRandom());
    expect(pick('a').givens, pick('a').givens);
    final distinct = {for (var i = 0; i < 20; i++) formatGrid(pick('dia-$i').givens)};
    expect(distinct.length, greaterThan(15));
  });

  group('partida libre', () {
    test('con tiempo de sobra genera el puzzle en el momento', () {
      final result = freePlaySudoku(SudokuDifficulty.easy, Pcg32(7, 7), budget: const Duration(seconds: 30));
      expect(result.fromBank, isFalse);
      expect(HumanSolver.grade(result.puzzle.givens), SudokuDifficulty.easy);
    });

    test('si se agota el tiempo usa el banco', () {
      for (final level in SudokuDifficulty.values) {
        final result = freePlaySudoku(level, Pcg32(7, 7), budget: Duration.zero);
        expect(result.fromBank, isTrue, reason: level.name);
        expect(result.puzzle.difficulty, level);
        expect(HumanSolver.grade(result.puzzle.givens), level);
      }
    });

    test('si el generador no encuentra puzzle usa el banco', () {
      final result = freePlaySudoku(
        SudokuDifficulty.expert,
        Pcg32(1, 1),
        budget: const Duration(seconds: 30),
        generator: const SudokuGenerator(maxAttempts: 0),
      );
      expect(result.fromBank, isTrue);
    });

    test('un presupuesto que vence a mitad de un intento lo corta', () {
      var calls = 0;
      expect(
        () => const SudokuGenerator().generate(SudokuDifficulty.hard, Pcg32(2, 2), expired: () => ++calls > 5),
        throwsA(isA<SudokuGenerationFailed>()),
      );
      // Corta en el primer intento, no después de los 40.
      expect(calls, lessThan(60));
    });
  });
}
