/// Un día del calendario, sin hora ni zona horaria.
///
/// Representa la fecha local en la que el jugador vive un reto o una racha.
/// La aritmética de días se hace en UTC, así que los cambios de horario de
/// verano no la afectan.
final class LocalDay implements Comparable<LocalDay> {
  LocalDay(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year || normalized.month != month || normalized.day != day) {
      throw ArgumentError('Fecha inválida: $year-$month-$day');
    }
  }

  /// Toma la fecha de [dateTime] tal como está expresada, sin convertir de zona.
  /// Con `DateTime.now()` da el día local del dispositivo.
  factory LocalDay.fromDateTime(DateTime dateTime) => LocalDay(dateTime.year, dateTime.month, dateTime.day);

  /// Lee el formato `AAAA-MM-DD`.
  factory LocalDay.parse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) throw FormatException('Se esperaba AAAA-MM-DD', iso);
    return LocalDay(int.parse(match.group(1)!), int.parse(match.group(2)!), int.parse(match.group(3)!));
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// Día de la semana según [DateTime]: 1 = lunes … 7 = domingo.
  int get weekday => _utc.weekday;

  LocalDay addDays(int days) => LocalDay.fromDateTime(DateTime.utc(year, month, day + days));

  /// Días de calendario desde este día hasta [other] (negativo si es anterior).
  int daysUntil(LocalDay other) => other._utc.difference(_utc).inDays;

  bool isBefore(LocalDay other) => compareTo(other) < 0;

  bool isAfter(LocalDay other) => compareTo(other) > 0;

  String toIso8601() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDay other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) => other is LocalDay && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601();
}
