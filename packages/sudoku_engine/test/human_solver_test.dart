import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';

import 'bit_solver_test.dart' show wikipediaPuzzle;

int _cell(int row, int column) => row * 9 + column;

int _mask(List<int> digits) => digits.fold(0, (m, d) => m | (1 << d));

/// Grilla vacía con todos los candidatos, para construir patrones a mano.
({List<int> values, List<int> candidates}) _open() =>
    (values: List.filled(81, 0), candidates: List.filled(81, SudokuGrid.allDigits));

/// Resuelve paso a paso verificando cada paso contra la solución real.
void _expectSoundSolve(List<int> givens, List<int> solution, {String reason = ''}) {
  final grid = CandidateGrid.fromValues(givens);
  while (!grid.isSolved) {
    final step = HumanSolver.nextStep(grid);
    if (step == null) break;
    if (step.isPlacement) {
      expect(step.digit, solution[step.cell!], reason: '$reason: ${step.technique.name} coloca mal');
    }
    for (final (c, d) in step.eliminations) {
      expect(d, isNot(solution[c]), reason: '$reason: ${step.technique.name} descarta la solución en $c');
    }
    step.applyTo(grid);
    // Ninguna celda vacía se queda sin su dígito correcto.
    for (var i = 0; i < 81; i++) {
      if (grid.values[i] == 0) {
        expect(grid.hasCandidate(i, solution[i]), isTrue, reason: '$reason: celda $i perdió su solución');
      }
    }
  }
}

void main() {
  group('técnicas sobre patrones construidos a mano', () {
    test('pointing: el 4 de la caja 0 está solo en la fila 0', () {
      final g = _open();
      for (final c in [_cell(1, 0), _cell(1, 1), _cell(1, 2), _cell(2, 0), _cell(2, 1), _cell(2, 2), _cell(0, 0)]) {
        g.candidates[c] &= ~_mask([4]);
      }
      final step = findStep(SudokuTechnique.pointing, CandidateGrid.fromCandidates(g.values, g.candidates))!;
      expect(step.eliminations, containsAll([(_cell(0, 5), 4), (_cell(0, 8), 4)]));
      expect(step.eliminations.every((e) => SudokuGrid.rowOf(e.$1) == 0 && SudokuGrid.boxOf(e.$1) != 0), isTrue);
    });

    test('par desnudo: dos celdas de la fila 0 con {2,3}', () {
      final g = _open();
      g.candidates[_cell(0, 0)] = _mask([2, 3]);
      g.candidates[_cell(0, 1)] = _mask([2, 3]);
      final step = findStep(SudokuTechnique.nakedPair, CandidateGrid.fromCandidates(g.values, g.candidates))!;
      expect(step.pattern, [_cell(0, 0), _cell(0, 1)]);
      expect(step.eliminations, contains((_cell(0, 5), 2)));
      expect(step.eliminations, contains((_cell(0, 5), 3)));
      expect(step.eliminations.any((e) => e.$1 == _cell(0, 0) || e.$1 == _cell(0, 1)), isFalse);
    });

    test('X-Wing: el 5 de las filas 1 y 5 solo en las columnas 2 y 7', () {
      final g = _open();
      for (final row in [1, 5]) {
        for (var c = 0; c < 9; c++) {
          if (c != 2 && c != 7) g.candidates[_cell(row, c)] &= ~_mask([5]);
        }
      }
      final step = findStep(SudokuTechnique.xWing, CandidateGrid.fromCandidates(g.values, g.candidates))!;
      expect(step.eliminations, contains((_cell(8, 2), 5)));
      expect(step.eliminations, contains((_cell(0, 7), 5)));
      expect(step.eliminations.any((e) => [1, 5].contains(SudokuGrid.rowOf(e.$1))), isFalse);
      expect(step.eliminations.every((e) => e.$2 == 5), isTrue);
    });

    test('XY-Wing: pivote {1,2}, alas {1,3} y {2,3}: el 3 sale de la celda que ve a ambas alas', () {
      final g = _open();
      g.candidates[_cell(0, 0)] = _mask([1, 2]);
      g.candidates[_cell(0, 5)] = _mask([1, 3]);
      g.candidates[_cell(5, 0)] = _mask([2, 3]);
      final step = findStep(SudokuTechnique.xyWing, CandidateGrid.fromCandidates(g.values, g.candidates))!;
      expect(step.pattern, [_cell(0, 0), _cell(0, 5), _cell(5, 0)]);
      expect(step.eliminations, [(_cell(5, 5), 3)]);
    });
  });

  group('calificación', () {
    test('el ejemplo de Wikipedia es Fácil y se resuelve', () {
      final report = HumanSolver.solve(parseGrid(wikipediaPuzzle));
      expect(report.solved, isTrue);
      expect(report.difficulty, SudokuDifficulty.easy);
    });

    test('un puzzle muy difícil queda fuera de nuestras técnicas', () {
      // Puzzle conocido por exigir técnicas más allá de Swordfish.
      final hard = parseGrid('800000000003600000070090200050007000000045700000100030001000068008500010090000400');
      expect(BitSolver.countSolutions(hard), 1);
      expect(HumanSolver.grade(hard), isNull);
    });

    test('el límite detiene el solver antes de usar técnicas más difíciles', () {
      final puzzle = const SudokuGenerator().generate(SudokuDifficulty.hard, Pcg32(1, 1));
      final limited = HumanSolver.solve(puzzle.givens, limit: SudokuDifficulty.medium);
      expect(limited.solved, isFalse);
      expect(limited.steps.every((s) => s.technique.difficulty.index <= SudokuDifficulty.medium.index), isTrue);
    });
  });

  group('solidez', () {
    test('ningún paso coloca o descarta mal en 300 puzzles sin calificar', () {
      for (var i = 0; i < 300; i++) {
        final raw = RawGenerator.generate(Pcg32(i, 11));
        _expectSoundSolve(raw.givens, raw.solution, reason: 'semilla $i');
      }
    });
  });

  group('generador por nivel', () {
    for (final level in SudokuDifficulty.values) {
      test('${level.name}: cada puzzle exige justo ese nivel, tiene solución única y se resuelve bien', () {
        var generated = 0;
        for (var i = 0; i < 25; i++) {
          final SudokuPuzzle puzzle;
          try {
            puzzle = const SudokuGenerator().generate(
              level,
              PuzzleSeed.fromKey('nivel|${level.name}|$i').createRandom(),
            );
          } on SudokuGenerationFailed {
            continue;
          }
          generated++;
          expect(puzzle.difficulty, level);
          expect(HumanSolver.grade(puzzle.givens), level);
          expect(BitSolver.countSolutions(puzzle.givens), 1);
          _expectSoundSolve(puzzle.givens, puzzle.solution, reason: '${level.name} $i');
          if (level == SudokuDifficulty.easy) expect(puzzle.givenCount, greaterThanOrEqualTo(38));
        }
        // Con 40 intentos por puzzle, la mayoría debe salir; los demás van al banco.
        expect(generated, greaterThanOrEqualTo(15), reason: 'demasiados fallos en ${level.name}');
      });
    }

    test('es determinista', () {
      const generator = SudokuGenerator();
      final a = generator.generate(SudokuDifficulty.medium, PuzzleSeed.fromKey('det').createRandom());
      final b = generator.generate(SudokuDifficulty.medium, PuzzleSeed.fromKey('det').createRandom());
      expect(a.givens, b.givens);
    });
  });
}
