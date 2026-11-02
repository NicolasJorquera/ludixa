import 'dart:typed_data';

import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

MineLayout _layout(int width, int height, List<int> mines) => MineLayout(
  BoardSpec(width: width, height: height, mines: mines.where((m) => m == 1).length),
  Uint8List.fromList(mines),
);

void main() {
  group('casos mínimos', () {
    // [_, _, M]: desde la celda 0 se abre la zona y el conteo global marca la mina.
    final solvable = _layout(3, 1, [0, 0, 1]);
    // [M, s, _]: el 1 del centro deja un 50/50 entre los extremos.
    final fiftyFifty = _layout(3, 1, [1, 0, 0]);

    test('el solver por reglas resuelve el caso deducible y se atasca en el 50/50', () {
      expect(const RuleSolver().solve(solvable, 0), isTrue);
      expect(const RuleSolver().solve(fiftyFifty, 1), isFalse);
    });

    test('el verificador exacto coincide', () {
      expect(const ExactSolver().solve(solvable, 0), ExactOutcome.solved);
      expect(const ExactSolver().solve(fiftyFifty, 1), ExactOutcome.stuck);
    });
  });

  group('solidez en tableros aleatorios', () {
    // Ningún solver puede deducir algo falso: si lo hiciera, SolveState lanza
    // UnsoundDeduction y la prueba falla. Se prueba en tableros al azar,
    // resolubles o no, desde una celda sin mina.
    for (final spec in [BoardSpec.beginner, BoardSpec.intermediate]) {
      test('$spec, 500 tableros', () {
        for (var seed = 0; seed < 500; seed++) {
          final rng = Pcg32(seed, 99);
          final cells = List<int>.generate(spec.cellCount, (i) => i);
          rng.shuffle(cells);
          final mines = Uint8List(spec.cellCount);
          for (var k = 0; k < spec.mines; k++) {
            mines[cells[k]] = 1;
          }
          final layout = MineLayout(spec, mines);
          final start = cells[spec.mines];
          final byRules = const RuleSolver().solve(layout, start);
          final exact = const ExactSolver().solve(layout, start);
          // El exacto es al menos tan fuerte como las reglas.
          if (byRules) expect(exact, ExactOutcome.solved, reason: 'semilla $seed');
        }
      });
    }
  });
}
