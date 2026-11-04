// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta('startedAtMs');
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMinMeta = const VerificationMeta('startOffsetMin');
  @override
  late final GeneratedColumn<int> startOffsetMin = GeneratedColumn<int>(
    'start_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeDateMeta = const VerificationMeta('challengeDate');
  @override
  late final GeneratedColumn<String> challengeDate = GeneratedColumn<String>(
    'challenge_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<String> seed = GeneratedColumn<String>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatorVersionMeta = const VerificationMeta('generatorVersion');
  @override
  late final GeneratedColumn<int> generatorVersion = GeneratedColumn<int>(
    'generator_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordsLangMeta = const VerificationMeta('wordsLang');
  @override
  late final GeneratedColumn<String> wordsLang = GeneratedColumn<String>(
    'words_lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _puzzleJsonMeta = const VerificationMeta('puzzleJson');
  @override
  late final GeneratedColumn<String> puzzleJson = GeneratedColumn<String>(
    'puzzle_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta('stateJson');
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta('elapsedMs');
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsFreeMeta = const VerificationMeta('hintsFree');
  @override
  late final GeneratedColumn<int> hintsFree = GeneratedColumn<int>(
    'hints_free',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsRewardedMeta = const VerificationMeta('hintsRewarded');
  @override
  late final GeneratedColumn<int> hintsRewarded = GeneratedColumn<int>(
    'hints_rewarded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rescuedMeta = const VerificationMeta('rescued');
  @override
  late final GeneratedColumn<bool> rescued = GeneratedColumn<bool>(
    'rescued',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("rescued" IN (0, 1))'),
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta('completedAtMs');
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeIdsJsonMeta = const VerificationMeta('themeIdsJson');
  @override
  late final GeneratedColumn<String> themeIdsJson = GeneratedColumn<String>(
    'theme_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagsPlacedMeta = const VerificationMeta('flagsPlaced');
  @override
  late final GeneratedColumn<int> flagsPlaced = GeneratedColumn<int>(
    'flags_placed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    difficulty,
    mode,
    startedAtMs,
    startOffsetMin,
    challengeDate,
    seed,
    generatorVersion,
    wordsLang,
    puzzleJson,
    stateJson,
    status,
    elapsedMs,
    hintsFree,
    hintsRewarded,
    rescued,
    completedAtMs,
    themeIdsJson,
    flagsPlaced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SessionRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta, gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(_difficultyMeta, difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(_modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(_startedAtMsMeta, startedAtMs.isAcceptableOrUnknown(data['started_at_ms']!, _startedAtMsMeta));
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('start_offset_min')) {
      context.handle(
        _startOffsetMinMeta,
        startOffsetMin.isAcceptableOrUnknown(data['start_offset_min']!, _startOffsetMinMeta),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMinMeta);
    }
    if (data.containsKey('challenge_date')) {
      context.handle(
        _challengeDateMeta,
        challengeDate.isAcceptableOrUnknown(data['challenge_date']!, _challengeDateMeta),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(_seedMeta, seed.isAcceptableOrUnknown(data['seed']!, _seedMeta));
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('generator_version')) {
      context.handle(
        _generatorVersionMeta,
        generatorVersion.isAcceptableOrUnknown(data['generator_version']!, _generatorVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_generatorVersionMeta);
    }
    if (data.containsKey('words_lang')) {
      context.handle(_wordsLangMeta, wordsLang.isAcceptableOrUnknown(data['words_lang']!, _wordsLangMeta));
    }
    if (data.containsKey('puzzle_json')) {
      context.handle(_puzzleJsonMeta, puzzleJson.isAcceptableOrUnknown(data['puzzle_json']!, _puzzleJsonMeta));
    } else if (isInserting) {
      context.missing(_puzzleJsonMeta);
    }
    if (data.containsKey('state_json')) {
      context.handle(_stateJsonMeta, stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta));
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(_elapsedMsMeta, elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta));
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('hints_free')) {
      context.handle(_hintsFreeMeta, hintsFree.isAcceptableOrUnknown(data['hints_free']!, _hintsFreeMeta));
    } else if (isInserting) {
      context.missing(_hintsFreeMeta);
    }
    if (data.containsKey('hints_rewarded')) {
      context.handle(
        _hintsRewardedMeta,
        hintsRewarded.isAcceptableOrUnknown(data['hints_rewarded']!, _hintsRewardedMeta),
      );
    } else if (isInserting) {
      context.missing(_hintsRewardedMeta);
    }
    if (data.containsKey('rescued')) {
      context.handle(_rescuedMeta, rescued.isAcceptableOrUnknown(data['rescued']!, _rescuedMeta));
    } else if (isInserting) {
      context.missing(_rescuedMeta);
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(data['completed_at_ms']!, _completedAtMsMeta),
      );
    }
    if (data.containsKey('theme_ids_json')) {
      context.handle(_themeIdsJsonMeta, themeIdsJson.isAcceptableOrUnknown(data['theme_ids_json']!, _themeIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_themeIdsJsonMeta);
    }
    if (data.containsKey('flags_placed')) {
      context.handle(_flagsPlacedMeta, flagsPlaced.isAcceptableOrUnknown(data['flags_placed']!, _flagsPlacedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      gameId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      difficulty: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      mode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      startedAtMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}started_at_ms'])!,
      startOffsetMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}start_offset_min'])!,
      challengeDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}challenge_date']),
      seed: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}seed'])!,
      generatorVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generator_version'],
      )!,
      wordsLang: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}words_lang']),
      puzzleJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}puzzle_json'])!,
      stateJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}state_json'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      elapsedMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}elapsed_ms'])!,
      hintsFree: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}hints_free'])!,
      hintsRewarded: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}hints_rewarded'])!,
      rescued: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}rescued'])!,
      completedAtMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}completed_at_ms']),
      themeIdsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}theme_ids_json'])!,
      flagsPlaced: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}flags_placed']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String gameId;
  final String difficulty;

  /// free | daily | archive
  final String mode;

  /// Inicio en milisegundos UTC y desfase de la zona en que se jugó.
  final int startedAtMs;
  final int startOffsetMin;

  /// Día del reto (AAAA-MM-DD) en los modos diario y archivo.
  final String? challengeDate;
  final String seed;
  final int generatorVersion;
  final String? wordsLang;

  /// Puzzle y estado en el JSON de cada motor.
  final String puzzleJson;
  final String stateJson;

  /// in_progress | won | lost | abandoned
  final String status;
  final int elapsedMs;
  final int hintsFree;
  final int hintsRewarded;
  final bool rescued;
  final int? completedAtMs;

  /// Temas de la sopa, como lista JSON.
  final String themeIdsJson;
  final int? flagsPlaced;
  const SessionRow({
    required this.id,
    required this.gameId,
    required this.difficulty,
    required this.mode,
    required this.startedAtMs,
    required this.startOffsetMin,
    this.challengeDate,
    required this.seed,
    required this.generatorVersion,
    this.wordsLang,
    required this.puzzleJson,
    required this.stateJson,
    required this.status,
    required this.elapsedMs,
    required this.hintsFree,
    required this.hintsRewarded,
    required this.rescued,
    this.completedAtMs,
    required this.themeIdsJson,
    this.flagsPlaced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['difficulty'] = Variable<String>(difficulty);
    map['mode'] = Variable<String>(mode);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    map['start_offset_min'] = Variable<int>(startOffsetMin);
    if (!nullToAbsent || challengeDate != null) {
      map['challenge_date'] = Variable<String>(challengeDate);
    }
    map['seed'] = Variable<String>(seed);
    map['generator_version'] = Variable<int>(generatorVersion);
    if (!nullToAbsent || wordsLang != null) {
      map['words_lang'] = Variable<String>(wordsLang);
    }
    map['puzzle_json'] = Variable<String>(puzzleJson);
    map['state_json'] = Variable<String>(stateJson);
    map['status'] = Variable<String>(status);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['hints_free'] = Variable<int>(hintsFree);
    map['hints_rewarded'] = Variable<int>(hintsRewarded);
    map['rescued'] = Variable<bool>(rescued);
    if (!nullToAbsent || completedAtMs != null) {
      map['completed_at_ms'] = Variable<int>(completedAtMs);
    }
    map['theme_ids_json'] = Variable<String>(themeIdsJson);
    if (!nullToAbsent || flagsPlaced != null) {
      map['flags_placed'] = Variable<int>(flagsPlaced);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      difficulty: Value(difficulty),
      mode: Value(mode),
      startedAtMs: Value(startedAtMs),
      startOffsetMin: Value(startOffsetMin),
      challengeDate: challengeDate == null && nullToAbsent ? const Value.absent() : Value(challengeDate),
      seed: Value(seed),
      generatorVersion: Value(generatorVersion),
      wordsLang: wordsLang == null && nullToAbsent ? const Value.absent() : Value(wordsLang),
      puzzleJson: Value(puzzleJson),
      stateJson: Value(stateJson),
      status: Value(status),
      elapsedMs: Value(elapsedMs),
      hintsFree: Value(hintsFree),
      hintsRewarded: Value(hintsRewarded),
      rescued: Value(rescued),
      completedAtMs: completedAtMs == null && nullToAbsent ? const Value.absent() : Value(completedAtMs),
      themeIdsJson: Value(themeIdsJson),
      flagsPlaced: flagsPlaced == null && nullToAbsent ? const Value.absent() : Value(flagsPlaced),
    );
  }

  factory SessionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      mode: serializer.fromJson<String>(json['mode']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      startOffsetMin: serializer.fromJson<int>(json['startOffsetMin']),
      challengeDate: serializer.fromJson<String?>(json['challengeDate']),
      seed: serializer.fromJson<String>(json['seed']),
      generatorVersion: serializer.fromJson<int>(json['generatorVersion']),
      wordsLang: serializer.fromJson<String?>(json['wordsLang']),
      puzzleJson: serializer.fromJson<String>(json['puzzleJson']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
      status: serializer.fromJson<String>(json['status']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      hintsFree: serializer.fromJson<int>(json['hintsFree']),
      hintsRewarded: serializer.fromJson<int>(json['hintsRewarded']),
      rescued: serializer.fromJson<bool>(json['rescued']),
      completedAtMs: serializer.fromJson<int?>(json['completedAtMs']),
      themeIdsJson: serializer.fromJson<String>(json['themeIdsJson']),
      flagsPlaced: serializer.fromJson<int?>(json['flagsPlaced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'difficulty': serializer.toJson<String>(difficulty),
      'mode': serializer.toJson<String>(mode),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'startOffsetMin': serializer.toJson<int>(startOffsetMin),
      'challengeDate': serializer.toJson<String?>(challengeDate),
      'seed': serializer.toJson<String>(seed),
      'generatorVersion': serializer.toJson<int>(generatorVersion),
      'wordsLang': serializer.toJson<String?>(wordsLang),
      'puzzleJson': serializer.toJson<String>(puzzleJson),
      'stateJson': serializer.toJson<String>(stateJson),
      'status': serializer.toJson<String>(status),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'hintsFree': serializer.toJson<int>(hintsFree),
      'hintsRewarded': serializer.toJson<int>(hintsRewarded),
      'rescued': serializer.toJson<bool>(rescued),
      'completedAtMs': serializer.toJson<int?>(completedAtMs),
      'themeIdsJson': serializer.toJson<String>(themeIdsJson),
      'flagsPlaced': serializer.toJson<int?>(flagsPlaced),
    };
  }

  SessionRow copyWith({
    String? id,
    String? gameId,
    String? difficulty,
    String? mode,
    int? startedAtMs,
    int? startOffsetMin,
    Value<String?> challengeDate = const Value.absent(),
    String? seed,
    int? generatorVersion,
    Value<String?> wordsLang = const Value.absent(),
    String? puzzleJson,
    String? stateJson,
    String? status,
    int? elapsedMs,
    int? hintsFree,
    int? hintsRewarded,
    bool? rescued,
    Value<int?> completedAtMs = const Value.absent(),
    String? themeIdsJson,
    Value<int?> flagsPlaced = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    difficulty: difficulty ?? this.difficulty,
    mode: mode ?? this.mode,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    startOffsetMin: startOffsetMin ?? this.startOffsetMin,
    challengeDate: challengeDate.present ? challengeDate.value : this.challengeDate,
    seed: seed ?? this.seed,
    generatorVersion: generatorVersion ?? this.generatorVersion,
    wordsLang: wordsLang.present ? wordsLang.value : this.wordsLang,
    puzzleJson: puzzleJson ?? this.puzzleJson,
    stateJson: stateJson ?? this.stateJson,
    status: status ?? this.status,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    hintsFree: hintsFree ?? this.hintsFree,
    hintsRewarded: hintsRewarded ?? this.hintsRewarded,
    rescued: rescued ?? this.rescued,
    completedAtMs: completedAtMs.present ? completedAtMs.value : this.completedAtMs,
    themeIdsJson: themeIdsJson ?? this.themeIdsJson,
    flagsPlaced: flagsPlaced.present ? flagsPlaced.value : this.flagsPlaced,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      difficulty: data.difficulty.present ? data.difficulty.value : this.difficulty,
      mode: data.mode.present ? data.mode.value : this.mode,
      startedAtMs: data.startedAtMs.present ? data.startedAtMs.value : this.startedAtMs,
      startOffsetMin: data.startOffsetMin.present ? data.startOffsetMin.value : this.startOffsetMin,
      challengeDate: data.challengeDate.present ? data.challengeDate.value : this.challengeDate,
      seed: data.seed.present ? data.seed.value : this.seed,
      generatorVersion: data.generatorVersion.present ? data.generatorVersion.value : this.generatorVersion,
      wordsLang: data.wordsLang.present ? data.wordsLang.value : this.wordsLang,
      puzzleJson: data.puzzleJson.present ? data.puzzleJson.value : this.puzzleJson,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      status: data.status.present ? data.status.value : this.status,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      hintsFree: data.hintsFree.present ? data.hintsFree.value : this.hintsFree,
      hintsRewarded: data.hintsRewarded.present ? data.hintsRewarded.value : this.hintsRewarded,
      rescued: data.rescued.present ? data.rescued.value : this.rescued,
      completedAtMs: data.completedAtMs.present ? data.completedAtMs.value : this.completedAtMs,
      themeIdsJson: data.themeIdsJson.present ? data.themeIdsJson.value : this.themeIdsJson,
      flagsPlaced: data.flagsPlaced.present ? data.flagsPlaced.value : this.flagsPlaced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('difficulty: $difficulty, ')
          ..write('mode: $mode, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('startOffsetMin: $startOffsetMin, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('seed: $seed, ')
          ..write('generatorVersion: $generatorVersion, ')
          ..write('wordsLang: $wordsLang, ')
          ..write('puzzleJson: $puzzleJson, ')
          ..write('stateJson: $stateJson, ')
          ..write('status: $status, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('hintsFree: $hintsFree, ')
          ..write('hintsRewarded: $hintsRewarded, ')
          ..write('rescued: $rescued, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('themeIdsJson: $themeIdsJson, ')
          ..write('flagsPlaced: $flagsPlaced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    difficulty,
    mode,
    startedAtMs,
    startOffsetMin,
    challengeDate,
    seed,
    generatorVersion,
    wordsLang,
    puzzleJson,
    stateJson,
    status,
    elapsedMs,
    hintsFree,
    hintsRewarded,
    rescued,
    completedAtMs,
    themeIdsJson,
    flagsPlaced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.difficulty == this.difficulty &&
          other.mode == this.mode &&
          other.startedAtMs == this.startedAtMs &&
          other.startOffsetMin == this.startOffsetMin &&
          other.challengeDate == this.challengeDate &&
          other.seed == this.seed &&
          other.generatorVersion == this.generatorVersion &&
          other.wordsLang == this.wordsLang &&
          other.puzzleJson == this.puzzleJson &&
          other.stateJson == this.stateJson &&
          other.status == this.status &&
          other.elapsedMs == this.elapsedMs &&
          other.hintsFree == this.hintsFree &&
          other.hintsRewarded == this.hintsRewarded &&
          other.rescued == this.rescued &&
          other.completedAtMs == this.completedAtMs &&
          other.themeIdsJson == this.themeIdsJson &&
          other.flagsPlaced == this.flagsPlaced);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> difficulty;
  final Value<String> mode;
  final Value<int> startedAtMs;
  final Value<int> startOffsetMin;
  final Value<String?> challengeDate;
  final Value<String> seed;
  final Value<int> generatorVersion;
  final Value<String?> wordsLang;
  final Value<String> puzzleJson;
  final Value<String> stateJson;
  final Value<String> status;
  final Value<int> elapsedMs;
  final Value<int> hintsFree;
  final Value<int> hintsRewarded;
  final Value<bool> rescued;
  final Value<int?> completedAtMs;
  final Value<String> themeIdsJson;
  final Value<int?> flagsPlaced;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mode = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.startOffsetMin = const Value.absent(),
    this.challengeDate = const Value.absent(),
    this.seed = const Value.absent(),
    this.generatorVersion = const Value.absent(),
    this.wordsLang = const Value.absent(),
    this.puzzleJson = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.status = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.hintsFree = const Value.absent(),
    this.hintsRewarded = const Value.absent(),
    this.rescued = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.themeIdsJson = const Value.absent(),
    this.flagsPlaced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String gameId,
    required String difficulty,
    required String mode,
    required int startedAtMs,
    required int startOffsetMin,
    this.challengeDate = const Value.absent(),
    required String seed,
    required int generatorVersion,
    this.wordsLang = const Value.absent(),
    required String puzzleJson,
    required String stateJson,
    required String status,
    required int elapsedMs,
    required int hintsFree,
    required int hintsRewarded,
    required bool rescued,
    this.completedAtMs = const Value.absent(),
    required String themeIdsJson,
    this.flagsPlaced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       difficulty = Value(difficulty),
       mode = Value(mode),
       startedAtMs = Value(startedAtMs),
       startOffsetMin = Value(startOffsetMin),
       seed = Value(seed),
       generatorVersion = Value(generatorVersion),
       puzzleJson = Value(puzzleJson),
       stateJson = Value(stateJson),
       status = Value(status),
       elapsedMs = Value(elapsedMs),
       hintsFree = Value(hintsFree),
       hintsRewarded = Value(hintsRewarded),
       rescued = Value(rescued),
       themeIdsJson = Value(themeIdsJson);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? difficulty,
    Expression<String>? mode,
    Expression<int>? startedAtMs,
    Expression<int>? startOffsetMin,
    Expression<String>? challengeDate,
    Expression<String>? seed,
    Expression<int>? generatorVersion,
    Expression<String>? wordsLang,
    Expression<String>? puzzleJson,
    Expression<String>? stateJson,
    Expression<String>? status,
    Expression<int>? elapsedMs,
    Expression<int>? hintsFree,
    Expression<int>? hintsRewarded,
    Expression<bool>? rescued,
    Expression<int>? completedAtMs,
    Expression<String>? themeIdsJson,
    Expression<int>? flagsPlaced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (difficulty != null) 'difficulty': difficulty,
      if (mode != null) 'mode': mode,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (startOffsetMin != null) 'start_offset_min': startOffsetMin,
      if (challengeDate != null) 'challenge_date': challengeDate,
      if (seed != null) 'seed': seed,
      if (generatorVersion != null) 'generator_version': generatorVersion,
      if (wordsLang != null) 'words_lang': wordsLang,
      if (puzzleJson != null) 'puzzle_json': puzzleJson,
      if (stateJson != null) 'state_json': stateJson,
      if (status != null) 'status': status,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (hintsFree != null) 'hints_free': hintsFree,
      if (hintsRewarded != null) 'hints_rewarded': hintsRewarded,
      if (rescued != null) 'rescued': rescued,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (themeIdsJson != null) 'theme_ids_json': themeIdsJson,
      if (flagsPlaced != null) 'flags_placed': flagsPlaced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? difficulty,
    Value<String>? mode,
    Value<int>? startedAtMs,
    Value<int>? startOffsetMin,
    Value<String?>? challengeDate,
    Value<String>? seed,
    Value<int>? generatorVersion,
    Value<String?>? wordsLang,
    Value<String>? puzzleJson,
    Value<String>? stateJson,
    Value<String>? status,
    Value<int>? elapsedMs,
    Value<int>? hintsFree,
    Value<int>? hintsRewarded,
    Value<bool>? rescued,
    Value<int?>? completedAtMs,
    Value<String>? themeIdsJson,
    Value<int?>? flagsPlaced,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      difficulty: difficulty ?? this.difficulty,
      mode: mode ?? this.mode,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      startOffsetMin: startOffsetMin ?? this.startOffsetMin,
      challengeDate: challengeDate ?? this.challengeDate,
      seed: seed ?? this.seed,
      generatorVersion: generatorVersion ?? this.generatorVersion,
      wordsLang: wordsLang ?? this.wordsLang,
      puzzleJson: puzzleJson ?? this.puzzleJson,
      stateJson: stateJson ?? this.stateJson,
      status: status ?? this.status,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      hintsFree: hintsFree ?? this.hintsFree,
      hintsRewarded: hintsRewarded ?? this.hintsRewarded,
      rescued: rescued ?? this.rescued,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      themeIdsJson: themeIdsJson ?? this.themeIdsJson,
      flagsPlaced: flagsPlaced ?? this.flagsPlaced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (startOffsetMin.present) {
      map['start_offset_min'] = Variable<int>(startOffsetMin.value);
    }
    if (challengeDate.present) {
      map['challenge_date'] = Variable<String>(challengeDate.value);
    }
    if (seed.present) {
      map['seed'] = Variable<String>(seed.value);
    }
    if (generatorVersion.present) {
      map['generator_version'] = Variable<int>(generatorVersion.value);
    }
    if (wordsLang.present) {
      map['words_lang'] = Variable<String>(wordsLang.value);
    }
    if (puzzleJson.present) {
      map['puzzle_json'] = Variable<String>(puzzleJson.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (hintsFree.present) {
      map['hints_free'] = Variable<int>(hintsFree.value);
    }
    if (hintsRewarded.present) {
      map['hints_rewarded'] = Variable<int>(hintsRewarded.value);
    }
    if (rescued.present) {
      map['rescued'] = Variable<bool>(rescued.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (themeIdsJson.present) {
      map['theme_ids_json'] = Variable<String>(themeIdsJson.value);
    }
    if (flagsPlaced.present) {
      map['flags_placed'] = Variable<int>(flagsPlaced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('difficulty: $difficulty, ')
          ..write('mode: $mode, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('startOffsetMin: $startOffsetMin, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('seed: $seed, ')
          ..write('generatorVersion: $generatorVersion, ')
          ..write('wordsLang: $wordsLang, ')
          ..write('puzzleJson: $puzzleJson, ')
          ..write('stateJson: $stateJson, ')
          ..write('status: $status, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('hintsFree: $hintsFree, ')
          ..write('hintsRewarded: $hintsRewarded, ')
          ..write('rescued: $rescued, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('themeIdsJson: $themeIdsJson, ')
          ..write('flagsPlaced: $flagsPlaced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyDaysTable extends DailyDays with TableInfo<$DailyDaysTable, DailyDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localDateMeta = const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinMeta = const VerificationMeta('tzOffsetMin');
  @override
  late final GeneratedColumn<int> tzOffsetMin = GeneratedColumn<int>(
    'tz_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedGamesMeta = const VerificationMeta('completedGames');
  @override
  late final GeneratedColumn<String> completedGames = GeneratedColumn<String>(
    'completed_games',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archiveGamesMeta = const VerificationMeta('archiveGames');
  @override
  late final GeneratedColumn<String> archiveGames = GeneratedColumn<String>(
    'archive_games',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saverUsedMeta = const VerificationMeta('saverUsed');
  @override
  late final GeneratedColumn<bool> saverUsed = GeneratedColumn<bool>(
    'saver_used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("saver_used" IN (0, 1))'),
  );
  @override
  List<GeneratedColumn> get $columns => [localDate, tzOffsetMin, completedGames, archiveGames, saverUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_days';
  @override
  VerificationContext validateIntegrity(Insertable<DailyDayRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_date')) {
      context.handle(_localDateMeta, localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta));
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('tz_offset_min')) {
      context.handle(_tzOffsetMinMeta, tzOffsetMin.isAcceptableOrUnknown(data['tz_offset_min']!, _tzOffsetMinMeta));
    } else if (isInserting) {
      context.missing(_tzOffsetMinMeta);
    }
    if (data.containsKey('completed_games')) {
      context.handle(
        _completedGamesMeta,
        completedGames.isAcceptableOrUnknown(data['completed_games']!, _completedGamesMeta),
      );
    } else if (isInserting) {
      context.missing(_completedGamesMeta);
    }
    if (data.containsKey('archive_games')) {
      context.handle(_archiveGamesMeta, archiveGames.isAcceptableOrUnknown(data['archive_games']!, _archiveGamesMeta));
    } else if (isInserting) {
      context.missing(_archiveGamesMeta);
    }
    if (data.containsKey('saver_used')) {
      context.handle(_saverUsedMeta, saverUsed.isAcceptableOrUnknown(data['saver_used']!, _saverUsedMeta));
    } else if (isInserting) {
      context.missing(_saverUsedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  DailyDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyDayRow(
      localDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}local_date'])!,
      tzOffsetMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tz_offset_min'])!,
      completedGames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_games'],
      )!,
      archiveGames: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}archive_games'])!,
      saverUsed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}saver_used'])!,
    );
  }

  @override
  $DailyDaysTable createAlias(String alias) {
    return $DailyDaysTable(attachedDatabase, alias);
  }
}

class DailyDayRow extends DataClass implements Insertable<DailyDayRow> {
  /// AAAA-MM-DD
  final String localDate;
  final int tzOffsetMin;

  /// Ids de juego separados por comas: completados ese día (cuentan para la
  /// racha) y desde el archivo (marca hueca).
  final String completedGames;
  final String archiveGames;
  final bool saverUsed;
  const DailyDayRow({
    required this.localDate,
    required this.tzOffsetMin,
    required this.completedGames,
    required this.archiveGames,
    required this.saverUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_date'] = Variable<String>(localDate);
    map['tz_offset_min'] = Variable<int>(tzOffsetMin);
    map['completed_games'] = Variable<String>(completedGames);
    map['archive_games'] = Variable<String>(archiveGames);
    map['saver_used'] = Variable<bool>(saverUsed);
    return map;
  }

  DailyDaysCompanion toCompanion(bool nullToAbsent) {
    return DailyDaysCompanion(
      localDate: Value(localDate),
      tzOffsetMin: Value(tzOffsetMin),
      completedGames: Value(completedGames),
      archiveGames: Value(archiveGames),
      saverUsed: Value(saverUsed),
    );
  }

  factory DailyDayRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyDayRow(
      localDate: serializer.fromJson<String>(json['localDate']),
      tzOffsetMin: serializer.fromJson<int>(json['tzOffsetMin']),
      completedGames: serializer.fromJson<String>(json['completedGames']),
      archiveGames: serializer.fromJson<String>(json['archiveGames']),
      saverUsed: serializer.fromJson<bool>(json['saverUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<String>(localDate),
      'tzOffsetMin': serializer.toJson<int>(tzOffsetMin),
      'completedGames': serializer.toJson<String>(completedGames),
      'archiveGames': serializer.toJson<String>(archiveGames),
      'saverUsed': serializer.toJson<bool>(saverUsed),
    };
  }

  DailyDayRow copyWith({
    String? localDate,
    int? tzOffsetMin,
    String? completedGames,
    String? archiveGames,
    bool? saverUsed,
  }) => DailyDayRow(
    localDate: localDate ?? this.localDate,
    tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
    completedGames: completedGames ?? this.completedGames,
    archiveGames: archiveGames ?? this.archiveGames,
    saverUsed: saverUsed ?? this.saverUsed,
  );
  DailyDayRow copyWithCompanion(DailyDaysCompanion data) {
    return DailyDayRow(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      tzOffsetMin: data.tzOffsetMin.present ? data.tzOffsetMin.value : this.tzOffsetMin,
      completedGames: data.completedGames.present ? data.completedGames.value : this.completedGames,
      archiveGames: data.archiveGames.present ? data.archiveGames.value : this.archiveGames,
      saverUsed: data.saverUsed.present ? data.saverUsed.value : this.saverUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyDayRow(')
          ..write('localDate: $localDate, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('completedGames: $completedGames, ')
          ..write('archiveGames: $archiveGames, ')
          ..write('saverUsed: $saverUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localDate, tzOffsetMin, completedGames, archiveGames, saverUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyDayRow &&
          other.localDate == this.localDate &&
          other.tzOffsetMin == this.tzOffsetMin &&
          other.completedGames == this.completedGames &&
          other.archiveGames == this.archiveGames &&
          other.saverUsed == this.saverUsed);
}

class DailyDaysCompanion extends UpdateCompanion<DailyDayRow> {
  final Value<String> localDate;
  final Value<int> tzOffsetMin;
  final Value<String> completedGames;
  final Value<String> archiveGames;
  final Value<bool> saverUsed;
  final Value<int> rowid;
  const DailyDaysCompanion({
    this.localDate = const Value.absent(),
    this.tzOffsetMin = const Value.absent(),
    this.completedGames = const Value.absent(),
    this.archiveGames = const Value.absent(),
    this.saverUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyDaysCompanion.insert({
    required String localDate,
    required int tzOffsetMin,
    required String completedGames,
    required String archiveGames,
    required bool saverUsed,
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate),
       tzOffsetMin = Value(tzOffsetMin),
       completedGames = Value(completedGames),
       archiveGames = Value(archiveGames),
       saverUsed = Value(saverUsed);
  static Insertable<DailyDayRow> custom({
    Expression<String>? localDate,
    Expression<int>? tzOffsetMin,
    Expression<String>? completedGames,
    Expression<String>? archiveGames,
    Expression<bool>? saverUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (tzOffsetMin != null) 'tz_offset_min': tzOffsetMin,
      if (completedGames != null) 'completed_games': completedGames,
      if (archiveGames != null) 'archive_games': archiveGames,
      if (saverUsed != null) 'saver_used': saverUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyDaysCompanion copyWith({
    Value<String>? localDate,
    Value<int>? tzOffsetMin,
    Value<String>? completedGames,
    Value<String>? archiveGames,
    Value<bool>? saverUsed,
    Value<int>? rowid,
  }) {
    return DailyDaysCompanion(
      localDate: localDate ?? this.localDate,
      tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
      completedGames: completedGames ?? this.completedGames,
      archiveGames: archiveGames ?? this.archiveGames,
      saverUsed: saverUsed ?? this.saverUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (tzOffsetMin.present) {
      map['tz_offset_min'] = Variable<int>(tzOffsetMin.value);
    }
    if (completedGames.present) {
      map['completed_games'] = Variable<String>(completedGames.value);
    }
    if (archiveGames.present) {
      map['archive_games'] = Variable<String>(archiveGames.value);
    }
    if (saverUsed.present) {
      map['saver_used'] = Variable<bool>(saverUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyDaysCompanion(')
          ..write('localDate: $localDate, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('completedGames: $completedGames, ')
          ..write('archiveGames: $archiveGames, ')
          ..write('saverUsed: $saverUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreaksTable extends Streaks with TableInfo<$StreaksTable, StreakRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentMeta = const VerificationMeta('current');
  @override
  late final GeneratedColumn<int> current = GeneratedColumn<int>(
    'current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestMeta = const VerificationMeta('best');
  @override
  late final GeneratedColumn<int> best = GeneratedColumn<int>(
    'best',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saversMeta = const VerificationMeta('savers');
  @override
  late final GeneratedColumn<int> savers = GeneratedColumn<int>(
    'savers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCountedDateMeta = const VerificationMeta('lastCountedDate');
  @override
  late final GeneratedColumn<String> lastCountedDate = GeneratedColumn<String>(
    'last_counted_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOffsetMinMeta = const VerificationMeta('lastOffsetMin');
  @override
  late final GeneratedColumn<int> lastOffsetMin = GeneratedColumn<int>(
    'last_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousMeta = const VerificationMeta('previous');
  @override
  late final GeneratedColumn<int> previous = GeneratedColumn<int>(
    'previous',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, current, best, savers, lastCountedDate, lastOffsetMin, previous];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak';
  @override
  VerificationContext validateIntegrity(Insertable<StreakRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current')) {
      context.handle(_currentMeta, current.isAcceptableOrUnknown(data['current']!, _currentMeta));
    } else if (isInserting) {
      context.missing(_currentMeta);
    }
    if (data.containsKey('best')) {
      context.handle(_bestMeta, best.isAcceptableOrUnknown(data['best']!, _bestMeta));
    } else if (isInserting) {
      context.missing(_bestMeta);
    }
    if (data.containsKey('savers')) {
      context.handle(_saversMeta, savers.isAcceptableOrUnknown(data['savers']!, _saversMeta));
    } else if (isInserting) {
      context.missing(_saversMeta);
    }
    if (data.containsKey('last_counted_date')) {
      context.handle(
        _lastCountedDateMeta,
        lastCountedDate.isAcceptableOrUnknown(data['last_counted_date']!, _lastCountedDateMeta),
      );
    }
    if (data.containsKey('last_offset_min')) {
      context.handle(
        _lastOffsetMinMeta,
        lastOffsetMin.isAcceptableOrUnknown(data['last_offset_min']!, _lastOffsetMinMeta),
      );
    } else if (isInserting) {
      context.missing(_lastOffsetMinMeta);
    }
    if (data.containsKey('previous')) {
      context.handle(_previousMeta, previous.isAcceptableOrUnknown(data['previous']!, _previousMeta));
    } else if (isInserting) {
      context.missing(_previousMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      current: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}current'])!,
      best: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}best'])!,
      savers: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}savers'])!,
      lastCountedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_counted_date'],
      ),
      lastOffsetMin: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_offset_min'])!,
      previous: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}previous'])!,
    );
  }

  @override
  $StreaksTable createAlias(String alias) {
    return $StreaksTable(attachedDatabase, alias);
  }
}

class StreakRow extends DataClass implements Insertable<StreakRow> {
  final int id;
  final int current;
  final int best;
  final int savers;
  final String? lastCountedDate;
  final int lastOffsetMin;
  final int previous;
  const StreakRow({
    required this.id,
    required this.current,
    required this.best,
    required this.savers,
    this.lastCountedDate,
    required this.lastOffsetMin,
    required this.previous,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current'] = Variable<int>(current);
    map['best'] = Variable<int>(best);
    map['savers'] = Variable<int>(savers);
    if (!nullToAbsent || lastCountedDate != null) {
      map['last_counted_date'] = Variable<String>(lastCountedDate);
    }
    map['last_offset_min'] = Variable<int>(lastOffsetMin);
    map['previous'] = Variable<int>(previous);
    return map;
  }

  StreaksCompanion toCompanion(bool nullToAbsent) {
    return StreaksCompanion(
      id: Value(id),
      current: Value(current),
      best: Value(best),
      savers: Value(savers),
      lastCountedDate: lastCountedDate == null && nullToAbsent ? const Value.absent() : Value(lastCountedDate),
      lastOffsetMin: Value(lastOffsetMin),
      previous: Value(previous),
    );
  }

  factory StreakRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakRow(
      id: serializer.fromJson<int>(json['id']),
      current: serializer.fromJson<int>(json['current']),
      best: serializer.fromJson<int>(json['best']),
      savers: serializer.fromJson<int>(json['savers']),
      lastCountedDate: serializer.fromJson<String?>(json['lastCountedDate']),
      lastOffsetMin: serializer.fromJson<int>(json['lastOffsetMin']),
      previous: serializer.fromJson<int>(json['previous']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'current': serializer.toJson<int>(current),
      'best': serializer.toJson<int>(best),
      'savers': serializer.toJson<int>(savers),
      'lastCountedDate': serializer.toJson<String?>(lastCountedDate),
      'lastOffsetMin': serializer.toJson<int>(lastOffsetMin),
      'previous': serializer.toJson<int>(previous),
    };
  }

  StreakRow copyWith({
    int? id,
    int? current,
    int? best,
    int? savers,
    Value<String?> lastCountedDate = const Value.absent(),
    int? lastOffsetMin,
    int? previous,
  }) => StreakRow(
    id: id ?? this.id,
    current: current ?? this.current,
    best: best ?? this.best,
    savers: savers ?? this.savers,
    lastCountedDate: lastCountedDate.present ? lastCountedDate.value : this.lastCountedDate,
    lastOffsetMin: lastOffsetMin ?? this.lastOffsetMin,
    previous: previous ?? this.previous,
  );
  StreakRow copyWithCompanion(StreaksCompanion data) {
    return StreakRow(
      id: data.id.present ? data.id.value : this.id,
      current: data.current.present ? data.current.value : this.current,
      best: data.best.present ? data.best.value : this.best,
      savers: data.savers.present ? data.savers.value : this.savers,
      lastCountedDate: data.lastCountedDate.present ? data.lastCountedDate.value : this.lastCountedDate,
      lastOffsetMin: data.lastOffsetMin.present ? data.lastOffsetMin.value : this.lastOffsetMin,
      previous: data.previous.present ? data.previous.value : this.previous,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakRow(')
          ..write('id: $id, ')
          ..write('current: $current, ')
          ..write('best: $best, ')
          ..write('savers: $savers, ')
          ..write('lastCountedDate: $lastCountedDate, ')
          ..write('lastOffsetMin: $lastOffsetMin, ')
          ..write('previous: $previous')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, current, best, savers, lastCountedDate, lastOffsetMin, previous);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakRow &&
          other.id == this.id &&
          other.current == this.current &&
          other.best == this.best &&
          other.savers == this.savers &&
          other.lastCountedDate == this.lastCountedDate &&
          other.lastOffsetMin == this.lastOffsetMin &&
          other.previous == this.previous);
}

class StreaksCompanion extends UpdateCompanion<StreakRow> {
  final Value<int> id;
  final Value<int> current;
  final Value<int> best;
  final Value<int> savers;
  final Value<String?> lastCountedDate;
  final Value<int> lastOffsetMin;
  final Value<int> previous;
  const StreaksCompanion({
    this.id = const Value.absent(),
    this.current = const Value.absent(),
    this.best = const Value.absent(),
    this.savers = const Value.absent(),
    this.lastCountedDate = const Value.absent(),
    this.lastOffsetMin = const Value.absent(),
    this.previous = const Value.absent(),
  });
  StreaksCompanion.insert({
    this.id = const Value.absent(),
    required int current,
    required int best,
    required int savers,
    this.lastCountedDate = const Value.absent(),
    required int lastOffsetMin,
    required int previous,
  }) : current = Value(current),
       best = Value(best),
       savers = Value(savers),
       lastOffsetMin = Value(lastOffsetMin),
       previous = Value(previous);
  static Insertable<StreakRow> custom({
    Expression<int>? id,
    Expression<int>? current,
    Expression<int>? best,
    Expression<int>? savers,
    Expression<String>? lastCountedDate,
    Expression<int>? lastOffsetMin,
    Expression<int>? previous,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (current != null) 'current': current,
      if (best != null) 'best': best,
      if (savers != null) 'savers': savers,
      if (lastCountedDate != null) 'last_counted_date': lastCountedDate,
      if (lastOffsetMin != null) 'last_offset_min': lastOffsetMin,
      if (previous != null) 'previous': previous,
    });
  }

  StreaksCompanion copyWith({
    Value<int>? id,
    Value<int>? current,
    Value<int>? best,
    Value<int>? savers,
    Value<String?>? lastCountedDate,
    Value<int>? lastOffsetMin,
    Value<int>? previous,
  }) {
    return StreaksCompanion(
      id: id ?? this.id,
      current: current ?? this.current,
      best: best ?? this.best,
      savers: savers ?? this.savers,
      lastCountedDate: lastCountedDate ?? this.lastCountedDate,
      lastOffsetMin: lastOffsetMin ?? this.lastOffsetMin,
      previous: previous ?? this.previous,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (current.present) {
      map['current'] = Variable<int>(current.value);
    }
    if (best.present) {
      map['best'] = Variable<int>(best.value);
    }
    if (savers.present) {
      map['savers'] = Variable<int>(savers.value);
    }
    if (lastCountedDate.present) {
      map['last_counted_date'] = Variable<String>(lastCountedDate.value);
    }
    if (lastOffsetMin.present) {
      map['last_offset_min'] = Variable<int>(lastOffsetMin.value);
    }
    if (previous.present) {
      map['previous'] = Variable<int>(previous.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreaksCompanion(')
          ..write('id: $id, ')
          ..write('current: $current, ')
          ..write('best: $best, ')
          ..write('savers: $savers, ')
          ..write('lastCountedDate: $lastCountedDate, ')
          ..write('lastOffsetMin: $lastOffsetMin, ')
          ..write('previous: $previous')
          ..write(')'))
        .toString();
  }
}

class $UnlockedAchievementsTable extends UnlockedAchievements
    with TableInfo<$UnlockedAchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnlockedAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMsMeta = const VerificationMeta('unlockedAtMs');
  @override
  late final GeneratedColumn<int> unlockedAtMs = GeneratedColumn<int>(
    'unlocked_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, unlockedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<AchievementRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unlocked_at_ms')) {
      context.handle(_unlockedAtMsMeta, unlockedAtMs.isAcceptableOrUnknown(data['unlocked_at_ms']!, _unlockedAtMsMeta));
    } else if (isInserting) {
      context.missing(_unlockedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      unlockedAtMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}unlocked_at_ms'])!,
    );
  }

  @override
  $UnlockedAchievementsTable createAlias(String alias) {
    return $UnlockedAchievementsTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  /// AchievementId.key: estable, no se cambia nunca.
  final String id;
  final int unlockedAtMs;
  const AchievementRow({required this.id, required this.unlockedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unlocked_at_ms'] = Variable<int>(unlockedAtMs);
    return map;
  }

  UnlockedAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UnlockedAchievementsCompanion(id: Value(id), unlockedAtMs: Value(unlockedAtMs));
  }

  factory AchievementRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      id: serializer.fromJson<String>(json['id']),
      unlockedAtMs: serializer.fromJson<int>(json['unlockedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<String>(id), 'unlockedAtMs': serializer.toJson<int>(unlockedAtMs)};
  }

  AchievementRow copyWith({String? id, int? unlockedAtMs}) =>
      AchievementRow(id: id ?? this.id, unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs);
  AchievementRow copyWithCompanion(UnlockedAchievementsCompanion data) {
    return AchievementRow(
      id: data.id.present ? data.id.value : this.id,
      unlockedAtMs: data.unlockedAtMs.present ? data.unlockedAtMs.value : this.unlockedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('id: $id, ')
          ..write('unlockedAtMs: $unlockedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unlockedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow && other.id == this.id && other.unlockedAtMs == this.unlockedAtMs);
}

class UnlockedAchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> id;
  final Value<int> unlockedAtMs;
  final Value<int> rowid;
  const UnlockedAchievementsCompanion({
    this.id = const Value.absent(),
    this.unlockedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnlockedAchievementsCompanion.insert({
    required String id,
    required int unlockedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unlockedAtMs = Value(unlockedAtMs);
  static Insertable<AchievementRow> custom({
    Expression<String>? id,
    Expression<int>? unlockedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unlockedAtMs != null) 'unlocked_at_ms': unlockedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnlockedAchievementsCompanion copyWith({Value<String>? id, Value<int>? unlockedAtMs, Value<int>? rowid}) {
    return UnlockedAchievementsCompanion(
      id: id ?? this.id,
      unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unlockedAtMs.present) {
      map['unlocked_at_ms'] = Variable<int>(unlockedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('unlockedAtMs: $unlockedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsResetsTable extends StatsResets with TableInfo<$StatsResetsTable, StatsResetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsResetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resetAtMsMeta = const VerificationMeta('resetAtMs');
  @override
  late final GeneratedColumn<int> resetAtMs = GeneratedColumn<int>(
    'reset_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, difficulty, resetAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_resets';
  @override
  VerificationContext validateIntegrity(Insertable<StatsResetRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta, gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(_difficultyMeta, difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('reset_at_ms')) {
      context.handle(_resetAtMsMeta, resetAtMs.isAcceptableOrUnknown(data['reset_at_ms']!, _resetAtMsMeta));
    } else if (isInserting) {
      context.missing(_resetAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, difficulty};
  @override
  StatsResetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsResetRow(
      gameId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      difficulty: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      resetAtMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reset_at_ms'])!,
    );
  }

  @override
  $StatsResetsTable createAlias(String alias) {
    return $StatsResetsTable(attachedDatabase, alias);
  }
}

class StatsResetRow extends DataClass implements Insertable<StatsResetRow> {
  final String gameId;
  final String difficulty;
  final int resetAtMs;
  const StatsResetRow({required this.gameId, required this.difficulty, required this.resetAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['difficulty'] = Variable<String>(difficulty);
    map['reset_at_ms'] = Variable<int>(resetAtMs);
    return map;
  }

  StatsResetsCompanion toCompanion(bool nullToAbsent) {
    return StatsResetsCompanion(gameId: Value(gameId), difficulty: Value(difficulty), resetAtMs: Value(resetAtMs));
  }

  factory StatsResetRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsResetRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      resetAtMs: serializer.fromJson<int>(json['resetAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'difficulty': serializer.toJson<String>(difficulty),
      'resetAtMs': serializer.toJson<int>(resetAtMs),
    };
  }

  StatsResetRow copyWith({String? gameId, String? difficulty, int? resetAtMs}) => StatsResetRow(
    gameId: gameId ?? this.gameId,
    difficulty: difficulty ?? this.difficulty,
    resetAtMs: resetAtMs ?? this.resetAtMs,
  );
  StatsResetRow copyWithCompanion(StatsResetsCompanion data) {
    return StatsResetRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      difficulty: data.difficulty.present ? data.difficulty.value : this.difficulty,
      resetAtMs: data.resetAtMs.present ? data.resetAtMs.value : this.resetAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsResetRow(')
          ..write('gameId: $gameId, ')
          ..write('difficulty: $difficulty, ')
          ..write('resetAtMs: $resetAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, difficulty, resetAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsResetRow &&
          other.gameId == this.gameId &&
          other.difficulty == this.difficulty &&
          other.resetAtMs == this.resetAtMs);
}

class StatsResetsCompanion extends UpdateCompanion<StatsResetRow> {
  final Value<String> gameId;
  final Value<String> difficulty;
  final Value<int> resetAtMs;
  final Value<int> rowid;
  const StatsResetsCompanion({
    this.gameId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.resetAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsResetsCompanion.insert({
    required String gameId,
    required String difficulty,
    required int resetAtMs,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       difficulty = Value(difficulty),
       resetAtMs = Value(resetAtMs);
  static Insertable<StatsResetRow> custom({
    Expression<String>? gameId,
    Expression<String>? difficulty,
    Expression<int>? resetAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (difficulty != null) 'difficulty': difficulty,
      if (resetAtMs != null) 'reset_at_ms': resetAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsResetsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? difficulty,
    Value<int>? resetAtMs,
    Value<int>? rowid,
  }) {
    return StatsResetsCompanion(
      gameId: gameId ?? this.gameId,
      difficulty: difficulty ?? this.difficulty,
      resetAtMs: resetAtMs ?? this.resetAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (resetAtMs.present) {
      map['reset_at_ms'] = Variable<int>(resetAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsResetsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('difficulty: $difficulty, ')
          ..write('resetAtMs: $resetAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ProgressDatabase extends GeneratedDatabase {
  _$ProgressDatabase(QueryExecutor e) : super(e);
  $ProgressDatabaseManager get managers => $ProgressDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $DailyDaysTable dailyDays = $DailyDaysTable(this);
  late final $StreaksTable streaks = $StreaksTable(this);
  late final $UnlockedAchievementsTable unlockedAchievements = $UnlockedAchievementsTable(this);
  late final $StatsResetsTable statsResets = $StatsResetsTable(this);
  late final Index sessionsGameLevel = Index(
    'sessions_game_level',
    'CREATE INDEX sessions_game_level ON sessions (game_id, difficulty)',
  );
  late final Index sessionsChallenge = Index(
    'sessions_challenge',
    'CREATE INDEX sessions_challenge ON sessions (challenge_date)',
  );
  late final Index sessionsStatus = Index('sessions_status', 'CREATE INDEX sessions_status ON sessions (status)');
  late final SessionsDao sessionsDao = SessionsDao(this as ProgressDatabase);
  late final DailyDaysDao dailyDaysDao = DailyDaysDao(this as ProgressDatabase);
  late final StreakDao streakDao = StreakDao(this as ProgressDatabase);
  late final AchievementsDao achievementsDao = AchievementsDao(this as ProgressDatabase);
  late final StatsResetsDao statsResetsDao = StatsResetsDao(this as ProgressDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    dailyDays,
    streaks,
    unlockedAchievements,
    statsResets,
    sessionsGameLevel,
    sessionsChallenge,
    sessionsStatus,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String gameId,
      required String difficulty,
      required String mode,
      required int startedAtMs,
      required int startOffsetMin,
      Value<String?> challengeDate,
      required String seed,
      required int generatorVersion,
      Value<String?> wordsLang,
      required String puzzleJson,
      required String stateJson,
      required String status,
      required int elapsedMs,
      required int hintsFree,
      required int hintsRewarded,
      required bool rescued,
      Value<int?> completedAtMs,
      required String themeIdsJson,
      Value<int?> flagsPlaced,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> difficulty,
      Value<String> mode,
      Value<int> startedAtMs,
      Value<int> startOffsetMin,
      Value<String?> challengeDate,
      Value<String> seed,
      Value<int> generatorVersion,
      Value<String?> wordsLang,
      Value<String> puzzleJson,
      Value<String> stateJson,
      Value<String> status,
      Value<int> elapsedMs,
      Value<int> hintsFree,
      Value<int> hintsRewarded,
      Value<bool> rescued,
      Value<int?> completedAtMs,
      Value<String> themeIdsJson,
      Value<int?> flagsPlaced,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer extends Composer<_$ProgressDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAtMs =>
      $composableBuilder(column: $table.startedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startOffsetMin =>
      $composableBuilder(column: $table.startOffsetMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get challengeDate =>
      $composableBuilder(column: $table.challengeDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seed => $composableBuilder(column: $table.seed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get generatorVersion =>
      $composableBuilder(column: $table.generatorVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordsLang =>
      $composableBuilder(column: $table.wordsLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get puzzleJson =>
      $composableBuilder(column: $table.puzzleJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hintsFree =>
      $composableBuilder(column: $table.hintsFree, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hintsRewarded =>
      $composableBuilder(column: $table.hintsRewarded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rescued =>
      $composableBuilder(column: $table.rescued, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAtMs =>
      $composableBuilder(column: $table.completedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeIdsJson =>
      $composableBuilder(column: $table.themeIdsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flagsPlaced =>
      $composableBuilder(column: $table.flagsPlaced, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer extends Composer<_$ProgressDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAtMs =>
      $composableBuilder(column: $table.startedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startOffsetMin =>
      $composableBuilder(column: $table.startOffsetMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get challengeDate =>
      $composableBuilder(column: $table.challengeDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get generatorVersion =>
      $composableBuilder(column: $table.generatorVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordsLang =>
      $composableBuilder(column: $table.wordsLang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get puzzleJson =>
      $composableBuilder(column: $table.puzzleJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hintsFree =>
      $composableBuilder(column: $table.hintsFree, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hintsRewarded =>
      $composableBuilder(column: $table.hintsRewarded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rescued =>
      $composableBuilder(column: $table.rescued, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAtMs =>
      $composableBuilder(column: $table.completedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeIdsJson =>
      $composableBuilder(column: $table.themeIdsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flagsPlaced =>
      $composableBuilder(column: $table.flagsPlaced, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer extends Composer<_$ProgressDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameId => $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get mode => $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(column: $table.startedAtMs, builder: (column) => column);

  GeneratedColumn<int> get startOffsetMin =>
      $composableBuilder(column: $table.startOffsetMin, builder: (column) => column);

  GeneratedColumn<String> get challengeDate =>
      $composableBuilder(column: $table.challengeDate, builder: (column) => column);

  GeneratedColumn<String> get seed => $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get generatorVersion =>
      $composableBuilder(column: $table.generatorVersion, builder: (column) => column);

  GeneratedColumn<String> get wordsLang => $composableBuilder(column: $table.wordsLang, builder: (column) => column);

  GeneratedColumn<String> get puzzleJson => $composableBuilder(column: $table.puzzleJson, builder: (column) => column);

  GeneratedColumn<String> get stateJson => $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs => $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get hintsFree => $composableBuilder(column: $table.hintsFree, builder: (column) => column);

  GeneratedColumn<int> get hintsRewarded =>
      $composableBuilder(column: $table.hintsRewarded, builder: (column) => column);

  GeneratedColumn<bool> get rescued => $composableBuilder(column: $table.rescued, builder: (column) => column);

  GeneratedColumn<int> get completedAtMs =>
      $composableBuilder(column: $table.completedAtMs, builder: (column) => column);

  GeneratedColumn<String> get themeIdsJson =>
      $composableBuilder(column: $table.themeIdsJson, builder: (column) => column);

  GeneratedColumn<int> get flagsPlaced => $composableBuilder(column: $table.flagsPlaced, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, BaseReferences<_$ProgressDatabase, $SessionsTable, SessionRow>),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$ProgressDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int> startOffsetMin = const Value.absent(),
                Value<String?> challengeDate = const Value.absent(),
                Value<String> seed = const Value.absent(),
                Value<int> generatorVersion = const Value.absent(),
                Value<String?> wordsLang = const Value.absent(),
                Value<String> puzzleJson = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> hintsFree = const Value.absent(),
                Value<int> hintsRewarded = const Value.absent(),
                Value<bool> rescued = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<String> themeIdsJson = const Value.absent(),
                Value<int?> flagsPlaced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                gameId: gameId,
                difficulty: difficulty,
                mode: mode,
                startedAtMs: startedAtMs,
                startOffsetMin: startOffsetMin,
                challengeDate: challengeDate,
                seed: seed,
                generatorVersion: generatorVersion,
                wordsLang: wordsLang,
                puzzleJson: puzzleJson,
                stateJson: stateJson,
                status: status,
                elapsedMs: elapsedMs,
                hintsFree: hintsFree,
                hintsRewarded: hintsRewarded,
                rescued: rescued,
                completedAtMs: completedAtMs,
                themeIdsJson: themeIdsJson,
                flagsPlaced: flagsPlaced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String difficulty,
                required String mode,
                required int startedAtMs,
                required int startOffsetMin,
                Value<String?> challengeDate = const Value.absent(),
                required String seed,
                required int generatorVersion,
                Value<String?> wordsLang = const Value.absent(),
                required String puzzleJson,
                required String stateJson,
                required String status,
                required int elapsedMs,
                required int hintsFree,
                required int hintsRewarded,
                required bool rescued,
                Value<int?> completedAtMs = const Value.absent(),
                required String themeIdsJson,
                Value<int?> flagsPlaced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                gameId: gameId,
                difficulty: difficulty,
                mode: mode,
                startedAtMs: startedAtMs,
                startOffsetMin: startOffsetMin,
                challengeDate: challengeDate,
                seed: seed,
                generatorVersion: generatorVersion,
                wordsLang: wordsLang,
                puzzleJson: puzzleJson,
                stateJson: stateJson,
                status: status,
                elapsedMs: elapsedMs,
                hintsFree: hintsFree,
                hintsRewarded: hintsRewarded,
                rescued: rescued,
                completedAtMs: completedAtMs,
                themeIdsJson: themeIdsJson,
                flagsPlaced: flagsPlaced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, BaseReferences<_$ProgressDatabase, $SessionsTable, SessionRow>),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$DailyDaysTableCreateCompanionBuilder =
    DailyDaysCompanion Function({
      required String localDate,
      required int tzOffsetMin,
      required String completedGames,
      required String archiveGames,
      required bool saverUsed,
      Value<int> rowid,
    });
typedef $$DailyDaysTableUpdateCompanionBuilder =
    DailyDaysCompanion Function({
      Value<String> localDate,
      Value<int> tzOffsetMin,
      Value<String> completedGames,
      Value<String> archiveGames,
      Value<bool> saverUsed,
      Value<int> rowid,
    });

class $$DailyDaysTableFilterComposer extends Composer<_$ProgressDatabase, $DailyDaysTable> {
  $$DailyDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tzOffsetMin =>
      $composableBuilder(column: $table.tzOffsetMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedGames =>
      $composableBuilder(column: $table.completedGames, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archiveGames =>
      $composableBuilder(column: $table.archiveGames, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get saverUsed =>
      $composableBuilder(column: $table.saverUsed, builder: (column) => ColumnFilters(column));
}

class $$DailyDaysTableOrderingComposer extends Composer<_$ProgressDatabase, $DailyDaysTable> {
  $$DailyDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tzOffsetMin =>
      $composableBuilder(column: $table.tzOffsetMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedGames =>
      $composableBuilder(column: $table.completedGames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archiveGames =>
      $composableBuilder(column: $table.archiveGames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get saverUsed =>
      $composableBuilder(column: $table.saverUsed, builder: (column) => ColumnOrderings(column));
}

class $$DailyDaysTableAnnotationComposer extends Composer<_$ProgressDatabase, $DailyDaysTable> {
  $$DailyDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localDate => $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMin => $composableBuilder(column: $table.tzOffsetMin, builder: (column) => column);

  GeneratedColumn<String> get completedGames =>
      $composableBuilder(column: $table.completedGames, builder: (column) => column);

  GeneratedColumn<String> get archiveGames =>
      $composableBuilder(column: $table.archiveGames, builder: (column) => column);

  GeneratedColumn<bool> get saverUsed => $composableBuilder(column: $table.saverUsed, builder: (column) => column);
}

class $$DailyDaysTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $DailyDaysTable,
          DailyDayRow,
          $$DailyDaysTableFilterComposer,
          $$DailyDaysTableOrderingComposer,
          $$DailyDaysTableAnnotationComposer,
          $$DailyDaysTableCreateCompanionBuilder,
          $$DailyDaysTableUpdateCompanionBuilder,
          (DailyDayRow, BaseReferences<_$ProgressDatabase, $DailyDaysTable, DailyDayRow>),
          DailyDayRow,
          PrefetchHooks Function()
        > {
  $$DailyDaysTableTableManager(_$ProgressDatabase db, $DailyDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DailyDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DailyDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DailyDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localDate = const Value.absent(),
                Value<int> tzOffsetMin = const Value.absent(),
                Value<String> completedGames = const Value.absent(),
                Value<String> archiveGames = const Value.absent(),
                Value<bool> saverUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyDaysCompanion(
                localDate: localDate,
                tzOffsetMin: tzOffsetMin,
                completedGames: completedGames,
                archiveGames: archiveGames,
                saverUsed: saverUsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localDate,
                required int tzOffsetMin,
                required String completedGames,
                required String archiveGames,
                required bool saverUsed,
                Value<int> rowid = const Value.absent(),
              }) => DailyDaysCompanion.insert(
                localDate: localDate,
                tzOffsetMin: tzOffsetMin,
                completedGames: completedGames,
                archiveGames: archiveGames,
                saverUsed: saverUsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $DailyDaysTable,
      DailyDayRow,
      $$DailyDaysTableFilterComposer,
      $$DailyDaysTableOrderingComposer,
      $$DailyDaysTableAnnotationComposer,
      $$DailyDaysTableCreateCompanionBuilder,
      $$DailyDaysTableUpdateCompanionBuilder,
      (DailyDayRow, BaseReferences<_$ProgressDatabase, $DailyDaysTable, DailyDayRow>),
      DailyDayRow,
      PrefetchHooks Function()
    >;
typedef $$StreaksTableCreateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      required int current,
      required int best,
      required int savers,
      Value<String?> lastCountedDate,
      required int lastOffsetMin,
      required int previous,
    });
typedef $$StreaksTableUpdateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      Value<int> current,
      Value<int> best,
      Value<int> savers,
      Value<String?> lastCountedDate,
      Value<int> lastOffsetMin,
      Value<int> previous,
    });

class $$StreaksTableFilterComposer extends Composer<_$ProgressDatabase, $StreaksTable> {
  $$StreaksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get current =>
      $composableBuilder(column: $table.current, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get best => $composableBuilder(column: $table.best, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savers =>
      $composableBuilder(column: $table.savers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastCountedDate =>
      $composableBuilder(column: $table.lastCountedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastOffsetMin =>
      $composableBuilder(column: $table.lastOffsetMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previous =>
      $composableBuilder(column: $table.previous, builder: (column) => ColumnFilters(column));
}

class $$StreaksTableOrderingComposer extends Composer<_$ProgressDatabase, $StreaksTable> {
  $$StreaksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get current =>
      $composableBuilder(column: $table.current, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get best =>
      $composableBuilder(column: $table.best, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savers =>
      $composableBuilder(column: $table.savers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastCountedDate =>
      $composableBuilder(column: $table.lastCountedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastOffsetMin =>
      $composableBuilder(column: $table.lastOffsetMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previous =>
      $composableBuilder(column: $table.previous, builder: (column) => ColumnOrderings(column));
}

class $$StreaksTableAnnotationComposer extends Composer<_$ProgressDatabase, $StreaksTable> {
  $$StreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get current => $composableBuilder(column: $table.current, builder: (column) => column);

  GeneratedColumn<int> get best => $composableBuilder(column: $table.best, builder: (column) => column);

  GeneratedColumn<int> get savers => $composableBuilder(column: $table.savers, builder: (column) => column);

  GeneratedColumn<String> get lastCountedDate =>
      $composableBuilder(column: $table.lastCountedDate, builder: (column) => column);

  GeneratedColumn<int> get lastOffsetMin =>
      $composableBuilder(column: $table.lastOffsetMin, builder: (column) => column);

  GeneratedColumn<int> get previous => $composableBuilder(column: $table.previous, builder: (column) => column);
}

class $$StreaksTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $StreaksTable,
          StreakRow,
          $$StreaksTableFilterComposer,
          $$StreaksTableOrderingComposer,
          $$StreaksTableAnnotationComposer,
          $$StreaksTableCreateCompanionBuilder,
          $$StreaksTableUpdateCompanionBuilder,
          (StreakRow, BaseReferences<_$ProgressDatabase, $StreaksTable, StreakRow>),
          StreakRow,
          PrefetchHooks Function()
        > {
  $$StreaksTableTableManager(_$ProgressDatabase db, $StreaksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> current = const Value.absent(),
                Value<int> best = const Value.absent(),
                Value<int> savers = const Value.absent(),
                Value<String?> lastCountedDate = const Value.absent(),
                Value<int> lastOffsetMin = const Value.absent(),
                Value<int> previous = const Value.absent(),
              }) => StreaksCompanion(
                id: id,
                current: current,
                best: best,
                savers: savers,
                lastCountedDate: lastCountedDate,
                lastOffsetMin: lastOffsetMin,
                previous: previous,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int current,
                required int best,
                required int savers,
                Value<String?> lastCountedDate = const Value.absent(),
                required int lastOffsetMin,
                required int previous,
              }) => StreaksCompanion.insert(
                id: id,
                current: current,
                best: best,
                savers: savers,
                lastCountedDate: lastCountedDate,
                lastOffsetMin: lastOffsetMin,
                previous: previous,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreaksTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $StreaksTable,
      StreakRow,
      $$StreaksTableFilterComposer,
      $$StreaksTableOrderingComposer,
      $$StreaksTableAnnotationComposer,
      $$StreaksTableCreateCompanionBuilder,
      $$StreaksTableUpdateCompanionBuilder,
      (StreakRow, BaseReferences<_$ProgressDatabase, $StreaksTable, StreakRow>),
      StreakRow,
      PrefetchHooks Function()
    >;
typedef $$UnlockedAchievementsTableCreateCompanionBuilder =
    UnlockedAchievementsCompanion Function({required String id, required int unlockedAtMs, Value<int> rowid});
typedef $$UnlockedAchievementsTableUpdateCompanionBuilder =
    UnlockedAchievementsCompanion Function({Value<String> id, Value<int> unlockedAtMs, Value<int> rowid});

class $$UnlockedAchievementsTableFilterComposer extends Composer<_$ProgressDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unlockedAtMs =>
      $composableBuilder(column: $table.unlockedAtMs, builder: (column) => ColumnFilters(column));
}

class $$UnlockedAchievementsTableOrderingComposer extends Composer<_$ProgressDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unlockedAtMs =>
      $composableBuilder(column: $table.unlockedAtMs, builder: (column) => ColumnOrderings(column));
}

class $$UnlockedAchievementsTableAnnotationComposer extends Composer<_$ProgressDatabase, $UnlockedAchievementsTable> {
  $$UnlockedAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get unlockedAtMs => $composableBuilder(column: $table.unlockedAtMs, builder: (column) => column);
}

class $$UnlockedAchievementsTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $UnlockedAchievementsTable,
          AchievementRow,
          $$UnlockedAchievementsTableFilterComposer,
          $$UnlockedAchievementsTableOrderingComposer,
          $$UnlockedAchievementsTableAnnotationComposer,
          $$UnlockedAchievementsTableCreateCompanionBuilder,
          $$UnlockedAchievementsTableUpdateCompanionBuilder,
          (AchievementRow, BaseReferences<_$ProgressDatabase, $UnlockedAchievementsTable, AchievementRow>),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$UnlockedAchievementsTableTableManager(_$ProgressDatabase db, $UnlockedAchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UnlockedAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UnlockedAchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UnlockedAchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> unlockedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnlockedAchievementsCompanion(id: id, unlockedAtMs: unlockedAtMs, rowid: rowid),
          createCompanionCallback:
              ({required String id, required int unlockedAtMs, Value<int> rowid = const Value.absent()}) =>
                  UnlockedAchievementsCompanion.insert(id: id, unlockedAtMs: unlockedAtMs, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnlockedAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $UnlockedAchievementsTable,
      AchievementRow,
      $$UnlockedAchievementsTableFilterComposer,
      $$UnlockedAchievementsTableOrderingComposer,
      $$UnlockedAchievementsTableAnnotationComposer,
      $$UnlockedAchievementsTableCreateCompanionBuilder,
      $$UnlockedAchievementsTableUpdateCompanionBuilder,
      (AchievementRow, BaseReferences<_$ProgressDatabase, $UnlockedAchievementsTable, AchievementRow>),
      AchievementRow,
      PrefetchHooks Function()
    >;
typedef $$StatsResetsTableCreateCompanionBuilder =
    StatsResetsCompanion Function({
      required String gameId,
      required String difficulty,
      required int resetAtMs,
      Value<int> rowid,
    });
typedef $$StatsResetsTableUpdateCompanionBuilder =
    StatsResetsCompanion Function({
      Value<String> gameId,
      Value<String> difficulty,
      Value<int> resetAtMs,
      Value<int> rowid,
    });

class $$StatsResetsTableFilterComposer extends Composer<_$ProgressDatabase, $StatsResetsTable> {
  $$StatsResetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resetAtMs =>
      $composableBuilder(column: $table.resetAtMs, builder: (column) => ColumnFilters(column));
}

class $$StatsResetsTableOrderingComposer extends Composer<_$ProgressDatabase, $StatsResetsTable> {
  $$StatsResetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty =>
      $composableBuilder(column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resetAtMs =>
      $composableBuilder(column: $table.resetAtMs, builder: (column) => ColumnOrderings(column));
}

class $$StatsResetsTableAnnotationComposer extends Composer<_$ProgressDatabase, $StatsResetsTable> {
  $$StatsResetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId => $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get resetAtMs => $composableBuilder(column: $table.resetAtMs, builder: (column) => column);
}

class $$StatsResetsTableTableManager
    extends
        RootTableManager<
          _$ProgressDatabase,
          $StatsResetsTable,
          StatsResetRow,
          $$StatsResetsTableFilterComposer,
          $$StatsResetsTableOrderingComposer,
          $$StatsResetsTableAnnotationComposer,
          $$StatsResetsTableCreateCompanionBuilder,
          $$StatsResetsTableUpdateCompanionBuilder,
          (StatsResetRow, BaseReferences<_$ProgressDatabase, $StatsResetsTable, StatsResetRow>),
          StatsResetRow,
          PrefetchHooks Function()
        > {
  $$StatsResetsTableTableManager(_$ProgressDatabase db, $StatsResetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StatsResetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StatsResetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StatsResetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> resetAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsResetsCompanion(gameId: gameId, difficulty: difficulty, resetAtMs: resetAtMs, rowid: rowid),
          createCompanionCallback:
              ({
                required String gameId,
                required String difficulty,
                required int resetAtMs,
                Value<int> rowid = const Value.absent(),
              }) => StatsResetsCompanion.insert(
                gameId: gameId,
                difficulty: difficulty,
                resetAtMs: resetAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsResetsTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDatabase,
      $StatsResetsTable,
      StatsResetRow,
      $$StatsResetsTableFilterComposer,
      $$StatsResetsTableOrderingComposer,
      $$StatsResetsTableAnnotationComposer,
      $$StatsResetsTableCreateCompanionBuilder,
      $$StatsResetsTableUpdateCompanionBuilder,
      (StatsResetRow, BaseReferences<_$ProgressDatabase, $StatsResetsTable, StatsResetRow>),
      StatsResetRow,
      PrefetchHooks Function()
    >;

class $ProgressDatabaseManager {
  final _$ProgressDatabase _db;
  $ProgressDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db, _db.sessions);
  $$DailyDaysTableTableManager get dailyDays => $$DailyDaysTableTableManager(_db, _db.dailyDays);
  $$StreaksTableTableManager get streaks => $$StreaksTableTableManager(_db, _db.streaks);
  $$UnlockedAchievementsTableTableManager get unlockedAchievements =>
      $$UnlockedAchievementsTableTableManager(_db, _db.unlockedAchievements);
  $$StatsResetsTableTableManager get statsResets => $$StatsResetsTableTableManager(_db, _db.statsResets);
}

mixin _$SessionsDaoMixin on DatabaseAccessor<ProgressDatabase> {
  $SessionsTable get sessions => attachedDatabase.sessions;
  SessionsDaoManager get managers => SessionsDaoManager(this);
}

class SessionsDaoManager {
  final _$SessionsDaoMixin _db;
  SessionsDaoManager(this._db);
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
}

mixin _$DailyDaysDaoMixin on DatabaseAccessor<ProgressDatabase> {
  $DailyDaysTable get dailyDays => attachedDatabase.dailyDays;
  DailyDaysDaoManager get managers => DailyDaysDaoManager(this);
}

class DailyDaysDaoManager {
  final _$DailyDaysDaoMixin _db;
  DailyDaysDaoManager(this._db);
  $$DailyDaysTableTableManager get dailyDays => $$DailyDaysTableTableManager(_db.attachedDatabase, _db.dailyDays);
}

mixin _$StreakDaoMixin on DatabaseAccessor<ProgressDatabase> {
  $StreaksTable get streaks => attachedDatabase.streaks;
  StreakDaoManager get managers => StreakDaoManager(this);
}

class StreakDaoManager {
  final _$StreakDaoMixin _db;
  StreakDaoManager(this._db);
  $$StreaksTableTableManager get streaks => $$StreaksTableTableManager(_db.attachedDatabase, _db.streaks);
}

mixin _$AchievementsDaoMixin on DatabaseAccessor<ProgressDatabase> {
  $UnlockedAchievementsTable get unlockedAchievements => attachedDatabase.unlockedAchievements;
  AchievementsDaoManager get managers => AchievementsDaoManager(this);
}

class AchievementsDaoManager {
  final _$AchievementsDaoMixin _db;
  AchievementsDaoManager(this._db);
  $$UnlockedAchievementsTableTableManager get unlockedAchievements =>
      $$UnlockedAchievementsTableTableManager(_db.attachedDatabase, _db.unlockedAchievements);
}

mixin _$StatsResetsDaoMixin on DatabaseAccessor<ProgressDatabase> {
  $StatsResetsTable get statsResets => attachedDatabase.statsResets;
  StatsResetsDaoManager get managers => StatsResetsDaoManager(this);
}

class StatsResetsDaoManager {
  final _$StatsResetsDaoMixin _db;
  StatsResetsDaoManager(this._db);
  $$StatsResetsTableTableManager get statsResets =>
      $$StatsResetsTableTableManager(_db.attachedDatabase, _db.statsResets);
}
