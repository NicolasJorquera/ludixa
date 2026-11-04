import 'package:drift/drift.dart';

// Esquema v1 de la base de progreso (ADR 0007). Los nombres de columna se
// guardan en snake_case. Cambiar una tabla exige subir schemaVersion, una
// migración y un volcado nuevo en drift_schemas/.

/// Una partida, en curso o terminada. Única fuente de las estadísticas.
@DataClassName('SessionRow')
@TableIndex(name: 'sessions_game_level', columns: {#gameId, #difficulty})
@TableIndex(name: 'sessions_challenge', columns: {#challengeDate})
@TableIndex(name: 'sessions_status', columns: {#status})
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text()();
  TextColumn get difficulty => text()();

  /// free | daily | archive
  TextColumn get mode => text()();

  /// Inicio en milisegundos UTC y desfase de la zona en que se jugó.
  IntColumn get startedAtMs => integer()();
  IntColumn get startOffsetMin => integer()();

  /// Día del reto (AAAA-MM-DD) en los modos diario y archivo.
  TextColumn get challengeDate => text().nullable()();

  TextColumn get seed => text()();
  IntColumn get generatorVersion => integer()();
  TextColumn get wordsLang => text().nullable()();

  /// Puzzle y estado en el JSON de cada motor.
  TextColumn get puzzleJson => text()();
  TextColumn get stateJson => text()();

  /// in_progress | won | lost | abandoned
  TextColumn get status => text()();
  IntColumn get elapsedMs => integer()();
  IntColumn get hintsFree => integer()();
  IntColumn get hintsRewarded => integer()();
  BoolColumn get rescued => boolean()();
  IntColumn get completedAtMs => integer().nullable()();

  /// Temas de la sopa, como lista JSON.
  TextColumn get themeIdsJson => text()();
  IntColumn get flagsPlaced => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un día del calendario del reto.
@DataClassName('DailyDayRow')
class DailyDays extends Table {
  /// AAAA-MM-DD
  TextColumn get localDate => text()();
  IntColumn get tzOffsetMin => integer()();

  /// Ids de juego separados por comas: completados ese día (cuentan para la
  /// racha) y desde el archivo (marca hueca).
  TextColumn get completedGames => text()();
  TextColumn get archiveGames => text()();
  BoolColumn get saverUsed => boolean()();

  @override
  Set<Column> get primaryKey => {localDate};
}

/// La racha: una sola fila (id = 1).
@DataClassName('StreakRow')
class Streaks extends Table {
  // ignore: recursive_getters, la restricción CHECK se refiere a la propia columna.
  IntColumn get id => integer().check(id.equals(1))();
  IntColumn get current => integer()();
  IntColumn get best => integer()();
  IntColumn get savers => integer()();
  TextColumn get lastCountedDate => text().nullable()();
  IntColumn get lastOffsetMin => integer()();
  IntColumn get previous => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'streak';
}

/// Logros desbloqueados. El avance se calcula a partir de las partidas.
@DataClassName('AchievementRow')
class UnlockedAchievements extends Table {
  /// AchievementId.key: estable, no se cambia nunca.
  TextColumn get id => text()();
  IntColumn get unlockedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'achievements';
}

/// Reinicios de estadísticas, por juego (difficulty vacío) o por nivel.
@DataClassName('StatsResetRow')
class StatsResets extends Table {
  TextColumn get gameId => text()();
  TextColumn get difficulty => text()();
  IntColumn get resetAtMs => integer()();

  @override
  Set<Column> get primaryKey => {gameId, difficulty};
}
