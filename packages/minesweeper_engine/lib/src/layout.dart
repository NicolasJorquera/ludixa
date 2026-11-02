import 'dart:typed_data';

/// Dimensiones y cantidad de minas de un tablero.
final class BoardSpec {
  const BoardSpec({required this.width, required this.height, required this.mines});

  static const beginner = BoardSpec(width: 9, height: 9, mines: 10);
  static const intermediate = BoardSpec(width: 16, height: 16, mines: 40);

  /// Experto clásico (30×16) girado a vertical para el teléfono.
  static const expert = BoardSpec(width: 16, height: 30, mines: 99);

  final int width;
  final int height;
  final int mines;

  int get cellCount => width * height;

  @override
  String toString() => '${width}x$height/$mines';
}

/// Vecindad precalculada de una grilla. Las celdas se indexan como `fila * ancho + columna`.
final class Geometry {
  Geometry._(this.width, this.height, this.neighbors);

  factory Geometry.of(int width, int height) => _cache.putIfAbsent((width, height), () => _build(width, height));

  static final _cache = <(int, int), Geometry>{};

  static Geometry _build(int width, int height) {
    final neighbors = List<Int32List>.generate(width * height, (i) {
      final r = i ~/ width;
      final c = i % width;
      final out = <int>[];
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = r + dr;
          final nc = c + dc;
          if (nr >= 0 && nr < height && nc >= 0 && nc < width) out.add(nr * width + nc);
        }
      }
      return Int32List.fromList(out);
    }, growable: false);
    return Geometry._(width, height, neighbors);
  }

  final int width;
  final int height;

  /// Vecinas de cada celda (de 3 a 8).
  final List<Int32List> neighbors;

  int get cellCount => width * height;
}

/// Disposición de minas de un tablero, con los números ya calculados.
final class MineLayout {
  MineLayout(this.spec, Uint8List mines) : _mines = mines, geometry = Geometry.of(spec.width, spec.height) {
    if (mines.length != spec.cellCount) {
      throw ArgumentError('Se esperaban ${spec.cellCount} celdas y llegaron ${mines.length}');
    }
    var count = 0;
    for (final m in mines) {
      if (m != 0 && m != 1) throw ArgumentError('Las celdas deben ser 0 o 1');
      count += m;
    }
    if (count != spec.mines) throw ArgumentError('Se esperaban ${spec.mines} minas y hay $count');
    numbers = Int8List(spec.cellCount);
    for (var i = 0; i < spec.cellCount; i++) {
      var n = 0;
      for (final j in geometry.neighbors[i]) {
        n += mines[j];
      }
      numbers[i] = n;
    }
  }

  final BoardSpec spec;
  final Geometry geometry;
  final Uint8List _mines;

  /// Cantidad de minas vecinas de cada celda (también definida en las celdas con mina).
  late final Int8List numbers;

  bool isMine(int index) => _mines[index] == 1;

  Iterable<int> get mineIndices sync* {
    for (var i = 0; i < _mines.length; i++) {
      if (_mines[i] == 1) yield i;
    }
  }

  /// Copia de las minas, para serializar.
  Uint8List toBytes() => Uint8List.fromList(_mines);
}
