import 'package:puzzle_core/puzzle_core.dart';

import '../../domain/achievements.dart';
import '../../domain/daily_day.dart';
import '../../domain/progress_repository.dart';
import '../../domain/session_record.dart';
import '../../domain/streak.dart';
import 'database.dart';

/// Progreso guardado en SQLite (H5-02). [transaction] es una transacción real:
/// si la acción lanza, SQLite deshace todo lo que escribió.
final class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this.db);

  final ProgressDatabase db;

  // Dentro de db.transaction, Drift dirige estas mismas llamadas a la
  // transacción en curso: el store y el repositorio son el mismo objeto.
  @override
  Future<T> transaction<T>(Future<T> Function(ProgressStore store) action) => db.transaction(() => action(this));

  // Dentro de una transacción, Drift la anida (savepoint).
  @override
  Future<void> clear() => db.clearAll();
  @override
  Future<List<StatsReset>> statsResets() => db.statsResetsDao.all();

  @override
  Future<List<SessionRecord>> sessions() => db.sessionsDao.all();
  @override
  Future<List<SessionRecord>> sessionSummaries() => db.sessionsDao.summaries();
  @override
  Future<List<SessionRecord>> inProgressSessions() => db.sessionsDao.inProgress();
  @override
  Future<SessionRecord?> session(String id) => db.sessionsDao.byId(id);
  @override
  Future<void> putSession(SessionRecord session) => db.sessionsDao.put(session);

  @override
  Future<List<DailyDay>> days({LocalDay? from, LocalDay? to}) => db.dailyDaysDao.range(from: from, to: to);
  @override
  Future<DailyDay?> day(LocalDay day) => db.dailyDaysDao.byDay(day);
  @override
  Future<void> putDay(DailyDay day) => db.dailyDaysDao.put(day);

  @override
  Future<StreakState> streak() => db.streakDao.get();
  @override
  Future<void> putStreak(StreakState streak) => db.streakDao.put(streak);

  @override
  Future<Map<AchievementId, DateTime>> unlocked() => db.achievementsDao.unlocked();
  @override
  Future<void> unlock(AchievementId id, DateTime at) => db.achievementsDao.unlock(id, at);

  @override
  Future<DateTime?> statsResetAt(GameId game, [Difficulty? difficulty]) => db.statsResetsDao.get(game, difficulty);
  @override
  Future<void> putStatsResetAt(GameId game, DateTime at, [Difficulty? difficulty]) =>
      db.statsResetsDao.put(game, at, difficulty);
}
