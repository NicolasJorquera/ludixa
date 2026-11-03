import 'package:puzzle_core/puzzle_core.dart';

import 'daily_day.dart';
import 'session_record.dart';
import 'stats.dart';
import 'streak.dart';

/// Los 18 logros del lanzamiento. Ninguno exige anuncios, una hora concreta
/// ni muchas horas de juego. El id se guarda: no se cambia nunca.
enum AchievementId {
  // Transversales
  firstPuzzle('first_puzzle', 1),
  allThreeGames('all_three_games', 3),
  streak3('streak_3', 3),
  streak7('streak_7', 7),
  streak30('streak_30', 30),
  streak100('streak_100', 100),
  perfectDay('perfect_day', 1),
  fullMonth('full_month', 1),
  tenUnassisted('ten_unassisted', 10),
  // Sudoku
  sudokuFirstHard('sudoku_first_hard', 1),
  sudokuFirstExpert('sudoku_first_expert', 1),
  sudokuFastMedium('sudoku_fast_medium', 1),
  // Buscaminas
  minesFirstExpert('mines_first_expert', 1),
  minesFiveInARow('mines_five_in_a_row', 5),
  minesNoFlags('mines_no_flags', 1),
  // Sopa de letras
  wordsTenThemes('words_ten_themes', 10),
  wordsExpertNoHints('words_expert_no_hints', 1),
  wordsFifty('words_fifty', 50);

  const AchievementId(this.key, this.target);

  final String key;
  final int target;
}

/// Lo que se evalúa: todo el historial. Son miles de filas como mucho.
final class ProgressSnapshot {
  const ProgressSnapshot({required this.sessions, required this.days, required this.streak});

  final List<SessionRecord> sessions;
  final List<DailyDay> days;
  final StreakState streak;
}

/// Avance de cada logro (de 0 a su meta).
abstract final class Achievements {
  static const sudokuFastMediumLimit = Duration(minutes: 6);

  static int progress(AchievementId id, ProgressSnapshot p) {
    final value = _raw(id, p);
    return value > id.target ? id.target : value;
  }

  static Map<AchievementId, int> all(ProgressSnapshot p) => {
    for (final id in AchievementId.values) id: progress(id, p),
  };

  static int _raw(AchievementId id, ProgressSnapshot p) {
    final won = p.sessions.where((s) => s.won);
    int wins(GameId game, String difficulty) => ProgressStats.wins(won, game: game, difficulty: Difficulty(difficulty));
    return switch (id) {
      AchievementId.firstPuzzle => won.length,
      AchievementId.allThreeGames => {for (final s in won) s.game}.length,
      AchievementId.streak3 ||
      AchievementId.streak7 ||
      AchievementId.streak30 ||
      AchievementId.streak100 => p.streak.best,
      AchievementId.perfectDay => p.days.where((d) => d.perfect).length,
      AchievementId.fullMonth => ProgressStats.monthBadges(p.days).length,
      AchievementId.tenUnassisted => won.where((s) => !s.assisted).length,
      AchievementId.sudokuFirstHard => wins(GameId.sudoku, 'hard'),
      AchievementId.sudokuFirstExpert => wins(GameId.sudoku, 'expert'),
      AchievementId.sudokuFastMedium =>
        won
            .where(
              (s) =>
                  s.game == GameId.sudoku &&
                  s.difficulty == const Difficulty('medium') &&
                  s.elapsed < sudokuFastMediumLimit,
            )
            .length,
      AchievementId.minesFirstExpert => wins(GameId.minesweeper, 'expert'),
      AchievementId.minesFiveInARow => DifficultyStats.of(
        p.sessions.where((s) => s.game == GameId.minesweeper),
      ).bestWinStreak,
      AchievementId.minesNoFlags => won.where((s) => s.game == GameId.minesweeper && s.flagsPlaced == 0).length,
      AchievementId.wordsTenThemes => ProgressStats.themesExplored(won).length,
      AchievementId.wordsExpertNoHints =>
        won
            .where((s) => s.game == GameId.wordSearch && s.difficulty == const Difficulty('expert') && s.hintsUsed == 0)
            .length,
      AchievementId.wordsFifty => won.where((s) => s.game == GameId.wordSearch).length,
    };
  }
}
