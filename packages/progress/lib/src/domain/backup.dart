import 'dart:convert';

import 'package:puzzle_core/puzzle_core.dart';

import 'achievements.dart';
import 'clock.dart';
import 'daily_day.dart';
import 'progress_repository.dart';
import 'session_record.dart';
import 'streak.dart';

/// Por qué no se puede importar un archivo.
enum BackupProblem {
  /// No es JSON.
  notJson,

  /// Es JSON, pero no es un respaldo de Ludixa.
  notLudixa,

  /// Lo hizo una versión más nueva de la app.
  newerVersion,

  /// Es un respaldo de Ludixa, pero le faltan datos o están mal.
  corrupt,
}

final class BackupException implements Exception {
  const BackupException(this.problem, [this.detail]);

  final BackupProblem problem;
  final String? detail;

  @override
  String toString() => 'BackupException(${problem.name}${detail == null ? '' : ': $detail'})';
}

/// Un respaldo ya leído y validado: se puede mostrar y luego restaurar.
final class ProgressBackupData {
  const ProgressBackupData({
    required this.exportedAt,
    required this.sessions,
    required this.days,
    required this.streak,
    required this.unlocked,
    required this.resets,
  });

  final DateTime exportedAt;
  final List<SessionRecord> sessions;
  final List<DailyDay> days;
  final StreakState streak;
  final Map<AchievementId, DateTime> unlocked;
  final List<StatsReset> resets;

  int get completed => sessions.where((s) => s.won).length;
}

/// Respaldo del progreso en JSON (H5-05): partidas completas (con su puzzle y
/// estado, para retomar las que están en curso), calendario, racha, logros y
/// reinicios. No incluye los ajustes ni los contadores de anuncios.
///
/// El formato tiene versión. Un archivo de una versión más nueva se rechaza
/// en vez de importarse a medias.
abstract final class ProgressBackup {
  static const format = 'ludixa-progress';
  static const version = 1;

  static Future<String> export(ProgressStore store, {required DateTime now}) async {
    final resets = await store.statsResets();
    return const JsonEncoder.withIndent(' ').convert({
      'format': format,
      'version': version,
      'exportedAt': now.toUtc().toIso8601String(),
      'sessions': [for (final s in await store.sessions()) _sessionToJson(s)],
      'days': [for (final d in await store.days()) _dayToJson(d)],
      'streak': _streakToJson(await store.streak()),
      'achievements': {for (final MapEntry(:key, :value) in (await store.unlocked()).entries) key.key: _instant(value)},
      'statsResets': [
        for (final r in resets) {'game': r.game.value, 'difficulty': r.difficulty?.value, 'at': _instant(r.at)},
      ],
    });
  }

  /// Lee y valida todo el archivo antes de tocar nada.
  static ProgressBackupData parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const BackupException(BackupProblem.notJson);
    }
    if (decoded is! Map<String, Object?> || decoded['format'] != format) {
      throw const BackupException(BackupProblem.notLudixa);
    }
    final fileVersion = decoded['version'];
    if (fileVersion is! int || fileVersion < 1) throw const BackupException(BackupProblem.corrupt, 'version');
    if (fileVersion > version) throw const BackupException(BackupProblem.newerVersion);
    try {
      final byKey = {for (final id in AchievementId.values) id.key: id};
      return ProgressBackupData(
        exportedAt: _parseInstant(decoded['exportedAt']),
        sessions: [for (final s in _list(decoded['sessions'])) _sessionFromJson(_map(s))],
        days: [for (final d in _list(decoded['days'])) _dayFromJson(_map(d))],
        streak: _streakFromJson(_map(decoded['streak'])),
        unlocked: {
          for (final MapEntry(:key, :value) in _map(decoded['achievements']).entries) ?byKey[key]: _parseInstant(value),
        },
        resets: [
          for (final r in _list(decoded['statsResets']))
            (
              game: GameId(_map(r)['game']! as String),
              difficulty: switch (_map(r)['difficulty']) {
                final String level => Difficulty(level),
                _ => null,
              },
              at: _parseInstant(_map(r)['at']),
            ),
        ],
      );
    } on BackupException {
      rethrow;
    } on Object catch (e) {
      // Cualquier campo que falte o tenga otro tipo.
      throw BackupException(BackupProblem.corrupt, '$e');
    }
  }

  /// Reemplaza todo el progreso por el del respaldo, en una sola transacción:
  /// si algo falla, queda el progreso de antes.
  static Future<void> restore(ProgressRepository repository, ProgressBackupData data) =>
      repository.transaction((store) async {
        await store.clear();
        for (final s in data.sessions) {
          await store.putSession(s);
        }
        for (final d in data.days) {
          await store.putDay(d);
        }
        await store.putStreak(data.streak);
        for (final MapEntry(:key, :value) in data.unlocked.entries) {
          await store.unlock(key, value);
        }
        for (final r in data.resets) {
          await store.putStatsResetAt(r.game, r.at, r.difficulty);
        }
      });
}

const _modes = {PuzzleMode.free: 'free', PuzzleMode.daily: 'daily', PuzzleMode.archive: 'archive'};
const _statuses = {
  SessionStatus.inProgress: 'in_progress',
  SessionStatus.won: 'won',
  SessionStatus.lost: 'lost',
  SessionStatus.abandoned: 'abandoned',
};

K _key<K>(Map<K, String> values, Object? stored) => values.entries.firstWhere((e) => e.value == stored).key;

String _instant(DateTime t) => t.toUtc().toIso8601String();

DateTime _parseInstant(Object? value) => DateTime.parse(value! as String).toUtc();

List<Object?> _list(Object? value) => value! as List<Object?>;

Map<String, Object?> _map(Object? value) => (value! as Map).cast<String, Object?>();

Map<String, Object?> _sessionToJson(SessionRecord s) => {
  'id': s.id,
  'game': s.game.value,
  'difficulty': s.difficulty.value,
  'mode': _modes[s.mode],
  'startedAt': _instant(s.startedAt.utc),
  'offsetMin': s.startedAt.offsetMinutes,
  'challengeDay': s.challengeDay?.toIso8601(),
  'seed': s.seedKey,
  'generatorVersion': s.generatorVersion,
  'wordsLanguage': s.wordsLanguage,
  'puzzle': s.puzzle,
  'state': s.state,
  'status': _statuses[s.status],
  'elapsedMs': s.elapsed.inMilliseconds,
  'freeHints': s.freeHints,
  'rewardedHints': s.rewardedHints,
  'rescued': s.rescued,
  'completedAt': s.completedAt == null ? null : _instant(s.completedAt!),
  'themeIds': s.themeIds,
  'flagsPlaced': s.flagsPlaced,
};

SessionRecord _sessionFromJson(Map<String, Object?> j) {
  final mode = _key(_modes, j['mode']);
  final challengeDay = j['challengeDay'] as String?;
  if (mode != PuzzleMode.free && challengeDay == null) {
    throw const BackupException(BackupProblem.corrupt, 'reto sin día');
  }
  return SessionRecord(
    id: j['id']! as String,
    game: GameId(j['game']! as String),
    difficulty: Difficulty(j['difficulty']! as String),
    mode: mode,
    startedAt: LocalNow(utc: _parseInstant(j['startedAt']), offsetMinutes: j['offsetMin']! as int),
    challengeDay: challengeDay == null ? null : LocalDay.parse(challengeDay),
    seedKey: j['seed']! as String,
    generatorVersion: j['generatorVersion']! as int,
    wordsLanguage: j['wordsLanguage'] as String?,
    puzzle: _map(j['puzzle']),
    state: _map(j['state']),
    status: _key(_statuses, j['status']),
    elapsed: Duration(milliseconds: j['elapsedMs']! as int),
    freeHints: j['freeHints']! as int,
    rewardedHints: j['rewardedHints']! as int,
    rescued: j['rescued']! as bool,
    completedAt: j['completedAt'] == null ? null : _parseInstant(j['completedAt']),
    themeIds: _list(j['themeIds']).cast<String>(),
    flagsPlaced: j['flagsPlaced'] as int?,
  );
}

List<String> _games(Set<GameId> games) => [for (final g in games) g.value]..sort();

Map<String, Object?> _dayToJson(DailyDay d) => {
  'day': d.day.toIso8601(),
  'offsetMin': d.offsetMinutes,
  'completed': _games(d.completed),
  'archiveCompleted': _games(d.archiveCompleted),
  'saverUsed': d.saverUsed,
};

DailyDay _dayFromJson(Map<String, Object?> j) => DailyDay(
  day: LocalDay.parse(j['day']! as String),
  offsetMinutes: j['offsetMin']! as int,
  completed: {for (final g in _list(j['completed'])) GameId(g! as String)},
  archiveCompleted: {for (final g in _list(j['archiveCompleted'])) GameId(g! as String)},
  saverUsed: j['saverUsed']! as bool,
);

Map<String, Object?> _streakToJson(StreakState s) => {
  'current': s.current,
  'best': s.best,
  'savers': s.savers,
  'lastCounted': s.lastCounted?.toIso8601(),
  'lastOffsetMin': s.lastOffsetMinutes,
  'previous': s.previous,
};

StreakState _streakFromJson(Map<String, Object?> j) => StreakState(
  current: j['current']! as int,
  best: j['best']! as int,
  savers: j['savers']! as int,
  lastCounted: j['lastCounted'] == null ? null : LocalDay.parse(j['lastCounted']! as String),
  lastOffsetMinutes: j['lastOffsetMin']! as int,
  previous: j['previous']! as int,
);
