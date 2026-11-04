import 'package:drift/native.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

final _start = LocalNow(utc: DateTime.utc(2026, 11, 3, 2, 55), offsetMinutes: -180);

SessionRecord _session({String id = 's1', SessionStatus status = SessionStatus.won}) {
  final base = SessionRecord(
    id: id,
    game: GameId.wordSearch,
    difficulty: const Difficulty('expert'),
    mode: PuzzleMode.daily,
    startedAt: _start,
    challengeDay: LocalDay(2026, 11, 2),
    seedKey: 'daily:2026-11-02:wordsearch:v3:es',
    generatorVersion: 3,
    wordsLanguage: 'es',
    puzzle: const {
      'size': 14,
      'words': ['GATO', 'ÑANDÚ'],
    },
    state: const {
      'found': [0],
    },
    themeIds: const ['animals', 'kitchen'],
    flagsPlaced: null,
  );
  if (status == SessionStatus.inProgress) return base;
  return base.finish(
    status: status,
    elapsed: const Duration(minutes: 7, seconds: 3, milliseconds: 250),
    completedAt: DateTime.utc(2026, 11, 3, 3, 2),
    freeHints: 2,
    rewardedHints: 1,
    rescued: true,
    flagsPlaced: 4,
  );
}

void _expectSame(SessionRecord a, SessionRecord b) {
  expect(a.id, b.id);
  expect(a.game, b.game);
  expect(a.difficulty, b.difficulty);
  expect(a.mode, b.mode);
  expect(a.startedAt.utc, b.startedAt.utc);
  expect(a.startedAt.offsetMinutes, b.startedAt.offsetMinutes);
  expect(a.challengeDay, b.challengeDay);
  expect(a.seedKey, b.seedKey);
  expect(a.generatorVersion, b.generatorVersion);
  expect(a.wordsLanguage, b.wordsLanguage);
  expect(a.puzzle, b.puzzle);
  expect(a.state, b.state);
  expect(a.status, b.status);
  expect(a.elapsed, b.elapsed);
  expect(a.freeHints, b.freeHints);
  expect(a.rewardedHints, b.rewardedHints);
  expect(a.rescued, b.rescued);
  expect(a.completedAt, b.completedAt);
  expect(a.themeIds, b.themeIds);
  expect(a.flagsPlaced, b.flagsPlaced);
}

void main() {
  late ProgressDatabase db;

  setUp(() => db = ProgressDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('partidas', () {
    test('ida y vuelta sin perder nada (zona, día del reto, JSON, ñ)', () async {
      final session = _session();
      await db.sessionsDao.put(session);
      _expectSame((await db.sessionsDao.byId('s1'))!, session);
      expect(await db.sessionsDao.byId('otra'), isNull);
    });

    test('una partida libre no tiene día del reto; poner de nuevo la actualiza', () async {
      final free = SessionRecord(
        id: 'f1',
        game: GameId.sudoku,
        difficulty: const Difficulty('easy'),
        mode: PuzzleMode.free,
        startedAt: _start,
      );
      await db.sessionsDao.put(free);
      await db.sessionsDao.put(free.withState(const {'v': 2}, const Duration(seconds: 40)));
      final all = await db.sessionsDao.all();
      expect(all, hasLength(1));
      expect(all.single.challengeDay, isNull);
      expect(all.single.state, {'v': 2});
      expect(all.single.elapsed, const Duration(seconds: 40));
      expect(all.single.status, SessionStatus.inProgress);
    });

    test('modo y estado se guardan como texto estable', () async {
      await db.sessionsDao.put(_session(status: SessionStatus.inProgress));
      final row = await db.customSelect('SELECT mode, status FROM sessions').getSingle();
      expect(row.read<String>('mode'), 'daily');
      expect(row.read<String>('status'), 'in_progress');
    });
  });

  group('días del reto', () {
    DailyDay day(int d, {Set<GameId> completed = const {}, Set<GameId> archive = const {}}) => DailyDay(
      day: LocalDay(2026, 11, d),
      offsetMinutes: -180,
      completed: completed,
      archiveCompleted: archive,
      saverUsed: d == 2,
    );

    test('ida y vuelta con completados, archivo y comodín', () async {
      await db.dailyDaysDao.put(day(2, completed: {GameId.sudoku, GameId.wordSearch}, archive: {GameId.minesweeper}));
      final read = (await db.dailyDaysDao.byDay(LocalDay(2026, 11, 2)))!;
      expect(read.completed, {GameId.sudoku, GameId.wordSearch});
      expect(read.archiveCompleted, {GameId.minesweeper});
      expect(read.saverUsed, isTrue);
      expect(read.offsetMinutes, -180);
      expect(await db.dailyDaysDao.byDay(LocalDay(2026, 11, 9)), isNull);
    });

    test('rango por fechas, en orden e incluyendo los extremos', () async {
      for (final d in [12, 3, 10, 1, 30]) {
        await db.dailyDaysDao.put(day(d));
      }
      final range = await db.dailyDaysDao.range(from: LocalDay(2026, 11, 3), to: LocalDay(2026, 11, 12));
      expect([for (final d in range) d.day.day], [3, 10, 12]);
      expect(await db.dailyDaysDao.range(), hasLength(5));
    });
  });

  test('racha: vacía al empezar, una sola fila', () async {
    expect((await db.streakDao.get()).current, 0);
    const state = StreakState(current: 5, best: 9, savers: 1, lastOffsetMinutes: -180, previous: 3);
    await db.streakDao.put(state);
    await db.streakDao.put(
      StreakState(current: 6, best: 9, savers: 2, lastCounted: LocalDay(2026, 11, 3), lastOffsetMinutes: 60),
    );
    final read = await db.streakDao.get();
    expect((read.current, read.best, read.savers, read.lastOffsetMinutes), (6, 9, 2, 60));
    expect(read.lastCounted, LocalDay(2026, 11, 3));
    expect(await db.customSelect('SELECT * FROM streak').get(), hasLength(1));
  });

  test('un logro se desbloquea una sola vez y conserva su fecha; ids desconocidos se ignoran', () async {
    final first = DateTime.utc(2026, 11, 2, 12);
    await db.achievementsDao.unlock(AchievementId.firstPuzzle, first);
    await db.achievementsDao.unlock(AchievementId.firstPuzzle, DateTime.utc(2026, 11, 3));
    await db.customStatement("INSERT INTO achievements (id, unlocked_at_ms) VALUES ('del_futuro', 0)");
    expect(await db.achievementsDao.unlocked(), {AchievementId.firstPuzzle: first});
  });

  test('reinicios de estadísticas por juego y por nivel, por separado', () async {
    final game = DateTime.utc(2026, 11, 1), level = DateTime.utc(2026, 11, 2);
    await db.statsResetsDao.put(GameId.sudoku, game);
    await db.statsResetsDao.put(GameId.sudoku, level, const Difficulty('easy'));
    expect(await db.statsResetsDao.get(GameId.sudoku), game);
    expect(await db.statsResetsDao.get(GameId.sudoku, const Difficulty('easy')), level);
    expect(await db.statsResetsDao.get(GameId.sudoku, const Difficulty('medium')), isNull);
    expect(await db.statsResetsDao.get(GameId.minesweeper), isNull);
  });

  test('borrar todo vacía las 5 tablas', () async {
    await db.sessionsDao.put(_session());
    await db.dailyDaysDao.put(DailyDay(day: LocalDay(2026, 11, 2), offsetMinutes: 0));
    await db.streakDao.put(const StreakState(current: 1, best: 1));
    await db.achievementsDao.unlock(AchievementId.firstPuzzle, DateTime.utc(2026));
    await db.statsResetsDao.put(GameId.sudoku, DateTime.utc(2026));
    await db.clearAll();
    for (final table in db.allTables) {
      expect(await db.select(table).get(), isEmpty, reason: table.actualTableName);
    }
  });
}
