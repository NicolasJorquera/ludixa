/// Las 8 direcciones de lectura.
enum WordDirection {
  right(0, 1),
  down(1, 0),
  downRight(1, 1),
  upRight(-1, 1),
  left(0, -1),
  up(-1, 0),
  upLeft(-1, -1),
  downLeft(1, -1);

  const WordDirection(this.dRow, this.dColumn);

  final int dRow;
  final int dColumn;

  WordDirection get reversed => switch (this) {
    right => left,
    left => right,
    down => up,
    up => down,
    downRight => upLeft,
    upLeft => downRight,
    upRight => downLeft,
    downLeft => upRight,
  };

  /// Dirección exacta de (dRow, dColumn) normalizados, o null si no es recta.
  static WordDirection? between(int fromRow, int fromColumn, int toRow, int toColumn) {
    final dr = toRow - fromRow;
    final dc = toColumn - fromColumn;
    if (dr == 0 && dc == 0) return null;
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) return null;
    final sr = dr.sign;
    final sc = dc.sign;
    return values.firstWhere((d) => d.dRow == sr && d.dColumn == sc);
  }
}

/// Niveles de dificultad de la Sopa (PRD).
enum WordSearchDifficulty {
  easy(size: 8, words: 6, directions: [WordDirection.right, WordDirection.down]),
  medium(
    size: 10,
    words: 9,
    directions: [WordDirection.right, WordDirection.down, WordDirection.downRight, WordDirection.upRight],
  ),
  hard(size: 12, words: 12, directions: WordDirection.values),

  /// Además coloca señuelos: prefijos de las palabras buscadas.
  expert(size: 14, words: 15, directions: WordDirection.values);

  const WordSearchDifficulty({required this.size, required this.words, required this.directions});

  final int size;
  final int words;
  final List<WordDirection> directions;

  bool get usesDecoys => this == expert;
}
