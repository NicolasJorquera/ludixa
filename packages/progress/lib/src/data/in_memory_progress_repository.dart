import 'package:puzzle_core/puzzle_core.dart';

import '../domain/achievements.dart';
import '../domain/daily_day.dart';
import '../domain/progress_repository.dart';
import '../domain/session_record.dart';
import '../domain/streak.dart';

/// Progreso en memoria: para pruebas y para las pantallas de H4, hasta que
/// H5-02 lo reemplace por Drift. Se pierde al cerrar la app.
final class InMemoryProgressRepository implements ProgressRepository {
  _State _state = _State();

  @override
  Future<T> transaction<T>(Future<T> Function(ProgressStore store) action) async {
    final draft = _state.copy();
    final result = await action(_Store(draft));
    _state = draft;
    return result;
  }

  _Store get _store => _Store(_state);

  @override
  Future<void> clear() async => _state = _State();

  @override
  Future<List<SessionRecord>> sessions() => _store.sessions();
  @override
  Future<SessionRecord?> session(String id) => _store.session(id);
  @override
  Future<void> putSession(SessionRecord session) => _store.putSession(session);
  @override
  Future<List<DailyDay>> days({LocalDay? from, LocalDay? to}) => _store.days(from: from, to: to);
  @override
  Future<DailyDay?> day(LocalDay day) => _store.day(day);
  @override
  Future<void> putDay(DailyDay day) => _store.putDay(day);
  @override
  Future<StreakState> streak() => _store.streak();
  @override
  Future<void> putStreak(StreakState streak) => _store.putStreak(streak);
  @override
  Future<Map<AchievementId, DateTime>> unlocked() => _store.unlocked();
  @override
  Future<void> unlock(AchievementId id, DateTime at) => _store.unlock(id, at);
  @override
  Future<DateTime?> statsResetAt(GameId game, [Difficulty? difficulty]) => _store.statsResetAt(game, difficulty);
  @override
  Future<void> putStatsResetAt(GameId game, DateTime at, [Difficulty? difficulty]) =>
      _store.putStatsResetAt(game, at, difficulty);
}

final class _State {
  final sessions = <String, SessionRecord>{};
  final days = <LocalDay, DailyDay>{};
  var streak = StreakState.empty;
  final unlocked = <AchievementId, DateTime>{};

  /// Clave "juego" o "juego/nivel".
  final statsResetAt = <String, DateTime>{};

  _State copy() => _State()
    ..sessions.addAll(sessions)
    ..days.addAll(days)
    ..streak = streak
    ..unlocked.addAll(unlocked)
    ..statsResetAt.addAll(statsResetAt);
}

final class _Store implements ProgressStore {
  _Store(this._s);

  final _State _s;

  @override
  Future<List<SessionRecord>> sessions() async => List.unmodifiable(_s.sessions.values);
  @override
  Future<SessionRecord?> session(String id) async => _s.sessions[id];
  @override
  Future<void> putSession(SessionRecord session) async => _s.sessions[session.id] = session;

  @override
  Future<List<DailyDay>> days({LocalDay? from, LocalDay? to}) async => [
    for (final d in _s.days.values)
      if ((from == null || !d.day.isBefore(from)) && (to == null || !d.day.isAfter(to))) d,
  ]..sort((a, b) => a.day.compareTo(b.day));
  @override
  Future<DailyDay?> day(LocalDay day) async => _s.days[day];
  @override
  Future<void> putDay(DailyDay day) async => _s.days[day.day] = day;

  @override
  Future<StreakState> streak() async => _s.streak;
  @override
  Future<void> putStreak(StreakState streak) async => _s.streak = streak;

  @override
  Future<Map<AchievementId, DateTime>> unlocked() async => Map.unmodifiable(_s.unlocked);
  @override
  Future<void> unlock(AchievementId id, DateTime at) async => _s.unlocked.putIfAbsent(id, () => at);

  @override
  Future<DateTime?> statsResetAt(GameId game, [Difficulty? difficulty]) async =>
      _s.statsResetAt[_key(game, difficulty)];
  @override
  Future<void> putStatsResetAt(GameId game, DateTime at, [Difficulty? difficulty]) async =>
      _s.statsResetAt[_key(game, difficulty)] = at;

  static String _key(GameId game, Difficulty? difficulty) =>
      difficulty == null ? game.value : '${game.value}/${difficulty.value}';
}
