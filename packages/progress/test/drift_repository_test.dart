import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

import 'support.dart';

/// Falla al guardar la racha: después de escribir la partida y el día del
/// reto, a mitad de la transacción de recordResult. Usa la transacción real
/// de SQLite y delega todo lo demás.
final class _FailingStreak implements ProgressRepository {
  _FailingStreak(ProgressDatabase db) : _inner = DriftProgressRepository(db);

  final DriftProgressRepository _inner;

  @override
  Future<void> putStreak(StreakState streak) => throw StateError('disco lleno');

  @override
  Future<T> transaction<T>(Future<T> Function(ProgressStore store) action) => _inner.db.transaction(() => action(this));
  @override
  Future<void> clear() => _inner.clear();
  @override
  Future<List<SessionRecord>> sessions() => _inner.sessions();
  @override
  Future<SessionRecord?> session(String id) => _inner.session(id);
  @override
  Future<void> putSession(SessionRecord session) => _inner.putSession(session);
  @override
  Future<List<DailyDay>> days({LocalDay? from, LocalDay? to}) => _inner.days(from: from, to: to);
  @override
  Future<DailyDay?> day(LocalDay day) => _inner.day(day);
  @override
  Future<void> putDay(DailyDay day) => _inner.putDay(day);
  @override
  Future<StreakState> streak() => _inner.streak();
  @override
  Future<Map<AchievementId, DateTime>> unlocked() => _inner.unlocked();
  @override
  Future<void> unlock(AchievementId id, DateTime at) => _inner.unlock(id, at);
  @override
  Future<DateTime?> statsResetAt(GameId game, [Difficulty? difficulty]) => _inner.statsResetAt(game, difficulty);
  @override
  Future<void> putStatsResetAt(GameId game, DateTime at, [Difficulty? difficulty]) =>
      _inner.putStatsResetAt(game, at, difficulty);
}

void main() {
  late ProgressDatabase db;

  // Cada prueba abre bases distintas (memoria y archivo); no comparten conexión.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() => db = ProgressDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('una falla a mitad de recordResult no deja datos a medias', () async {
    final service = ProgressService(_FailingStreak(db), clock: FakeClock(at('2026-11-02')));
    await expectLater(service.recordResult(session(startedAt: at('2026-11-02', hour: 9))), throwsStateError);
    final repo = DriftProgressRepository(db);
    expect(await repo.sessions(), isEmpty);
    expect(await repo.days(), isEmpty);
    expect((await repo.streak()).current, 0);
    expect(await repo.unlocked(), isEmpty);
  });

  test('lo escrito fuera de una transacción fallida se conserva', () async {
    final repo = DriftProgressRepository(db);
    final running = SessionRecord(
      id: 'en-curso',
      game: GameId.sudoku,
      difficulty: const Difficulty('easy'),
      mode: PuzzleMode.free,
      startedAt: at('2026-11-02', hour: 8),
    );
    await repo.putSession(running);
    await expectLater(
      repo.transaction((store) async {
        await store.putDay(DailyDay(day: LocalDay(2026, 11, 2), offsetMinutes: 0));
        throw StateError('falla');
      }),
      throwsStateError,
    );
    expect((await repo.sessions()).single.id, running.id);
    expect(await repo.days(), isEmpty);
  });

  test('el progreso sobrevive a cerrar y abrir la base (archivo real)', () async {
    final dir = await Directory.systemTemp.createTemp('ludixa_progress');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/progress.sqlite');

    final first = ProgressDatabase(NativeDatabase(file));
    final service = ProgressService(DriftProgressRepository(first), clock: FakeClock(at('2026-11-02')));
    await service.recordResult(session(startedAt: at('2026-11-02', hour: 9)));
    await first.close();

    final reopened = ProgressDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final repo = DriftProgressRepository(reopened);
    expect(await repo.sessions(), hasLength(1));
    expect((await repo.streak()).current, 1);
    expect((await repo.day(LocalDay(2026, 11, 2)))!.completed, {GameId.sudoku});
    expect((await repo.unlocked()).keys, contains(AchievementId.firstPuzzle));
  });
}
