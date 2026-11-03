import 'package:puzzle_core/puzzle_core.dart';

import 'clock.dart';

enum SessionStatus { inProgress, won, lost, abandoned }

/// Una partida, en curso o terminada. Es la única fuente de las estadísticas.
final class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.game,
    required this.difficulty,
    required this.mode,
    required this.startedAt,
    this.challengeDay,
    this.seedKey = '',
    this.generatorVersion = 0,
    this.wordsLanguage,
    this.puzzle = const {},
    this.state = const {},
    this.status = SessionStatus.inProgress,
    this.elapsed = Duration.zero,
    this.freeHints = 0,
    this.rewardedHints = 0,
    this.rescued = false,
    this.completedAt,
    this.themeIds = const [],
    this.flagsPlaced,
  }) : assert(mode == PuzzleMode.free || challengeDay != null, 'Un reto necesita su día');

  final String id;
  final GameId game;
  final Difficulty difficulty;
  final PuzzleMode mode;

  /// Cuándo y en qué zona se empezó. El día local de inicio decide para qué
  /// día cuenta un reto (23:55 → 00:05 cuenta para el día en que se empezó).
  final LocalNow startedAt;

  /// Día del reto, en los modos diario y archivo.
  final LocalDay? challengeDay;

  final String seedKey;
  final int generatorVersion;
  final String? wordsLanguage;

  /// Puzzle completo y estado, en JSON del motor. Guardar el puzzle hace que
  /// subir la versión de un generador no altere el historial.
  final Map<String, Object?> puzzle;
  final Map<String, Object?> state;

  final SessionStatus status;
  final Duration elapsed;
  final int freeHints;
  final int rewardedHints;

  /// Se salvó con un deshacer por video (Buscaminas).
  final bool rescued;
  final DateTime? completedAt;

  /// Temas de la sopa (uno, o tres el domingo).
  final List<String> themeIds;

  /// Banderas colocadas en el Buscaminas.
  final int? flagsPlaced;

  bool get won => status == SessionStatus.won;
  bool get finished => status != SessionStatus.inProgress;
  bool get assisted => freeHints > 0 || rewardedHints > 0 || rescued;
  int get hintsUsed => freeHints + rewardedHints;

  SessionRecord finish({
    required SessionStatus status,
    required Duration elapsed,
    required DateTime completedAt,
    int freeHints = 0,
    int rewardedHints = 0,
    bool rescued = false,
    int? flagsPlaced,
  }) {
    assert(status != SessionStatus.inProgress, 'Una partida terminada no está en curso');
    return SessionRecord(
      id: id,
      game: game,
      difficulty: difficulty,
      mode: mode,
      startedAt: startedAt,
      challengeDay: challengeDay,
      seedKey: seedKey,
      generatorVersion: generatorVersion,
      wordsLanguage: wordsLanguage,
      puzzle: puzzle,
      state: state,
      status: status,
      elapsed: elapsed,
      freeHints: freeHints,
      rewardedHints: rewardedHints,
      rescued: rescued,
      completedAt: completedAt,
      themeIds: themeIds,
      flagsPlaced: flagsPlaced ?? this.flagsPlaced,
    );
  }
}
