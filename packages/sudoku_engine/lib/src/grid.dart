import 'dart:typed_data';

/// Geometría del Sudoku 9×9. Las celdas se indexan como `fila * 9 + columna`.
abstract final class SudokuGrid {
  static const cellCount = 81;

  /// Máscara con los bits 1 a 9 encendidos (el bit d representa el dígito d).
  static const allDigits = 0x3FE;

  static int rowOf(int cell) => cell ~/ 9;

  static int columnOf(int cell) => cell % 9;

  static int boxOf(int cell) => (cell ~/ 27) * 3 + (cell % 9) ~/ 3;

  /// Las 27 unidades: filas 0–8, columnas 9–17 y cajas 18–26.
  static final List<Int8List> units = List.unmodifiable([
    for (var r = 0; r < 9; r++) Int8List.fromList([for (var c = 0; c < 9; c++) r * 9 + c]),
    for (var c = 0; c < 9; c++) Int8List.fromList([for (var r = 0; r < 9; r++) r * 9 + c]),
    for (var b = 0; b < 9; b++)
      Int8List.fromList([for (var k = 0; k < 9; k++) ((b ~/ 3) * 3 + k ~/ 3) * 9 + (b % 3) * 3 + k % 3]),
  ]);

  /// Para cada celda: índice de su fila, su columna y su caja en [units].
  static final List<Int8List> unitsOfCell = List.unmodifiable([
    for (var i = 0; i < cellCount; i++) Int8List.fromList([rowOf(i), 9 + columnOf(i), 18 + boxOf(i)]),
  ]);

  /// Las 20 celdas que comparten fila, columna o caja con cada celda.
  static final List<Int8List> peers = List.unmodifiable([
    for (var i = 0; i < cellCount; i++)
      Int8List.fromList(({for (final u in unitsOfCell[i]) ...units[u]}..remove(i)).toList()..sort()),
  ]);

  static bool arePeers(int a, int b) =>
      a != b && (rowOf(a) == rowOf(b) || columnOf(a) == columnOf(b) || boxOf(a) == boxOf(b));
}

/// Cantidad de bits encendidos.
int popCount(int mask) {
  var m = mask;
  var count = 0;
  while (m != 0) {
    m &= m - 1;
    count++;
  }
  return count;
}

/// Dígitos presentes en una máscara, de menor a mayor.
List<int> digitsOf(int mask) => [
  for (var d = 1; d <= 9; d++)
    if (mask & (1 << d) != 0) d,
];

/// Lee un Sudoku de 81 caracteres (`0` o `.` para vacío).
Uint8List parseGrid(String text) {
  final clean = text.replaceAll(RegExp(r'\s'), '');
  if (clean.length != SudokuGrid.cellCount) throw FormatException('Se esperaban 81 celdas', text);
  return Uint8List.fromList([
    for (final ch in clean.split(''))
      if (ch == '.' || ch == '0') 0 else int.parse(ch),
  ]);
}

/// Escribe un Sudoku como 81 caracteres con `0` para vacío.
String formatGrid(List<int> grid) => grid.join();
