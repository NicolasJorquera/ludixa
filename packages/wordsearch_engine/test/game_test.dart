import 'dart:convert';

import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'fixtures.dart';

WordSearchGame _game([int seed = 1, WordSearchDifficulty difficulty = WordSearchDifficulty.hard]) => WordSearchGame(
  const WordSearchGenerator().generate(
    themeWords: spanishFruits,
    language: WordLanguage.spanish,
    difficulty: difficulty,
    random: Pcg32(seed, 5),
  ),
);

void main() {
  test('seleccionar una palabra en su sentido o al revés la encuentra', () {
    final game = _game();
    final first = game.puzzle.placements[0];
    final second = game.puzzle.placements[1];
    expect(game.select(first.start, first.end), (outcome: SelectionOutcome.found, wordIndex: 0));
    expect(game.select(second.end, second.start), (outcome: SelectionOutcome.found, wordIndex: 1));
    expect(game.foundOrder, [0, 1]);
    expect(game.isFound(0), isTrue);
  });

  test('repetir una palabra encontrada no la cuenta dos veces', () {
    final game = _game();
    final p = game.puzzle.placements[0];
    game.select(p.start, p.end);
    expect(game.select(p.start, p.end).outcome, SelectionOutcome.alreadyFound);
    expect(game.foundOrder, [0]);
  });

  test('una selección que no es recta, es parcial o es una sola letra no cuenta', () {
    final game = _game();
    final size = game.puzzle.size;
    final p = game.puzzle.placements.firstWhere((p) => p.length >= 4);
    expect(game.select(p.start, p.cellAt(p.length - 2)).outcome, SelectionOutcome.miss);
    expect(game.select(p.start, p.start).outcome, SelectionOutcome.miss);
    // De (0,0) a (1,2): no es horizontal, vertical ni diagonal.
    expect(game.lineBetween(0, size + 2), isEmpty);
    expect(game.select(0, size + 2).outcome, SelectionOutcome.miss);
  });

  test('lineBetween devuelve las celdas intermedias en las 8 direcciones', () {
    final game = _game();
    final size = game.puzzle.size;
    expect(game.lineBetween(0, 3), [0, 1, 2, 3]);
    expect(game.lineBetween(3, 0), [3, 2, 1, 0]);
    expect(game.lineBetween(0, 2 * size + 2), [0, size + 1, 2 * size + 2]);
    expect(game.lineBetween(2 * size, 2), [2 * size, size + 1, 2]);
  });

  test('encontrar todas las palabras completa la partida', () {
    final game = _game();
    for (final p in game.puzzle.placements) {
      expect(game.isComplete, isFalse);
      game.select(p.start, p.end);
    }
    expect(game.isComplete, isTrue);
    expect(game.remaining, 0);
    expect(game.hint(), isNull);
  });

  test('la pista señala la primera letra y la siguiente de una palabra pendiente', () {
    final game = _game();
    final p0 = game.puzzle.placements[0];
    game.select(p0.start, p0.end);
    final hint = game.hint()!;
    final target = game.puzzle.placements[hint.wordIndex];
    expect(game.isFound(hint.wordIndex), isFalse);
    expect(hint.startCell, target.start);
    expect(hint.nextCell, target.cellAt(1));
  });

  test('guardado de ida y vuelta conserva la grilla y lo encontrado', () {
    final game = _game(3, WordSearchDifficulty.expert);
    final p = game.puzzle.placements[2];
    game.select(p.end, p.start);
    final copy = WordSearchGame.fromJson(jsonDecode(jsonEncode(game.toJson())) as Map<String, Object?>);
    expect(copy.toJson(), game.toJson());
    expect(copy.foundOrder, [2]);
    final q = copy.puzzle.placements[0];
    expect(copy.select(q.start, q.end).outcome, SelectionOutcome.found);
  });

  test('el guardado conserva la Ñ y rechaza versiones desconocidas', () {
    WordSearchGame? withEnye;
    for (var seed = 0; seed < 40 && withEnye == null; seed++) {
      final game = _game(seed, WordSearchDifficulty.expert);
      if (game.puzzle.letters.contains('Ñ')) withEnye = game;
    }
    expect(withEnye, isNotNull);
    final copy = WordSearchGame.fromJson(jsonDecode(jsonEncode(withEnye!.toJson())) as Map<String, Object?>);
    expect(copy.puzzle.letters, withEnye.puzzle.letters);
    expect(() => WordSearchGame.fromJson({...withEnye!.toJson(), 'v': 9}), throwsFormatException);
  });
}
