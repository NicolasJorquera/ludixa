import 'dart:math';

import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

List<int> _firstOutputs(PuzzleSeed seed, [int n = 8]) {
  final rng = seed.createRandom();
  return List<int>.generate(n, (_) => rng.nextUint32());
}

void main() {
  final day = LocalDay(2026, 11, 2);

  group('PuzzleSeed.daily', () {
    test('la clave contiene fecha, juego, versión e idioma', () {
      final seed = PuzzleSeed.daily(day: day, game: GameId.wordSearch, generatorVersion: 1, wordsLanguage: 'es');
      expect(seed.key, 'daily|2026-11-02|wordsearch|v1|es');
    });

    test('omite el idioma cuando el juego no lo usa', () {
      final seed = PuzzleSeed.daily(day: day, game: GameId.sudoku, generatorVersion: 3);
      expect(seed.key, 'daily|2026-11-02|sudoku|v3');
    });

    test('la misma clave produce la misma secuencia', () {
      final a = PuzzleSeed.daily(day: day, game: GameId.sudoku, generatorVersion: 1);
      final b = PuzzleSeed.daily(day: day, game: GameId.sudoku, generatorVersion: 1);
      expect(a, b);
      expect(_firstOutputs(a), _firstOutputs(b));
    });

    test('cambiar cualquier componente cambia la secuencia', () {
      final base = _firstOutputs(PuzzleSeed.daily(day: day, game: GameId.sudoku, generatorVersion: 1));
      final otherDay = _firstOutputs(PuzzleSeed.daily(day: day.addDays(1), game: GameId.sudoku, generatorVersion: 1));
      final otherGame = _firstOutputs(PuzzleSeed.daily(day: day, game: GameId.minesweeper, generatorVersion: 1));
      final otherVersion = _firstOutputs(PuzzleSeed.daily(day: day, game: GameId.sudoku, generatorVersion: 2));
      expect(otherDay, isNot(base));
      expect(otherGame, isNot(base));
      expect(otherVersion, isNot(base));
    });

    test('es/en dan retos distintos de Sopa', () {
      final es = PuzzleSeed.daily(day: day, game: GameId.wordSearch, generatorVersion: 1, wordsLanguage: 'es');
      final en = PuzzleSeed.daily(day: day, game: GameId.wordSearch, generatorVersion: 1, wordsLanguage: 'en');
      expect(_firstOutputs(es), isNot(_firstOutputs(en)));
    });
  });

  group('PuzzleSeed.fromKey', () {
    test('reconstruye la misma semilla que se guardó', () {
      final original = PuzzleSeed.random(Random(1));
      final restored = PuzzleSeed.fromKey(original.key);
      expect(restored, original);
      expect(_firstOutputs(restored), _firstOutputs(original));
    });

    test('rechaza una clave vacía', () {
      expect(() => PuzzleSeed.fromKey(''), throwsArgumentError);
    });
  });

  group('PuzzleSeed.random', () {
    test('genera claves de partida libre distintas', () {
      final keys = List<String>.generate(100, (_) => PuzzleSeed.random().key).toSet();
      expect(keys.length, 100);
      expect(keys.every((k) => RegExp(r'^free\|[0-9a-f]{32}$').hasMatch(k)), isTrue);
    });
  });
}
