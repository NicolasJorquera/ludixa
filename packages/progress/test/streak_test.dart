import 'package:progress/progress.dart';
import 'package:test/test.dart';

import 'support.dart';

/// Juega el reto en cada instante y devuelve la racha final.
StreakState play(List<LocalNow> plays, [StreakState start = StreakState.empty]) =>
    plays.fold(start, (state, when) => StreakRules.count(state, when).state);

void main() {
  group('tabla de escenarios', () {
    final scenarios = <({String name, List<LocalNow> plays, int current, int best, int savers})>[
      (name: 'primer día', plays: [at('2026-11-02')], current: 1, best: 1, savers: 0),
      (
        name: 'tres días seguidos',
        plays: [at('2026-11-02'), at('2026-11-03'), at('2026-11-04')],
        current: 3,
        best: 3,
        savers: 0,
      ),
      (
        name: 'dos retos el mismo día cuentan una vez',
        plays: [at('2026-11-02', hour: 9), at('2026-11-02', hour: 21)],
        current: 1,
        best: 1,
        savers: 0,
      ),
      (
        name: 'medianoche: empezado 23:55 cuenta para ese día y el siguiente sigue la racha',
        plays: [at('2026-11-02', hour: 23, minute: 55), at('2026-11-03', hour: 0, minute: 10)],
        current: 2,
        best: 2,
        savers: 0,
      ),
      (
        name: '7 días seguidos ganan un comodín',
        plays: [for (var i = 2; i <= 8; i++) at('2026-11-0$i')],
        current: 7,
        best: 7,
        savers: 1,
      ),
      (
        name: 'un día sin jugar con comodín: no se rompe y se gasta',
        plays: [for (var i = 2; i <= 8; i++) at('2026-11-0$i'), at('2026-11-10')],
        current: 8,
        best: 8,
        savers: 0,
      ),
      (
        name: 'un día sin jugar sin comodín: se rompe',
        plays: [at('2026-11-02'), at('2026-11-03'), at('2026-11-05')],
        current: 1,
        best: 2,
        savers: 0,
      ),
      (
        name: 'los comodines se acumulan hasta 2',
        plays: [for (var i = 0; i < 21; i++) at(_day(i))],
        current: 21,
        best: 21,
        savers: 2,
      ),
      (
        name: 'dos días sin jugar con dos comodines',
        plays: [for (var i = 0; i < 14; i++) at(_day(i)), at(_day(16))],
        current: 15,
        best: 15,
        savers: 0,
      ),
      (
        name: 'tres días sin jugar con dos comodines: se rompe y los conserva',
        plays: [for (var i = 0; i < 14; i++) at(_day(i)), at(_day(17))],
        current: 1,
        best: 14,
        savers: 2,
      ),
      (
        name: 'viaje al este: el día local salta pero no faltó ninguno',
        // Santiago (UTC−3) a las 22:00; luego Tokio (UTC+9) el 4 a las 08:00,
        // que en Santiago todavía es el 3 a las 20:00.
        plays: [at('2026-11-02', hour: 22), at('2026-11-04', hour: 8, zone: 9)],
        current: 2,
        best: 2,
        savers: 0,
      ),
      (
        name: 'viaje al este sin jugar un día de verdad: se rompe',
        plays: [at('2026-11-02', hour: 22), at('2026-11-05', hour: 20, zone: 9)],
        current: 1,
        best: 1,
        savers: 0,
      ),
      (
        name: 'viaje al oeste: el día se repite y no cambia nada',
        // Tokio el 3 a las 08:00; luego Santiago el 2 a las 21:00.
        plays: [at('2026-11-03', hour: 8, zone: 9), at('2026-11-02', hour: 21), at('2026-11-03', hour: 10)],
        current: 1,
        best: 1,
        savers: 0,
      ),
      (
        name: 'horario de verano: el día de 23 horas no afecta',
        plays: [at('2026-09-05', hour: 23, zone: -4), at('2026-09-06', hour: 23, zone: -3), at('2026-09-07', zone: -3)],
        current: 3,
        best: 3,
        savers: 0,
      ),
      (
        name: 'reloj atrasado: un día ya pasado no reescribe la racha',
        plays: [at('2026-11-02'), at('2026-11-03'), at('2026-11-01'), at('2026-11-04')],
        current: 3,
        best: 3,
        savers: 0,
      ),
    ];

    for (final s in scenarios) {
      test(s.name, () {
        final state = play(s.plays);
        expect((state.current, state.best, state.savers), (s.current, s.best, s.savers));
      });
    }
  });

  test('al romperse informa el largo anterior y lo guarda para el mensaje', () {
    final before = play([at('2026-11-02'), at('2026-11-03'), at('2026-11-04')]);
    final update = StreakRules.count(before, at('2026-11-07'));
    expect(update.brokeFrom, 3);
    expect(update.state.previous, 3);
  });

  test('los comodines gastados indican qué días cubrieron', () {
    final before = play([for (var i = 0; i < 14; i++) at(_day(i))]);
    final update = StreakRules.count(before, at(_day(16)));
    expect(update.saversUsedOn.map((d) => d.toIso8601()), [_day(14), _day(15)]);
  });

  group('estado visto desde hoy', () {
    final week = play([for (var i = 2; i <= 8; i++) at('2026-11-0$i')]); // 7 días, 1 comodín

    test('jugado hoy', () {
      final s = StreakRules.status(week, at('2026-11-08', hour: 20));
      expect((s.current, s.playedToday, s.saversNeeded), (7, true, 0));
    });

    test('sin jugar aún hoy: sigue viva', () {
      final s = StreakRules.status(week, at('2026-11-09'));
      expect((s.current, s.playedToday, s.saversNeeded), (7, false, 0));
    });

    test('ayer sin jugar: un comodín la sostiene', () {
      final s = StreakRules.status(week, at('2026-11-10'));
      expect((s.current, s.saversNeeded), (7, 1));
    });

    test('dos días sin jugar con un comodín: rota, con mensaje de la anterior', () {
      final s = StreakRules.status(week, at('2026-11-11'));
      expect((s.current, s.best, s.previous), (0, 7, 7));
    });

    test('sin historial', () {
      final s = StreakRules.status(StreakState.empty, at('2026-11-02'));
      expect((s.current, s.best, s.playedToday), (0, 0, false));
    });
  });
}

String _day(int offset) => DateTime.utc(2026, 11, 2 + offset).toIso8601String().substring(0, 10);
