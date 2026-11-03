import 'dart:math' as math;

import 'package:puzzle_core/puzzle_core.dart';

import 'daily_day.dart';
import 'session_record.dart';

/// Estadísticas de un juego en una dificultad. Se calculan de las partidas,
/// sin tablas propias.
final class DifficultyStats {
  const DifficultyStats({
    required this.started,
    required this.won,
    required this.lost,
    required this.bestTime,
    required this.meanTime,
    required this.currentWinStreak,
    required this.bestWinStreak,
    required this.unassistedWins,
    required this.hintsUsed,
  });

  final int started;
  final int won;
  final int lost;
  final Duration? bestTime;
  final Duration? meanTime;
  final int currentWinStreak;
  final int bestWinStreak;
  final int unassistedWins;
  final int hintsUsed;

  /// % de victorias sobre partidas decididas (tiene sentido en el Buscaminas).
  double? get winRate => won + lost == 0 ? null : won / (won + lost);

  factory DifficultyStats.of(Iterable<SessionRecord> sessions) {
    final finished = sessions.where((s) => s.finished).toList()..sort(_byCompletion);
    final wins = [
      for (final s in finished)
        if (s.won) s.elapsed,
    ];
    var streak = 0, bestStreak = 0;
    for (final s in finished) {
      streak = s.won ? streak + 1 : 0;
      bestStreak = math.max(bestStreak, streak);
    }
    return DifficultyStats(
      started: sessions.length,
      won: wins.length,
      lost: finished.where((s) => s.status == SessionStatus.lost).length,
      bestTime: wins.isEmpty ? null : wins.reduce((a, b) => a < b ? a : b),
      meanTime: wins.isEmpty
          ? null
          : Duration(microseconds: wins.fold(0, (sum, d) => sum + d.inMicroseconds) ~/ wins.length),
      currentWinStreak: streak,
      bestWinStreak: bestStreak,
      unassistedWins: finished.where((s) => s.won && !s.assisted).length,
      hintsUsed: sessions.fold(0, (sum, s) => sum + s.hintsUsed),
    );
  }
}

/// Maestría por juego y dificultad: 10, 25 y 50 partidas completadas.
enum Mastery {
  none(0),
  bronze(10),
  silver(25),
  gold(50);

  const Mastery(this.wins);

  final int wins;

  static Mastery forWins(int wins) => values.lastWhere((m) => wins >= m.wins);

  /// Victorias que faltan para el siguiente nivel (null en Oro).
  static int? toNext(int wins) {
    final next = forWins(wins).index + 1;
    return next < values.length ? values[next].wins - wins : null;
  }
}

/// Insignia de un mes: 20 días jugados o más; dorada si todos fueron perfectos.
enum MonthBadge { none, earned, golden }

/// Cálculos sobre el historial.
abstract final class ProgressStats {
  static const int daysForMonthBadge = 20;

  static DifficultyStats forDifficulty(Iterable<SessionRecord> sessions, GameId game, Difficulty difficulty) =>
      DifficultyStats.of(sessions.where((s) => s.game == game && s.difficulty == difficulty));

  static int wins(Iterable<SessionRecord> sessions, {GameId? game, Difficulty? difficulty}) => sessions
      .where((s) => s.won && (game == null || s.game == game) && (difficulty == null || s.difficulty == difficulty))
      .length;

  static Mastery mastery(Iterable<SessionRecord> sessions, GameId game, Difficulty difficulty) =>
      Mastery.forWins(wins(sessions, game: game, difficulty: difficulty));

  /// Tiempo total de las partidas terminadas.
  static Duration totalTime(Iterable<SessionRecord> sessions) =>
      sessions.where((s) => s.finished).fold(Duration.zero, (sum, s) => sum + s.elapsed);

  /// Temas distintos de las sopas completadas.
  static Set<String> themesExplored(Iterable<SessionRecord> sessions) => {
    for (final s in sessions)
      if (s.won && s.game == GameId.wordSearch) ...s.themeIds,
  };

  static MonthBadge monthBadge(Iterable<DailyDay> days, int year, int month) {
    final inMonth = [
      for (final d in days)
        if (d.day.year == year && d.day.month == month) d,
    ];
    final played = inMonth.where((d) => d.played).length;
    if (played < daysForMonthBadge) return MonthBadge.none;
    final length = DateTime.utc(year, month + 1, 0).day;
    final perfect = inMonth.where((d) => d.perfect).length;
    return perfect == length ? MonthBadge.golden : MonthBadge.earned;
  }

  /// Meses con insignia (cualquiera), en orden.
  static List<(int, int, MonthBadge)> monthBadges(Iterable<DailyDay> days) {
    final months = {for (final d in days) (d.day.year, d.day.month)}.toList()
      ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [
      for (final (y, m) in months)
        if (monthBadge(days, y, m) case final badge when badge != MonthBadge.none) (y, m, badge),
    ];
  }

  /// "Tu semana": los 7 días que terminan hoy, por día local de inicio.
  static WeekSummary week(Iterable<SessionRecord> sessions, LocalDay today) {
    final from = today.addDays(-6);
    final inWeek = sessions.where(
      (s) => s.finished && !s.startedAt.day.isBefore(from) && !s.startedAt.day.isAfter(today),
    );
    return WeekSummary(
      completedByGame: {for (final game in dailyGames) game: inWeek.where((s) => s.won && s.game == game).length},
      time: totalTime(inWeek),
      bestTimeByGame: {
        for (final game in dailyGames) game: ?DifficultyStats.of(inWeek.where((s) => s.game == game)).bestTime,
      },
    );
  }
}

final class WeekSummary {
  const WeekSummary({required this.completedByGame, required this.time, required this.bestTimeByGame});

  final Map<GameId, int> completedByGame;
  final Duration time;
  final Map<GameId, Duration> bestTimeByGame;
}

int _byCompletion(SessionRecord a, SessionRecord b) =>
    (a.completedAt ?? a.startedAt.utc).compareTo(b.completedAt ?? b.startedAt.utc);
