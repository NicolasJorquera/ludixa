import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'schedule.dart';

/// Se pidió el reto de un día posterior a hoy.
final class DailyNotAvailable implements Exception {
  DailyNotAvailable(this.day, this.today);

  final LocalDay day;
  final LocalDay today;

  @override
  String toString() => 'DailyNotAvailable: $day todavía no llega (hoy es $today)';
}

/// Sopa del día y los temas de los que salen sus palabras.
final class DailyWordSearch {
  const DailyWordSearch({required this.puzzle, required this.themeIds, required this.special});

  final WordSearchPuzzle puzzle;

  /// Un tema, o tres el domingo.
  final List<String> themeIds;
  final bool special;
}

/// Puzzles del reto diario. Para una fecha (y un idioma, en la sopa) son
/// idénticos en todos los dispositivos con las mismas versiones.
///
/// Las versiones de cada juego forman parte de la semilla. Si cambia el motor
/// de un juego, su banco o una regla de este archivo que afecte sus puzzles,
/// hay que subir la versión de ese juego (las pruebas de goldens lo detectan).
abstract final class DailyChallenge {
  static const int sudokuVersion = 1;
  static const int minesweeperVersion = 1;
  static const int wordSearchVersion = 1;

  /// Un Medio es "medio alto" si exige pointing o claiming al menos estas
  /// veces. En el banco v1, el 61% de los Medios lo cumple (ADR 0005).
  static const int upperMediumMinSteps = 2;

  /// Lunes en que empieza la ronda de temas de la sopa.
  static final LocalDay _rotationStart = LocalDay(2026, 1, 5);
  static const int _themesPerWeek = 9;

  static PuzzleSeed seed(GameId game, LocalDay day, {String? wordsLanguage}) => PuzzleSeed.daily(
    day: day,
    game: game,
    generatorVersion: switch (game) {
      GameId.sudoku => sudokuVersion,
      GameId.minesweeper => minesweeperVersion,
      _ => wordSearchVersion,
    },
    wordsLanguage: wordsLanguage,
  );

  /// Sudoku del día, tomado del banco pregenerado (ADR 0004).
  static SudokuPuzzle sudoku(LocalDay day, {required LocalDay today}) {
    _checkAvailable(day, today);
    final lineup = DailyLineup.of(day);
    final random = seed(GameId.sudoku, day).createRandom();
    if (!lineup.sudokuUpperMedium) return SudokuBank.pick(lineup.sudoku, random);
    // El banco garantiza que la mayoría califica; el tope evita un bucle
    // infinito si un banco futuro no tuviera ninguno.
    for (var tries = 0; tries < 200; tries++) {
      final puzzle = SudokuBank.pick(lineup.sudoku, random);
      if (mediumSteps(puzzle.givens) >= upperMediumMinSteps) return puzzle;
    }
    throw StateError('El banco de Sudoku no tiene Medios altos');
  }

  /// Pasos de técnicas de nivel Medio que exige resolver [givens].
  static int mediumSteps(List<int> givens) =>
      HumanSolver.solve(givens).steps.where((s) => s.technique.difficulty == SudokuDifficulty.medium).length;

  /// Buscaminas del día: tablero y celda de inicio salen de la semilla.
  static GeneratedBoard minesweeper(LocalDay day, {required LocalDay today}) {
    _checkAvailable(day, today);
    return const NoGuessGenerator().generateDaily(DailyLineup.of(day).minesweeper, seed(GameId.minesweeper, day));
  }

  /// Sopa del día en [languageCode]. Los idiomas comparten tema, pero no la
  /// grilla: las palabras son otras.
  static DailyWordSearch wordSearch(LocalDay day, String languageCode, {required LocalDay today}) {
    _checkAvailable(day, today);
    final lineup = DailyLineup.of(day);
    final themeIds = themesFor(day);
    final words = [for (final id in themeIds) ...WordBanks.theme(languageCode, id).words];
    final puzzle = const WordSearchGenerator().generate(
      themeWords: words,
      language: WordLanguage.byCode(languageCode),
      difficulty: lineup.wordSearch,
      random: seed(GameId.wordSearch, day, wordsLanguage: languageCode).createRandom(),
      blocklist: WordBanks.blocklist(languageCode),
    );
    return DailyWordSearch(puzzle: puzzle, themeIds: themeIds, special: lineup.specialTheme);
  }

  /// Temas del día. Cada día toma los siguientes de una ronda fija por los
  /// 20 temas: uno de lunes a sábado y tres el domingo, 9 por semana. Así
  /// ningún tema se repite en 14 días seguidos.
  static List<String> themesFor(LocalDay day) {
    final order = [for (final t in WordBanks.themes('es')) t.id];
    PuzzleSeed.fromKey('daily-themes|v$wordSearchVersion').createRandom().shuffle(order);
    final days = _rotationStart.daysUntil(day);
    final dayOfWeek = days % 7; // 0 = lunes; `%` en Dart nunca es negativo.
    final week = (days - dayOfWeek) ~/ 7;
    final first = week * _themesPerWeek + dayOfWeek;
    final count = DailyLineup.of(day).specialTheme ? 3 : 1;
    return [for (var k = 0; k < count; k++) order[(first + k) % order.length]];
  }

  static void _checkAvailable(LocalDay day, LocalDay today) {
    if (day.isAfter(today)) throw DailyNotAvailable(day, today);
  }
}
