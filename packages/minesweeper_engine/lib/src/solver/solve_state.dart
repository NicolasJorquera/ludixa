import 'dart:typed_data';

import '../layout.dart';

/// Estado de una celda durante la resolución simulada.
abstract final class CellStatus {
  static const int unknown = -1;
  static const int flagged = -2;
  // Los valores >= 0 son celdas reveladas con su número.
}

/// Un solver dedujo algo falso. Siempre es un error de programación.
final class UnsoundDeduction implements Exception {
  UnsoundDeduction(this.message);

  final String message;

  @override
  String toString() => 'UnsoundDeduction: $message';
}

/// Lo que sabe un jugador que solo deduce: celdas reveladas y banderas seguras.
///
/// La disposición real solo se consulta para revelar el número de una celda,
/// igual que en el juego. Revelar una mina o marcar una celda libre lanza
/// [UnsoundDeduction].
final class SolveState {
  SolveState(this.layout)
    : status = Int8List(layout.spec.cellCount)..fillRange(0, layout.spec.cellCount, CellStatus.unknown),
      unknownCount = layout.spec.cellCount;

  final MineLayout layout;
  final Int8List status;
  int unknownCount;
  int flaggedCount = 0;

  Geometry get geometry => layout.geometry;

  bool get isSolved => unknownCount == 0;

  int get remainingMines => layout.spec.mines - flaggedCount;

  /// Revela [index] y abre en cascada las zonas con 0.
  void reveal(int index) {
    if (status[index] != CellStatus.unknown) return;
    if (layout.isMine(index)) throw UnsoundDeduction('se reveló la mina $index');
    final stack = <int>[index];
    while (stack.isNotEmpty) {
      final i = stack.removeLast();
      if (status[i] != CellStatus.unknown) continue;
      final n = layout.numbers[i];
      status[i] = n;
      unknownCount--;
      if (n == 0) {
        for (final j in geometry.neighbors[i]) {
          if (status[j] == CellStatus.unknown) stack.add(j);
        }
      }
    }
  }

  void flag(int index) {
    if (status[index] != CellStatus.unknown) return;
    if (!layout.isMine(index)) throw UnsoundDeduction('se marcó como mina la celda libre $index');
    status[index] = CellStatus.flagged;
    unknownCount--;
    flaggedCount++;
  }
}
