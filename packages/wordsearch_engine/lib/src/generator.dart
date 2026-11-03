import 'package:puzzle_core/puzzle_core.dart';

import 'geometry.dart';
import 'language.dart';
import 'puzzle.dart';

/// No se logró una grilla válida en los intentos disponibles.
final class WordSearchGenerationFailed implements Exception {
  WordSearchGenerationFailed(this.difficulty, this.attempts);

  final WordSearchDifficulty difficulty;
  final int attempts;

  @override
  String toString() => 'WordSearchGenerationFailed: ${difficulty.name} tras $attempts intentos';
}

/// Busca palabras en una grilla en las 8 direcciones.
abstract final class WordScanner {
  /// Apariciones distintas de [word]. Una palabra capicúa leída en ambos
  /// sentidos sobre las mismas celdas cuenta una sola vez.
  static int count(List<String> letters, int size, String word) {
    final target = WordLanguage.lettersOf(word);
    final seen = <String>{};
    for (var start = 0; start < letters.length; start++) {
      if (letters[start] != target.first) continue;
      final row = start ~/ size;
      final column = start % size;
      for (final d in WordDirection.values) {
        final endRow = row + d.dRow * (target.length - 1);
        final endColumn = column + d.dColumn * (target.length - 1);
        if (endRow < 0 || endRow >= size || endColumn < 0 || endColumn >= size) continue;
        var match = true;
        for (var k = 1; k < target.length && match; k++) {
          match = letters[(row + d.dRow * k) * size + column + d.dColumn * k] == target[k];
        }
        if (!match) continue;
        final cells = [for (var k = 0; k < target.length; k++) (row + d.dRow * k) * size + column + d.dColumn * k]
          ..sort();
        seen.add(cells.join(','));
      }
    }
    return seen.length;
  }
}

/// Genera sopas de letras validadas.
///
/// 1. Elige palabras del tema que no se contienen entre sí (ni al revés).
/// 2. Las coloca de la más larga a la más corta en las direcciones del nivel,
///    favoreciendo cruces desde el nivel Medio.
/// 3. En Experto agrega señuelos: prefijos de palabras buscadas.
/// 4. Rellena con letras ponderadas por la frecuencia del idioma.
/// 5. Valida que cada palabra aparezca exactamente una vez y que ninguna
///    palabra bloqueada aparezca en ninguna dirección; si no, rellena de nuevo
///    o reintenta.
final class WordSearchGenerator {
  const WordSearchGenerator({this.maxAttempts = 40, this.refillsPerAttempt = 6});

  /// Versión del algoritmo; forma parte de la semilla del reto diario.
  static const int version = 1;

  final int maxAttempts;
  final int refillsPerAttempt;

  WordSearchPuzzle generate({
    required List<String> themeWords,
    required WordLanguage language,
    required WordSearchDifficulty difficulty,
    required Pcg32 random,
    Set<String> blocklist = const {},
  }) {
    final size = difficulty.size;
    final candidates = <({String display, String word})>[];
    final seenWords = <String>{};
    for (final display in themeWords) {
      final word = language.normalize(display);
      if (word == null || word.runes.length < 3 || word.runes.length > size || !seenWords.add(word)) continue;
      candidates.add((display: display.trim().toUpperCase(), word: word));
    }
    final blocked = {for (final b in blocklist) ?language.normalize(b)};

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final chosen = _choose(candidates, difficulty.words, random);
      final grid = List<String?>.filled(size * size, null);
      final placements = <WordPlacement>[];
      var placedAll = true;
      for (final entry in chosen) {
        final placement = _place(entry.word, entry.display, grid, size, difficulty, random);
        if (placement == null) {
          placedAll = false;
          break;
        }
        placements.add(placement);
      }
      if (!placedAll) continue;
      if (difficulty.usesDecoys) _placeDecoys(chosen.map((e) => e.word).toList(), grid, size, random);

      for (var refill = 0; refill < refillsPerAttempt; refill++) {
        final letters = [for (final cell in grid) cell ?? _randomLetter(language, random)];
        final valid =
            placements.every((p) => WordScanner.count(letters, size, p.word) == 1) &&
            blocked.every((b) => WordScanner.count(letters, size, b) == 0);
        if (valid) {
          return WordSearchPuzzle(
            size: size,
            letters: letters,
            placements: placements,
            language: language.code,
            difficulty: difficulty,
          );
        }
      }
    }
    throw WordSearchGenerationFailed(difficulty, maxAttempts);
  }

  /// Elige [count] palabras al azar, sin que ninguna contenga a otra en ningún
  /// sentido (si no, la más corta aparecería dos veces).
  List<({String display, String word})> _choose(
    List<({String display, String word})> candidates,
    int count,
    Pcg32 random,
  ) {
    final pool = List.of(candidates);
    random.shuffle(pool);
    final chosen = <({String display, String word})>[];
    for (final entry in pool) {
      final reversed = WordLanguage.lettersOf(entry.word).reversed.join();
      final conflicts = chosen.any(
        (c) =>
            c.word.contains(entry.word) ||
            entry.word.contains(c.word) ||
            c.word.contains(reversed) ||
            reversed.contains(c.word),
      );
      if (!conflicts) chosen.add(entry);
      if (chosen.length == count) break;
    }
    if (chosen.length < count) {
      throw ArgumentError('El tema no tiene $count palabras válidas e independientes (hay ${chosen.length})');
    }
    chosen.sort((a, b) => b.word.runes.length.compareTo(a.word.runes.length));
    return chosen;
  }

  WordPlacement? _place(
    String word,
    String display,
    List<String?> grid,
    int size,
    WordSearchDifficulty difficulty,
    Pcg32 random,
  ) {
    final letters = WordLanguage.lettersOf(word);
    final options = <({int start, WordDirection direction, int overlaps})>[];
    for (var start = 0; start < grid.length; start++) {
      final row = start ~/ size;
      final column = start % size;
      for (final d in difficulty.directions) {
        final endRow = row + d.dRow * (letters.length - 1);
        final endColumn = column + d.dColumn * (letters.length - 1);
        if (endRow < 0 || endRow >= size || endColumn < 0 || endColumn >= size) continue;
        var overlaps = 0;
        var fits = true;
        for (var k = 0; k < letters.length && fits; k++) {
          final existing = grid[(row + d.dRow * k) * size + column + d.dColumn * k];
          if (existing == null) continue;
          if (existing == letters[k]) {
            overlaps++;
          } else {
            fits = false;
          }
        }
        // Una palabra completamente superpuesta a otra no aporta nada.
        if (fits && overlaps < letters.length) options.add((start: start, direction: d, overlaps: overlaps));
      }
    }
    if (options.isEmpty) return null;
    random.shuffle(options);
    var pick = options.first;
    if (difficulty != WordSearchDifficulty.easy) {
      // Entre algunas opciones al azar, la que más cruza.
      for (final option in options.take(24)) {
        if (option.overlaps > pick.overlaps) pick = option;
      }
    }
    final placement = WordPlacement(
      word: word,
      display: display,
      start: pick.start,
      direction: pick.direction,
      length: letters.length,
      size: size,
    );
    for (var k = 0; k < letters.length; k++) {
      grid[placement.cellAt(k)] = letters[k];
    }
    return placement;
  }

  /// Prefijos de palabras buscadas en celdas libres, para despistar.
  void _placeDecoys(List<String> words, List<String?> grid, int size, Pcg32 random) {
    final pool = List.of(words);
    random.shuffle(pool);
    for (final word in pool.take(words.length ~/ 2)) {
      final letters = WordLanguage.lettersOf(word);
      if (letters.length < 4) continue;
      final prefix = letters.sublist(0, letters.length - 1);
      final options = <(int, WordDirection)>[];
      for (var start = 0; start < grid.length; start++) {
        final row = start ~/ size;
        final column = start % size;
        for (final d in WordDirection.values) {
          final endRow = row + d.dRow * (prefix.length - 1);
          final endColumn = column + d.dColumn * (prefix.length - 1);
          if (endRow < 0 || endRow >= size || endColumn < 0 || endColumn >= size) continue;
          var free = true;
          for (var k = 0; k < prefix.length && free; k++) {
            free = grid[(row + d.dRow * k) * size + column + d.dColumn * k] == null;
          }
          if (free) options.add((start, d));
        }
      }
      if (options.isEmpty) continue;
      final (start, d) = random.pick(options);
      for (var k = 0; k < prefix.length; k++) {
        grid[(start ~/ size + d.dRow * k) * size + start % size + d.dColumn * k] = prefix[k];
      }
    }
  }

  String _randomLetter(WordLanguage language, Pcg32 random) {
    final total = language.letterWeights.values.fold(0, (a, b) => a + b);
    var roll = random.nextInt(total);
    for (final entry in language.letterWeights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return language.letterWeights.keys.first;
  }
}
