import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'fixtures.dart';

/// Secuencias raras que no aparecen en los temas de prueba: el relleno nunca
/// debe formarlas.
const _blocklist = {'EAE', 'OEO', 'AOA', 'IUI'};

WordSearchPuzzle _generate(WordLanguage language, WordSearchDifficulty difficulty, int seed) =>
    const WordSearchGenerator().generate(
      themeWords: language == WordLanguage.spanish ? spanishFruits : englishFruits,
      language: language,
      difficulty: difficulty,
      random: PuzzleSeed.fromKey('sopa|${language.code}|${difficulty.name}|$seed').createRandom(),
      blocklist: _blocklist,
    );

void main() {
  group('normalización', () {
    test('español: sin tildes ni diéresis, conserva la Ñ', () {
      final es = WordLanguage.spanish;
      expect(es.normalize('Limón'), 'LIMON');
      expect(es.normalize('piña'), 'PIÑA');
      expect(es.normalize('Pingüino'), 'PINGUINO');
      expect(es.normalize('  maracuyá '), 'MARACUYA');
      expect(es.normalize('agua de coco'), isNull);
      expect(es.normalize('H2O'), isNull);
      expect(es.normalize(''), isNull);
    });

    test('inglés: A–Z, simplifica préstamos', () {
      final en = WordLanguage.english;
      expect(en.normalize('Café'), 'CAFE');
      expect(en.normalize('jalapeño'), 'JALAPENO');
      expect(en.normalize('ice-cream'), isNull);
    });

    test('la Ñ cuenta como una letra', () {
      expect(WordLanguage.lettersOf('PIÑA'), ['P', 'I', 'Ñ', 'A']);
    });
  });

  group('propiedades de la grilla', () {
    for (final language in WordLanguage.all) {
      for (final difficulty in WordSearchDifficulty.values) {
        test('${language.code} · ${difficulty.name}: 100 grillas válidas', () {
          for (var seed = 0; seed < 100; seed++) {
            final puzzle = _generate(language, difficulty, seed);
            final reason = 'semilla $seed';
            expect(puzzle.size, difficulty.size);
            expect(puzzle.letters, hasLength(difficulty.size * difficulty.size));
            expect(puzzle.letters.every(language.alphabet.contains), isTrue, reason: reason);
            expect(puzzle.placements, hasLength(difficulty.words));
            expect(puzzle.language, language.code);
            for (final p in puzzle.placements) {
              expect(difficulty.directions, contains(p.direction), reason: '$reason: ${p.word}');
              expect([for (final c in p.cells) puzzle.letters[c]].join(), p.word, reason: '$reason: ${p.word}');
              expect(WordScanner.count(puzzle.letters, puzzle.size, p.word), 1, reason: '$reason: ${p.word} repetida');
              expect(language.normalize(p.display), p.word);
            }
            for (final blocked in _blocklist) {
              expect(WordScanner.count(puzzle.letters, puzzle.size, blocked), 0, reason: '$reason: $blocked');
            }
            final words = puzzle.placements.map((p) => p.word).toList();
            for (final a in words) {
              for (final b in words) {
                if (a != b) expect(a.contains(b), isFalse, reason: '$reason: $a contiene $b');
              }
            }
          }
        });
      }
    }
  });

  test('desde el nivel Medio hay cruces entre palabras', () {
    var crossed = 0;
    for (var seed = 0; seed < 50; seed++) {
      final puzzle = _generate(WordLanguage.spanish, WordSearchDifficulty.hard, seed);
      final used = <int>{};
      var overlap = false;
      for (final p in puzzle.placements) {
        for (final c in p.cells) {
          if (!used.add(c)) overlap = true;
        }
      }
      if (overlap) crossed++;
    }
    expect(crossed, greaterThan(40));
  });

  test('Experto agrega señuelos: prefijos repetidos de las palabras buscadas', () {
    var decoys = 0;
    for (var seed = 0; seed < 50; seed++) {
      final puzzle = _generate(WordLanguage.spanish, WordSearchDifficulty.expert, seed);
      for (final p in puzzle.placements.where((p) => p.length >= 4)) {
        final prefix = WordLanguage.lettersOf(p.word).sublist(0, p.length - 1).join();
        if (WordScanner.count(puzzle.letters, puzzle.size, prefix) > 1) decoys++;
      }
    }
    expect(decoys, greaterThan(100));
  });

  test('es determinista', () {
    final a = _generate(WordLanguage.english, WordSearchDifficulty.medium, 7);
    final b = _generate(WordLanguage.english, WordSearchDifficulty.medium, 7);
    expect(a.toJson(), b.toJson());
  });

  test('falla con un mensaje claro si el tema no alcanza', () {
    expect(
      () => const WordSearchGenerator().generate(
        themeWords: const ['Uva', 'Pera', 'Kiwi'],
        language: WordLanguage.spanish,
        difficulty: WordSearchDifficulty.easy,
        random: Pcg32(1, 1),
      ),
      throwsArgumentError,
    );
  });

  test('el escáner cuenta una vez las palabras capicúa', () {
    // ANA en la fila 0: se lee igual en ambos sentidos sobre las mismas celdas.
    final letters = ['A', 'N', 'A', 'X', 'X', 'X', 'X', 'X', 'X'];
    expect(WordScanner.count(letters, 3, 'ANA'), 1);
  });
}
