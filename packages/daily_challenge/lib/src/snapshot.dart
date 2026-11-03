import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import 'daily_challenge.dart';

/// Retrato en JSON del reto de un día: lo que comparan los goldens.
Map<String, Object?> dailySnapshot(LocalDay day) {
  final sudoku = DailyChallenge.sudoku(day, today: day);
  final board = DailyChallenge.minesweeper(day, today: day);
  return {
    'day': day.toIso8601(),
    'sudoku': {'difficulty': sudoku.difficulty.name, 'givens': formatGrid(sudoku.givens)},
    'minesweeper': {
      'spec': board.layout.spec.toString(),
      'start': board.start,
      'mines': board.layout.mineIndices.toList(),
    },
    'wordsearch': {
      for (final code in const ['es', 'en'])
        code: () {
          final ws = DailyChallenge.wordSearch(day, code, today: day);
          return {
            'difficulty': ws.puzzle.difficulty.name,
            'themes': ws.themeIds,
            'words': [for (final p in ws.puzzle.placements) p.word],
            'letters': ws.puzzle.letters.join(),
          };
        }(),
    },
  };
}
