/// Identificador estable de un juego. Se guarda en la base de datos y forma
/// parte de las semillas, así que un valor publicado no se cambia nunca.
extension type const GameId(String value) {
  static const sudoku = GameId('sudoku');
  static const minesweeper = GameId('minesweeper');
  static const wordSearch = GameId('wordsearch');
}

/// Identificador estable de una dificultad. Cada juego define las suyas
/// (por ejemplo `easy` en Sudoku, `beginner` en Buscaminas).
extension type const Difficulty(String value) {}

/// Origen de una partida.
enum PuzzleMode {
  /// Partida elegida libremente desde el catálogo.
  free,

  /// Reto del día actual: cuenta para la racha.
  daily,

  /// Reto de un día pasado jugado desde el archivo: no cuenta para la racha.
  archive,
}
