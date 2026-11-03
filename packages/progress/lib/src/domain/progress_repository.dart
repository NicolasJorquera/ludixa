import 'package:puzzle_core/puzzle_core.dart';

import 'achievements.dart';
import 'daily_day.dart';
import 'session_record.dart';
import 'streak.dart';

/// Lecturas y escrituras dentro de una transacción.
abstract interface class ProgressStore {
  Future<List<SessionRecord>> sessions();
  Future<SessionRecord?> session(String id);
  Future<void> putSession(SessionRecord session);

  Future<List<DailyDay>> days({LocalDay? from, LocalDay? to});
  Future<DailyDay?> day(LocalDay day);
  Future<void> putDay(DailyDay day);

  Future<StreakState> streak();
  Future<void> putStreak(StreakState streak);

  Future<Map<AchievementId, DateTime>> unlocked();
  Future<void> unlock(AchievementId id, DateTime at);

  /// Desde cuándo cuentan las estadísticas de un juego, o de uno de sus
  /// niveles si se da [difficulty] (null: desde siempre).
  Future<DateTime?> statsResetAt(GameId game, [Difficulty? difficulty]);
  Future<void> putStatsResetAt(GameId game, DateTime at, [Difficulty? difficulty]);
}

/// Almacenamiento del progreso. Registrar un resultado es una sola
/// transacción: sesión, día del reto, racha y logros.
abstract interface class ProgressRepository implements ProgressStore {
  /// Ejecuta [action] de forma atómica: si lanza, no queda nada escrito.
  Future<T> transaction<T>(Future<T> Function(ProgressStore store) action);
}
