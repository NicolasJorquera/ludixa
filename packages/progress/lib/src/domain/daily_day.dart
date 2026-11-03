import 'package:puzzle_core/puzzle_core.dart';

/// Juegos del reto diario: un día perfecto los completa todos.
const dailyGames = [GameId.sudoku, GameId.minesweeper, GameId.wordSearch];

/// Un día del calendario del reto.
final class DailyDay {
  const DailyDay({
    required this.day,
    required this.offsetMinutes,
    this.completed = const {},
    this.archiveCompleted = const {},
    this.saverUsed = false,
  });

  final LocalDay day;

  /// Zona horaria en que se jugó ese día.
  final int offsetMinutes;

  /// Retos completados ese mismo día: cuentan para la racha.
  final Set<GameId> completed;

  /// Retos completados después, desde el archivo: marca hueca, sin racha.
  final Set<GameId> archiveCompleted;

  /// Un comodín cubrió este día.
  final bool saverUsed;

  bool get played => completed.isNotEmpty;
  bool get perfect => dailyGames.every(completed.contains);

  /// Marcas del calendario: completados del día más los del archivo.
  int get marks => {...completed, ...archiveCompleted}.length;

  DailyDay copyWith({Set<GameId>? completed, Set<GameId>? archiveCompleted, bool? saverUsed}) => DailyDay(
    day: day,
    offsetMinutes: offsetMinutes,
    completed: completed ?? this.completed,
    archiveCompleted: archiveCompleted ?? this.archiveCompleted,
    saverUsed: saverUsed ?? this.saverUsed,
  );
}

/// Ventana del archivo: los 30 días anteriores a hoy.
abstract final class DailyArchive {
  static const int days = 30;

  static bool isAvailable(LocalDay day, LocalDay today) {
    final age = day.daysUntil(today);
    return age >= 1 && age <= days;
  }
}
