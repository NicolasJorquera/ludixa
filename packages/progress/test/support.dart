import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

/// Reloj que avanza a mano.
final class FakeClock implements Clock {
  FakeClock(this.current);

  LocalNow current;

  @override
  LocalNow now() => current;
}

/// Instante a una hora local dada en una zona (desfase en horas).
LocalNow at(String day, {int hour = 12, int minute = 0, num zone = -3}) {
  final d = LocalDay.parse(day);
  final offset = (zone * 60).round();
  return LocalNow(
    utc: DateTime.utc(d.year, d.month, d.day, hour, minute).subtract(Duration(minutes: offset)),
    offsetMinutes: offset,
  );
}

var _ids = 0;

/// Partida terminada. Por defecto, el reto diario de Sudoku del día de inicio.
SessionRecord session({
  required LocalNow startedAt,
  GameId game = GameId.sudoku,
  String difficulty = 'easy',
  PuzzleMode mode = PuzzleMode.daily,
  LocalDay? challengeDay,
  SessionStatus status = SessionStatus.won,
  Duration elapsed = const Duration(minutes: 4),
  int freeHints = 0,
  int? flagsPlaced,
  List<String> themeIds = const [],
  Duration finishAfter = const Duration(minutes: 5),
}) => SessionRecord(
  id: 's${_ids++}',
  game: game,
  difficulty: Difficulty(difficulty),
  mode: mode,
  startedAt: startedAt,
  challengeDay: mode == PuzzleMode.free ? null : (challengeDay ?? startedAt.day),
  themeIds: themeIds,
  flagsPlaced: flagsPlaced,
).finish(status: status, elapsed: elapsed, completedAt: startedAt.utc.add(finishAfter), freeHints: freeHints);
