import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

void main() {
  group('LocalDay', () {
    test('valida fechas inexistentes', () {
      expect(() => LocalDay(2026, 2, 29), throwsArgumentError);
      expect(() => LocalDay(2026, 13, 1), throwsArgumentError);
      expect(LocalDay(2028, 2, 29).toIso8601(), '2028-02-29');
    });

    test('formatea y lee AAAA-MM-DD', () {
      final d = LocalDay(2026, 11, 2);
      expect(d.toIso8601(), '2026-11-02');
      expect(LocalDay.parse('2026-11-02'), d);
      expect(() => LocalDay.parse('2026-1-2'), throwsFormatException);
    });

    test('el 2 de noviembre de 2026 es lunes y el 1, domingo', () {
      expect(LocalDay(2026, 11, 2).weekday, DateTime.monday);
      expect(LocalDay(2026, 11, 1).weekday, DateTime.sunday);
    });

    test('suma días cruzando mes, año y bisiestos', () {
      expect(LocalDay(2026, 10, 31).addDays(1), LocalDay(2026, 11, 1));
      expect(LocalDay(2026, 12, 31).addDays(1), LocalDay(2027, 1, 1));
      expect(LocalDay(2028, 2, 28).addDays(1), LocalDay(2028, 2, 29));
      expect(LocalDay(2026, 3, 1).addDays(-1), LocalDay(2026, 2, 28));
    });

    test('cuenta días de calendario sin verse afectada por el horario de verano', () {
      // En Chile y en EE.UU. hay cambios de hora en estas semanas;
      // la diferencia debe seguir siendo de días enteros.
      expect(LocalDay(2026, 4, 1).daysUntil(LocalDay(2026, 4, 10)), 9);
      expect(LocalDay(2026, 9, 1).daysUntil(LocalDay(2026, 9, 30)), 29);
      expect(LocalDay(2026, 11, 2).daysUntil(LocalDay(2026, 11, 1)), -1);
    });

    test('toma la fecha tal como viene en el DateTime', () {
      final lateNight = DateTime(2026, 11, 2, 23, 59);
      expect(LocalDay.fromDateTime(lateNight), LocalDay(2026, 11, 2));
    });

    test('ordena y compara', () {
      final a = LocalDay(2026, 11, 1);
      final b = LocalDay(2026, 11, 2);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect([b, a]..sort(), [a, b]);
      expect({a, LocalDay(2026, 11, 1)}.length, 1);
    });
  });
}
