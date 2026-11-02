import 'dart:typed_data';

import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:test/test.dart';

void main() {
  test('calcula los números de un tablero pequeño', () {
    // 3×3 con una mina en el centro: todas las demás tienen un 1.
    final layout = MineLayout(
      const BoardSpec(width: 3, height: 3, mines: 1),
      Uint8List.fromList([0, 0, 0, 0, 1, 0, 0, 0, 0]),
    );
    expect(layout.numbers.toList(), [1, 1, 1, 1, 0, 1, 1, 1, 1]);
    expect(layout.mineIndices.toList(), [4]);
  });

  test('las esquinas tienen 3 vecinas, los bordes 5 y el interior 8', () {
    final g = Geometry.of(4, 4);
    expect(g.neighbors[0].length, 3);
    expect(g.neighbors[1].length, 5);
    expect(g.neighbors[5].length, 8);
  });

  test('rechaza una cantidad de minas que no coincide', () {
    expect(
      () => MineLayout(const BoardSpec(width: 2, height: 1, mines: 1), Uint8List.fromList([1, 1])),
      throwsArgumentError,
    );
  });
}
