import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../play/play_providers.dart';

/// El día local de hoy. La pestaña Reto lo invalida a medianoche y al volver
/// a la app, así un cambio de día con la pantalla abierta la refresca.
final todayProvider = Provider<LocalDay>((ref) => ref.watch(clockProvider).now().day);

/// Lo que se sabe de un día del reto: qué se completó (ese día o desde el
/// archivo), en cuánto tiempo y qué quedó a medias.
final class DayStatus {
  const DayStatus({
    required this.day,
    required this.completed,
    required this.archiveCompleted,
    required this.saverUsed,
    required this.timeByGame,
    required this.running,
  });

  final LocalDay day;
  final Set<GameId> completed;
  final Set<GameId> archiveCompleted;
  final bool saverUsed;

  /// Tiempo del reto ganado de cada juego.
  final Map<GameId, Duration> timeByGame;

  /// Retos de ese día empezados y sin terminar.
  final Map<GameId, SessionRecord> running;

  bool done(GameId game) => completed.contains(game) || archiveCompleted.contains(game);
  bool get complete => dailyGames.every(completed.contains);
}

final dayStatusProvider = FutureProvider.family<DayStatus, LocalDay>((ref, day) async {
  ref.watch(progressRevisionProvider);
  final repository = ref.watch(progressServiceProvider).repository;
  final record = await repository.day(day);
  final sessions = (await repository.sessions()).where((s) => s.challengeDay == day && s.mode != PuzzleMode.free);
  final running = <GameId, SessionRecord>{};
  for (final s in sessions.where((s) => s.status == SessionStatus.inProgress && s.state.isNotEmpty)) {
    final current = running[s.game];
    if (current == null || s.startedAt.utc.isAfter(current.startedAt.utc)) running[s.game] = s;
  }
  return DayStatus(
    day: day,
    completed: record?.completed ?? const {},
    archiveCompleted: record?.archiveCompleted ?? const {},
    saverUsed: record?.saverUsed ?? false,
    timeByGame: {for (final s in sessions.where((s) => s.won)) s.game: s.elapsed},
    running: running,
  );
});

/// Días del calendario de un mes (año, mes).
final monthDaysProvider = FutureProvider.family<Map<LocalDay, DailyDay>, (int, int)>((ref, month) async {
  ref.watch(progressRevisionProvider);
  final repository = ref.watch(progressServiceProvider).repository;
  final (year, m) = month;
  final first = LocalDay(year, m, 1);
  final last = LocalDay.fromDateTime(DateTime.utc(year, m + 1, 0));
  return {for (final d in await repository.days(from: first, to: last)) d.day: d};
});

/// Los 30 días del archivo, del más reciente al más antiguo.
final archiveDaysProvider = FutureProvider<List<(LocalDay, DailyDay?)>>((ref) async {
  ref.watch(progressRevisionProvider);
  final today = ref.watch(todayProvider);
  final repository = ref.watch(progressServiceProvider).repository;
  final from = today.addDays(-DailyArchive.days);
  final known = {for (final d in await repository.days(from: from, to: today.addDays(-1))) d.day: d};
  return [for (var i = 1; i <= DailyArchive.days; i++) (today.addDays(-i), known[today.addDays(-i)])];
});

final streakStatusProvider = FutureProvider<StreakStatus>((ref) {
  ref.watch(progressRevisionProvider);
  ref.watch(todayProvider);
  return ref.watch(progressServiceProvider).streakStatus();
});
