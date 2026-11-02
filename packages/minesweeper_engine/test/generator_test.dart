import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

void main() {
  const generator = NoGuessGenerator();

  group('propiedades del tablero generado', () {
    final cases = <(BoardSpec, int)>[(BoardSpec.beginner, 300), (BoardSpec.intermediate, 150), (BoardSpec.expert, 40)];
    for (final (spec, count) in cases) {
      test('$spec: $count tableros resolubles sin adivinar según el verificador exacto', () {
        for (var i = 0; i < count; i++) {
          final rng = PuzzleSeed.fromKey('test|$spec|$i').createRandom();
          final start = rng.nextInt(spec.cellCount);
          final board = generator.generate(spec, rng, start);
          final layout = board.layout;

          expect(layout.mineIndices.length, spec.mines);
          expect(layout.isMine(start), isFalse);
          expect(layout.geometry.neighbors[start].any(layout.isMine), isFalse, reason: 'la zona de inicio tiene mina');
          expect(layout.numbers[start], 0, reason: 'el primer toque debe abrir una zona');
          expect(const ExactSolver().solve(layout, start), ExactOutcome.solved, reason: 'tablero $i exige adivinar');
        }
      });
    }
  });

  test('es determinista: misma semilla y misma celda, mismo tablero', () {
    for (var i = 0; i < 20; i++) {
      final a = generator.generate(BoardSpec.intermediate, PuzzleSeed.fromKey('det|$i').createRandom(), 100);
      final b = generator.generate(BoardSpec.intermediate, PuzzleSeed.fromKey('det|$i').createRandom(), 100);
      expect(a.layout.toBytes(), b.layout.toBytes());
      expect(a.attempts, b.attempts);
    }
  });

  test('el reto diario es igual para todos e incluye la celda de inicio', () {
    final seed = PuzzleSeed.daily(
      day: LocalDay(2026, 11, 2),
      game: GameId.minesweeper,
      generatorVersion: NoGuessGenerator.version,
    );
    final a = generator.generateDaily(BoardSpec.beginner, seed);
    final b = generator.generateDaily(BoardSpec.beginner, PuzzleSeed.fromKey(seed.key));
    expect(a.start, b.start);
    expect(a.layout.toBytes(), b.layout.toBytes());
  });

  test('falla con un mensaje claro si no caben las minas', () {
    expect(
      () => generator.generate(const BoardSpec(width: 3, height: 3, mines: 1), Pcg32(1, 1), 4),
      throwsArgumentError,
    );
  });
}
