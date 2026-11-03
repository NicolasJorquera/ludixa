import 'package:puzzle_core/puzzle_core.dart';

/// Un instante y la zona horaria en que lo vivió el jugador.
///
/// Se guarda el desfase de la zona (no su nombre): basta para saber el día
/// local y para reconocer un viaje entre zonas.
final class LocalNow {
  const LocalNow({required this.utc, required this.offsetMinutes});

  factory LocalNow.fromDateTime(DateTime dateTime) =>
      LocalNow(utc: dateTime.toUtc(), offsetMinutes: dateTime.timeZoneOffset.inMinutes);

  final DateTime utc;
  final int offsetMinutes;

  /// Día local del jugador en ese instante.
  LocalDay get day => dayAtOffset(offsetMinutes);

  /// Día que marcaría un reloj con otro desfase en el mismo instante.
  LocalDay dayAtOffset(int offset) => LocalDay.fromDateTime(utc.add(Duration(minutes: offset)));

  @override
  String toString() => '$utc ($offsetMinutes min)';
}

/// Fuente de la hora. Las pruebas usan un reloj falso.
abstract interface class Clock {
  LocalNow now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  LocalNow now() => LocalNow.fromDateTime(DateTime.now());
}
