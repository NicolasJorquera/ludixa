import 'geometry.dart';

/// Una palabra colocada en la grilla.
final class WordPlacement {
  const WordPlacement({
    required this.word,
    required this.display,
    required this.start,
    required this.direction,
    required this.length,
    required this.size,
  });

  /// Forma normalizada (la que está en la grilla).
  final String word;

  /// Ortografía real para la lista ("LIMÓN").
  final String display;

  /// Celda inicial (`fila * size + columna`).
  final int start;
  final WordDirection direction;
  final int length;
  final int size;

  int get end => cellAt(length - 1);

  int cellAt(int k) => (start ~/ size + direction.dRow * k) * size + (start % size + direction.dColumn * k);

  List<int> get cells => [for (var k = 0; k < length; k++) cellAt(k)];

  Map<String, Object?> toJson() => {
    'word': word,
    'display': display,
    'start': start,
    'dir': direction.name,
    'len': length,
  };

  static WordPlacement fromJson(Map<String, Object?> json, int size) => WordPlacement(
    word: json['word']! as String,
    display: json['display']! as String,
    start: json['start']! as int,
    direction: WordDirection.values.byName(json['dir']! as String),
    length: json['len']! as int,
    size: size,
  );
}

/// Sopa de letras generada.
final class WordSearchPuzzle {
  const WordSearchPuzzle({
    required this.size,
    required this.letters,
    required this.placements,
    required this.language,
    required this.difficulty,
  });

  final int size;

  /// Letra de cada celda (`fila * size + columna`).
  final List<String> letters;
  final List<WordPlacement> placements;

  /// Código del idioma de las palabras ("es", "en").
  final String language;
  final WordSearchDifficulty difficulty;

  String letterAt(int row, int column) => letters[row * size + column];

  Map<String, Object?> toJson() => {
    'size': size,
    'letters': letters.join(),
    'placements': [for (final p in placements) p.toJson()],
    'lang': language,
    'difficulty': difficulty.name,
  };

  static WordSearchPuzzle fromJson(Map<String, Object?> json) {
    final size = json['size']! as int;
    final letters = [for (final r in (json['letters']! as String).runes) String.fromCharCode(r)];
    if (letters.length != size * size) throw const FormatException('Cantidad de letras inválida');
    return WordSearchPuzzle(
      size: size,
      letters: letters,
      placements: [
        for (final p in json['placements']! as List) WordPlacement.fromJson((p as Map).cast<String, Object?>(), size),
      ],
      language: json['lang']! as String,
      difficulty: WordSearchDifficulty.values.byName(json['difficulty']! as String),
    );
  }
}
