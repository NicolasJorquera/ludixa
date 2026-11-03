import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

/// Mayor conjunto (voraz) de palabras del tema que caben en la grilla y no se
/// contienen entre sí: lo que el generador puede elegir.
int _independentCapacity(List<String> words, int size) {
  final sorted = words.where((w) => w.runes.length <= size).toList()
    ..sort((a, b) => a.runes.length.compareTo(b.runes.length));
  final chosen = <String>[];
  for (final word in sorted) {
    final reversed = WordLanguage.lettersOf(word).reversed.join();
    if (chosen.any((c) => word.contains(c) || word.contains(WordLanguage.lettersOf(c).reversed.join()))) continue;
    if (chosen.any((c) => c.contains(word) || c.contains(reversed))) continue;
    chosen.add(word);
  }
  return chosen.length;
}

void main() {
  for (final language in WordLanguage.all) {
    final code = language.code;
    final themes = WordBanks.themes(code);
    final blocked = {for (final b in WordBanks.blocklist(code)) language.normalize(b)};

    group('banco $code', () {
      test('20 temas con identificadores únicos y más de 1.200 palabras', () {
        expect(themes, hasLength(20));
        expect(themes.map((t) => t.id).toSet(), hasLength(20));
        expect(themes.fold(0, (sum, t) => sum + t.words.length), greaterThanOrEqualTo(1200));
        for (final t in themes) {
          expect(t.name.trim(), isNotEmpty);
          expect(WordBanks.theme(code, t.id), same(t));
        }
      });

      test('cada palabra se normaliza, mide entre 3 y 14 letras y no se repite en su tema', () {
        for (final t in themes) {
          final seen = <String>{};
          for (final w in t.words) {
            final n = language.normalize(w);
            expect(n, isNotNull, reason: '${t.id}: "$w" no se normaliza');
            expect(n!.runes.length, inInclusiveRange(3, 14), reason: '${t.id}: "$w"');
            expect(seen.add(n), isTrue, reason: '${t.id}: "$w" repetida');
          }
        }
      });

      test('la lista bloqueada se normaliza y ninguna palabra de tema está bloqueada', () {
        expect(blocked, isNot(contains(null)));
        for (final t in themes) {
          for (final w in t.words) {
            expect(blocked, isNot(contains(language.normalize(w))), reason: '${t.id}: "$w"');
          }
        }
      });

      test('cada tema tiene el doble de palabras independientes que pide cada nivel', () {
        for (final t in themes) {
          final words = {for (final w in t.words) language.normalize(w)!}.toList();
          for (final d in WordSearchDifficulty.values) {
            expect(_independentCapacity(words, d.size), greaterThanOrEqualTo(d.words * 2), reason: '${t.id} ${d.name}');
          }
        }
      });

      test('todos los temas generan grillas válidas en todos los niveles', () {
        const generator = WordSearchGenerator();
        for (final t in themes) {
          for (final d in WordSearchDifficulty.values) {
            for (var seed = 0; seed < 5; seed++) {
              final puzzle = generator.generate(
                themeWords: t.words,
                language: language,
                difficulty: d,
                random: PuzzleSeed.fromKey('banco|$code|${t.id}|${d.name}|$seed').createRandom(),
                blocklist: WordBanks.blocklist(code),
              );
              for (final b in blocked) {
                expect(
                  WordScanner.strayCount(puzzle.letters, puzzle.size, b!, puzzle.placements),
                  0,
                  reason: '${t.id} ${d.name} $seed: $b',
                );
              }
            }
          }
        }
      });
    });
  }

  test('desconocidos: idioma y tema fallan con un error claro', () {
    expect(() => WordBanks.themes('fr'), throwsArgumentError);
    expect(() => WordBanks.blocklist('fr'), throwsArgumentError);
    expect(() => WordBanks.theme('es', 'nada'), throwsArgumentError);
  });

  test('una palabra bloqueada dentro de una palabra buscada se permite; suelta, no', () {
    // Fila 0: BASS (palabra buscada, contiene ASS). Fila 1: ASS suelto.
    const size = 4;
    final letters = 'BASSASSXXXXXXXXX'.split('');
    final bass = WordPlacement(
      word: 'BASS',
      display: 'BASS',
      start: 0,
      direction: WordDirection.right,
      length: 4,
      size: size,
    );
    expect(WordScanner.count(letters, size, 'ASS'), 2);
    expect(WordScanner.strayCount(letters, size, 'ASS', [bass]), 1);
    expect(WordScanner.strayCount(letters, size, 'ASS', []), 2);
  });
}
