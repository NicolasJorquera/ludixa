import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';

/// Puzzle de ejemplo de Wikipedia (el de las maquetas) y su solución.
const wikipediaPuzzle = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
const wikipediaSolution = '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

bool _isValidSolution(List<int> grid) {
  for (final unit in SudokuGrid.units) {
    final seen = {for (final i in unit) grid[i]};
    if (seen.length != 9 || seen.contains(0)) return false;
  }
  return true;
}

void main() {
  group('geometría', () {
    test('27 unidades de 9 celdas y 20 vecinas por celda', () {
      expect(SudokuGrid.units, hasLength(27));
      expect(SudokuGrid.units.every((u) => u.length == 9), isTrue);
      expect(SudokuGrid.peers.every((p) => p.length == 20), isTrue);
      expect(SudokuGrid.boxOf(40), 4);
      expect(SudokuGrid.boxOf(80), 8);
      expect(SudokuGrid.arePeers(0, 80), isFalse);
      expect(SudokuGrid.arePeers(0, 20), isTrue);
    });

    test('lee y escribe 81 caracteres', () {
      expect(formatGrid(parseGrid(wikipediaPuzzle)), wikipediaPuzzle);
      expect(parseGrid(wikipediaPuzzle.replaceAll('0', '.')), parseGrid(wikipediaPuzzle));
      expect(() => parseGrid('123'), throwsFormatException);
    });
  });

  group('BitSolver', () {
    test('resuelve el ejemplo de Wikipedia con su solución conocida', () {
      expect(formatGrid(BitSolver.solve(parseGrid(wikipediaPuzzle))!), wikipediaSolution);
      expect(BitSolver.countSolutions(parseGrid(wikipediaPuzzle)), 1);
    });

    test('detecta varias soluciones y puzzles imposibles', () {
      final empty = parseGrid('0' * 81);
      expect(BitSolver.countSolutions(empty), 2);
      final duplicated = parseGrid('11${'0' * 79}');
      expect(BitSolver.countSolutions(duplicated), 0);
      expect(BitSolver.solve(duplicated), isNull);
    });

    test('las grillas al azar son válidas y deterministas', () {
      for (var i = 0; i < 50; i++) {
        final a = BitSolver.randomSolution(Pcg32(i, 7));
        final b = BitSolver.randomSolution(Pcg32(i, 7));
        expect(_isValidSolution(a), isTrue);
        expect(a, b);
      }
      expect(BitSolver.randomSolution(Pcg32(1, 7)), isNot(BitSolver.randomSolution(Pcg32(2, 7))));
    });
  });

  group('RawGenerator', () {
    test('genera puzzles de solución única que coinciden con su solución', () {
      for (var i = 0; i < 200; i++) {
        final puzzle = RawGenerator.generate(Pcg32(i, 3));
        expect(BitSolver.countSolutions(puzzle.givens), 1, reason: 'semilla $i');
        expect(BitSolver.solve(puzzle.givens), puzzle.solution);
        for (var c = 0; c < 81; c++) {
          if (puzzle.givens[c] != 0) expect(puzzle.givens[c], puzzle.solution[c]);
        }
      }
    });

    test('las pistas son simétricas respecto del centro', () {
      for (var i = 0; i < 50; i++) {
        final g = RawGenerator.generate(Pcg32(i, 4)).givens;
        for (var c = 0; c < 81; c++) {
          expect(g[c] == 0, g[80 - c] == 0, reason: 'celda $c');
        }
      }
    });

    test('respeta el mínimo de pistas y el filtro adicional', () {
      final puzzle = RawGenerator.generate(Pcg32(9, 9), minGivens: 40);
      expect(puzzle.givenCount, greaterThanOrEqualTo(40));
      final untouched = RawGenerator.generate(Pcg32(9, 9), keep: (_) => false);
      expect(untouched.givenCount, 81);
    });

    test('es determinista', () {
      expect(RawGenerator.generate(Pcg32(5, 5)).givens, RawGenerator.generate(Pcg32(5, 5)).givens);
    });
  });
}
