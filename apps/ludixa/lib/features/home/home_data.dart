import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../play/play_providers.dart';

/// Lo que muestra la portada, calculado del progreso local.
final class HomeData {
  const HomeData({
    required this.today,
    required this.streak,
    required this.dailyDone,
    required this.dailyTime,
    required this.inProgress,
    required this.winsByLevel,
    required this.week,
    required this.firstTime,
  });

  final LocalDay today;
  final StreakStatus streak;

  /// Retos de hoy completados y su tiempo total.
  final Set<GameId> dailyDone;
  final Duration dailyTime;

  /// La partida en curso más reciente, para "Continuar".
  final SessionRecord? inProgress;

  /// Victorias por juego y nivel (maestría del catálogo).
  final Map<GameId, Map<Difficulty, int>> winsByLevel;
  final WeekSummary week;

  /// Nunca jugó: sin racha, sin "Continuar".
  final bool firstTime;

  bool get dailyComplete => dailyGames.every(dailyDone.contains);

  /// Nivel con más victorias de un juego (la maestría que se muestra).
  (Difficulty, int)? bestLevel(GameId game) {
    final levels = winsByLevel[game];
    if (levels == null || levels.isEmpty) return null;
    final best = levels.entries.reduce((a, b) => b.value > a.value ? b : a);
    return (best.key, best.value);
  }
}

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  ref.watch(progressRevisionProvider);
  final service = ref.watch(progressServiceProvider);
  final repository = service.repository;
  final today = service.clock.now().day;
  final sessions = await repository.sessions();
  final day = await repository.day(today);
  final running = [
    for (final s in sessions)
      if (s.status == SessionStatus.inProgress && s.state.isNotEmpty) s,
  ]..sort((a, b) => b.startedAt.utc.compareTo(a.startedAt.utc));
  final won = sessions.where((s) => s.won);
  return HomeData(
    today: today,
    streak: await service.streakStatus(),
    dailyDone: day?.completed ?? const {},
    dailyTime: won
        .where((s) => s.mode == PuzzleMode.daily && s.challengeDay == today)
        .fold(Duration.zero, (sum, s) => sum + s.elapsed),
    inProgress: running.firstOrNull,
    winsByLevel: {
      for (final game in dailyGames)
        game: {
          for (final s in won.where((s) => s.game == game)) s.difficulty: 0,
        }.map((level, _) => MapEntry(level, ProgressStats.wins(won, game: game, difficulty: level))),
    },
    week: await service.week(),
    firstTime: sessions.isEmpty,
  );
});
