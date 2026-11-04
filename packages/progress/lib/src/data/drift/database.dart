import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../domain/achievements.dart';
import '../../domain/clock.dart';
import '../../domain/daily_day.dart';
import '../../domain/progress_repository.dart';
import '../../domain/session_record.dart';
import '../../domain/streak.dart';
import 'tables.dart';

part 'database.g.dart';

/// Base de datos del progreso (SQLite con Drift). La conexión la pone quien
/// la abre: un archivo en la app y una base en memoria en las pruebas.
@DriftDatabase(
  tables: [Sessions, DailyDays, Streaks, UnlockedAchievements, StatsResets],
  daos: [SessionsDao, DailyDaysDao, StreakDao, AchievementsDao, StatsResetsDao],
)
final class ProgressDatabase extends _$ProgressDatabase {
  ProgressDatabase(super.executor);

  /// Subirla exige una migración y un volcado nuevo (`make-migrations`).
  static const currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  /// "Reiniciar todo el progreso": vacía todas las tablas en una transacción.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}

@DriftAccessor(tables: [Sessions])
final class SessionsDao extends DatabaseAccessor<ProgressDatabase> with _$SessionsDaoMixin {
  SessionsDao(super.db);

  Future<List<SessionRecord>> all() async => [for (final row in await select(sessions).get()) _sessionOf(row)];

  Future<SessionRecord?> byId(String id) async {
    final row = await (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();
    return row == null ? null : _sessionOf(row);
  }

  /// Sin las columnas de JSON pesado (puzzle y estado): con miles de partidas
  /// es la diferencia entre leer kilobytes y megabytes.
  Future<List<SessionRecord>> summaries() async {
    final light = [
      for (final column in sessions.$columns)
        if (column != sessions.puzzleJson && column != sessions.stateJson) column,
    ];
    final rows = await (selectOnly(sessions)..addColumns(light)).get();
    return [
      for (final row in rows)
        _sessionOf(
          SessionRow(
            id: row.read(sessions.id)!,
            gameId: row.read(sessions.gameId)!,
            difficulty: row.read(sessions.difficulty)!,
            mode: row.read(sessions.mode)!,
            startedAtMs: row.read(sessions.startedAtMs)!,
            startOffsetMin: row.read(sessions.startOffsetMin)!,
            challengeDate: row.read(sessions.challengeDate),
            seed: row.read(sessions.seed)!,
            generatorVersion: row.read(sessions.generatorVersion)!,
            wordsLang: row.read(sessions.wordsLang),
            puzzleJson: '{}',
            stateJson: '{}',
            status: row.read(sessions.status)!,
            elapsedMs: row.read(sessions.elapsedMs)!,
            hintsFree: row.read(sessions.hintsFree)!,
            hintsRewarded: row.read(sessions.hintsRewarded)!,
            rescued: row.read(sessions.rescued)!,
            completedAtMs: row.read(sessions.completedAtMs),
            themeIdsJson: row.read(sessions.themeIdsJson)!,
            flagsPlaced: row.read(sessions.flagsPlaced),
          ),
        ),
    ];
  }

  Future<List<SessionRecord>> inProgress() async => [
    for (final row in await (select(
      sessions,
    )..where((s) => s.status.equals(_statuses[SessionStatus.inProgress]!))).get())
      _sessionOf(row),
  ];

  /// Inserta o reemplaza (las instantáneas actualizan la misma partida).
  Future<void> put(SessionRecord session) => into(sessions).insertOnConflictUpdate(_sessionRow(session));
}

@DriftAccessor(tables: [DailyDays])
final class DailyDaysDao extends DatabaseAccessor<ProgressDatabase> with _$DailyDaysDaoMixin {
  DailyDaysDao(super.db);

  Future<DailyDay?> byDay(LocalDay day) async {
    final row = await (select(dailyDays)..where((d) => d.localDate.equals(day.toIso8601()))).getSingleOrNull();
    return row == null ? null : _dayOf(row);
  }

  /// Días entre [from] y [to], ambos incluidos, en orden. El formato
  /// AAAA-MM-DD ordena igual como texto que como fecha.
  Future<List<DailyDay>> range({LocalDay? from, LocalDay? to}) async {
    final query = select(dailyDays)
      ..where((d) {
        Expression<bool> condition = const Constant(true);
        if (from != null) condition = condition & d.localDate.isBiggerOrEqualValue(from.toIso8601());
        if (to != null) condition = condition & d.localDate.isSmallerOrEqualValue(to.toIso8601());
        return condition;
      })
      ..orderBy([(d) => OrderingTerm.asc(d.localDate)]);
    return [for (final row in await query.get()) _dayOf(row)];
  }

  Future<void> put(DailyDay day) => into(dailyDays).insertOnConflictUpdate(_dayRow(day));
}

@DriftAccessor(tables: [Streaks])
final class StreakDao extends DatabaseAccessor<ProgressDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  Future<StreakState> get() async {
    final row = await select(streaks).getSingleOrNull();
    return row == null ? StreakState.empty : _streakOf(row);
  }

  Future<void> put(StreakState streak) => into(streaks).insertOnConflictUpdate(_streakRow(streak));
}

@DriftAccessor(tables: [UnlockedAchievements])
final class AchievementsDao extends DatabaseAccessor<ProgressDatabase> with _$AchievementsDaoMixin {
  AchievementsDao(super.db);

  /// Ids desconocidos (de una versión futura) se ignoran.
  Future<Map<AchievementId, DateTime>> unlocked() async {
    final byKey = {for (final id in AchievementId.values) id.key: id};
    return {
      for (final row in await select(unlockedAchievements).get())
        ?byKey[row.id]: DateTime.fromMillisecondsSinceEpoch(row.unlockedAtMs, isUtc: true),
    };
  }

  /// Un logro se desbloquea una sola vez: la fecha original se conserva.
  Future<void> unlock(AchievementId id, DateTime at) => into(unlockedAchievements).insert(
    UnlockedAchievementsCompanion.insert(id: id.key, unlockedAtMs: at.toUtc().millisecondsSinceEpoch),
    mode: InsertMode.insertOrIgnore,
  );
}

@DriftAccessor(tables: [StatsResets])
final class StatsResetsDao extends DatabaseAccessor<ProgressDatabase> with _$StatsResetsDaoMixin {
  StatsResetsDao(super.db);

  Future<DateTime?> get(GameId game, [Difficulty? difficulty]) async {
    final row = await (select(
      statsResets,
    )..where((r) => r.gameId.equals(game.value) & r.difficulty.equals(difficulty?.value ?? ''))).getSingleOrNull();
    return row == null ? null : DateTime.fromMillisecondsSinceEpoch(row.resetAtMs, isUtc: true);
  }

  Future<List<StatsReset>> all() async => [
    for (final row in await select(statsResets).get())
      (
        game: GameId(row.gameId),
        difficulty: row.difficulty.isEmpty ? null : Difficulty(row.difficulty),
        at: _utc(row.resetAtMs),
      ),
  ];

  Future<void> put(GameId game, DateTime at, [Difficulty? difficulty]) => into(statsResets).insertOnConflictUpdate(
    StatsResetsCompanion.insert(
      gameId: game.value,
      difficulty: difficulty?.value ?? '',
      resetAtMs: at.toUtc().millisecondsSinceEpoch,
    ),
  );
}

// Conversión entre filas y dominio. Los valores guardados son explícitos
// (no el nombre del enum de Dart) para que renombrar código no rompa datos.

const _modes = {PuzzleMode.free: 'free', PuzzleMode.daily: 'daily', PuzzleMode.archive: 'archive'};
const _statuses = {
  SessionStatus.inProgress: 'in_progress',
  SessionStatus.won: 'won',
  SessionStatus.lost: 'lost',
  SessionStatus.abandoned: 'abandoned',
};

K _key<K>(Map<K, String> values, String stored) => values.entries.firstWhere((e) => e.value == stored).key;

DateTime _utc(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

SessionsCompanion _sessionRow(SessionRecord s) => SessionsCompanion.insert(
  id: s.id,
  gameId: s.game.value,
  difficulty: s.difficulty.value,
  mode: _modes[s.mode]!,
  startedAtMs: s.startedAt.utc.millisecondsSinceEpoch,
  startOffsetMin: s.startedAt.offsetMinutes,
  challengeDate: Value(s.challengeDay?.toIso8601()),
  seed: s.seedKey,
  generatorVersion: s.generatorVersion,
  wordsLang: Value(s.wordsLanguage),
  puzzleJson: jsonEncode(s.puzzle),
  stateJson: jsonEncode(s.state),
  status: _statuses[s.status]!,
  elapsedMs: s.elapsed.inMilliseconds,
  hintsFree: s.freeHints,
  hintsRewarded: s.rewardedHints,
  rescued: s.rescued,
  completedAtMs: Value(s.completedAt?.toUtc().millisecondsSinceEpoch),
  themeIdsJson: jsonEncode(s.themeIds),
  flagsPlaced: Value(s.flagsPlaced),
);

SessionRecord _sessionOf(SessionRow r) => SessionRecord(
  id: r.id,
  game: GameId(r.gameId),
  difficulty: Difficulty(r.difficulty),
  mode: _key(_modes, r.mode),
  startedAt: LocalNow(utc: _utc(r.startedAtMs), offsetMinutes: r.startOffsetMin),
  challengeDay: r.challengeDate == null ? null : LocalDay.parse(r.challengeDate!),
  seedKey: r.seed,
  generatorVersion: r.generatorVersion,
  wordsLanguage: r.wordsLang,
  puzzle: (jsonDecode(r.puzzleJson) as Map).cast<String, Object?>(),
  state: (jsonDecode(r.stateJson) as Map).cast<String, Object?>(),
  status: _key(_statuses, r.status),
  elapsed: Duration(milliseconds: r.elapsedMs),
  freeHints: r.hintsFree,
  rewardedHints: r.hintsRewarded,
  rescued: r.rescued,
  completedAt: r.completedAtMs == null ? null : _utc(r.completedAtMs!),
  themeIds: (jsonDecode(r.themeIdsJson) as List).cast<String>(),
  flagsPlaced: r.flagsPlaced,
);

String _games(Set<GameId> games) => (games.map((g) => g.value).toList()..sort()).join(',');

Set<GameId> _gamesOf(String stored) => {
  for (final id in stored.split(','))
    if (id.isNotEmpty) GameId(id),
};

DailyDaysCompanion _dayRow(DailyDay d) => DailyDaysCompanion.insert(
  localDate: d.day.toIso8601(),
  tzOffsetMin: d.offsetMinutes,
  completedGames: _games(d.completed),
  archiveGames: _games(d.archiveCompleted),
  saverUsed: d.saverUsed,
);

DailyDay _dayOf(DailyDayRow r) => DailyDay(
  day: LocalDay.parse(r.localDate),
  offsetMinutes: r.tzOffsetMin,
  completed: _gamesOf(r.completedGames),
  archiveCompleted: _gamesOf(r.archiveGames),
  saverUsed: r.saverUsed,
);

StreaksCompanion _streakRow(StreakState s) => StreaksCompanion.insert(
  id: const Value(1),
  current: s.current,
  best: s.best,
  savers: s.savers,
  lastCountedDate: Value(s.lastCounted?.toIso8601()),
  lastOffsetMin: s.lastOffsetMinutes,
  previous: s.previous,
);

StreakState _streakOf(StreakRow r) => StreakState(
  current: r.current,
  best: r.best,
  savers: r.savers,
  lastCounted: r.lastCountedDate == null ? null : LocalDay.parse(r.lastCountedDate!),
  lastOffsetMinutes: r.lastOffsetMin,
  previous: r.previous,
);
