import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';

void main() {
  test('primero señala un número equivocado del jugador', () {
    final puzzle = const SudokuGenerator().generate(SudokuDifficulty.easy, Pcg32(3, 3));
    final values = List<int>.of(puzzle.givens);
    final empty = values.indexOf(0);
    values[empty] = puzzle.solution[empty] % 9 + 1; // cualquier dígito distinto
    final hint = SudokuHinter.hint(values, puzzle.solution)!;
    expect(hint.isError, isTrue);
    expect(hint.errorCell, empty);
  });

  test('sin errores, nunca propone un valor incorrecto y siempre explica la técnica', () {
    for (final level in SudokuDifficulty.values) {
      for (var i = 0; i < 10; i++) {
        final SudokuPuzzle puzzle;
        try {
          puzzle = const SudokuGenerator().generate(level, PuzzleSeed.fromKey('pista|${level.name}|$i').createRandom());
        } on SudokuGenerationFailed {
          continue;
        }
        final hint = SudokuHinter.hint(puzzle.givens, puzzle.solution)!;
        expect(hint.isError, isFalse);
        expect(hint.digit, puzzle.solution[hint.cell!]);
        expect(hint.technique, isNotNull);
        expect(hint.pattern, isNotEmpty);
      }
    }
  });

  test('seguir solo las pistas completa el puzzle en todos los niveles', () {
    for (final level in SudokuDifficulty.values) {
      for (var i = 0; i < 8; i++) {
        final SudokuPuzzle puzzle;
        try {
          puzzle = const SudokuGenerator().generate(level, PuzzleSeed.fromKey('solo|${level.name}|$i').createRandom());
        } on SudokuGenerationFailed {
          continue;
        }
        final values = List<int>.of(puzzle.givens);
        var hints = 0;
        while (values.contains(0)) {
          final hint = SudokuHinter.hint(values, puzzle.solution)!;
          expect(hint.technique, isNotNull, reason: 'no debería hacer falta revelar sin deducción');
          values[hint.cell!] = hint.digit!;
          hints++;
        }
        expect(values, puzzle.solution);
        expect(hints, puzzle.givens.where((d) => d == 0).length);
      }
    }
  });

  test('con la grilla completa no hay pista', () {
    final puzzle = const SudokuGenerator().generate(SudokuDifficulty.easy, Pcg32(4, 4));
    expect(SudokuHinter.hint(puzzle.solution, puzzle.solution), isNull);
  });
}
