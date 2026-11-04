import 'package:puzzle_core/puzzle_core.dart';

/// Lo que la app le pide a un módulo de juego al abrir una partida.
final class PuzzleRequest {
  const PuzzleRequest({
    required this.mode,
    required this.difficulty,
    required this.seed,
    this.day,
    this.wordsLanguage,
    this.resumeFrom,
  }) : assert(mode == PuzzleMode.free || day != null, 'Un reto (diario o de archivo) necesita su día');

  final PuzzleMode mode;
  final Difficulty difficulty;
  final PuzzleSeed seed;

  /// Día del reto. Solo en los modos [PuzzleMode.daily] y [PuzzleMode.archive].
  final LocalDay? day;

  /// Idioma de las palabras, para los juegos que lo usan (Sopa de letras).
  final String? wordsLanguage;

  /// Estado guardado para retomar una partida en curso.
  final SessionSnapshot? resumeFrom;
}

/// Estado serializable de una partida en curso.
///
/// [state] es JSON que define cada motor; la app lo guarda sin interpretarlo.
final class SessionSnapshot {
  const SessionSnapshot({
    required this.state,
    required this.elapsed,
    this.freeHintsUsed = 0,
    this.rewardedHintsUsed = 0,
  });

  final Map<String, Object?> state;
  final Duration elapsed;

  /// Pistas ya usadas: al retomar, el host no vuelve a dar las gratis.
  final int freeHintsUsed;
  final int rewardedHintsUsed;
}

/// Cómo terminó una partida.
enum GameOutcome { won, lost, abandoned }

/// Resultado que el módulo informa al terminar una partida.
final class GameResult {
  const GameResult({
    required this.outcome,
    required this.elapsed,
    this.freeHintsUsed = 0,
    this.rewardedHintsUsed = 0,
    this.rescued = false,
    this.flagsPlaced,
    this.themeIds = const [],
  });

  final GameOutcome outcome;
  final Duration elapsed;
  final int freeHintsUsed;
  final int rewardedHintsUsed;

  /// La partida se salvó con un deshacer por video (Buscaminas).
  final bool rescued;

  /// Datos para los logros. Banderas que puso el jugador (Buscaminas; las que
  /// el motor marca solo al ganar no cuentan) y temas de la sopa.
  final int? flagsPlaced;
  final List<String> themeIds;

  /// Usó alguna ayuda: no cuenta como "sin ayuda".
  bool get assisted => freeHintsUsed > 0 || rewardedHintsUsed > 0 || rescued;
}
