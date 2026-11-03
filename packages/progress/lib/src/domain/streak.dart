import 'dart:math' as math;

import 'package:puzzle_core/puzzle_core.dart';

import 'clock.dart';

/// Racha diaria guardada: una sola para toda la app.
final class StreakState {
  const StreakState({
    this.current = 0,
    this.best = 0,
    this.savers = 0,
    this.lastCounted,
    this.lastOffsetMinutes = 0,
    this.previous = 0,
  });

  static const empty = StreakState();

  final int current;
  final int best;

  /// Comodines disponibles (0 a [StreakRules.maxSavers]).
  final int savers;

  /// Último día que contó y la zona horaria en que se jugó.
  final LocalDay? lastCounted;
  final int lastOffsetMinutes;

  /// Largo de la última racha que se rompió ("Racha anterior: 23 días").
  final int previous;
}

/// Qué cambió al contar un día.
final class StreakUpdate {
  const StreakUpdate({required this.state, this.saversUsedOn = const [], this.brokeFrom});

  final StreakState state;

  /// Días que cubrió un comodín.
  final List<LocalDay> saversUsedOn;

  /// Si la racha se rompió, cuánto medía.
  final int? brokeFrom;
}

/// Lo que muestra la portada: la racha tal como está hoy, antes de jugar.
final class StreakStatus {
  const StreakStatus({
    required this.current,
    required this.best,
    required this.savers,
    required this.playedToday,
    required this.saversNeeded,
    required this.previous,
  });

  /// 0 si la racha ya se rompió.
  final int current;
  final int best;
  final int savers;
  final bool playedToday;

  /// Comodines que se gastarán al jugar hoy (días que faltan entre medio).
  final int saversNeeded;

  /// Racha que se rompió, para el mensaje neutro (0 si no hay).
  final int previous;
}

/// Reglas de la racha (PRD, reto diario):
///
/// - Un día cuenta si se completa al menos un reto empezado ese día local.
/// - Se gana un comodín cada 7 días seguidos, hasta 2. Se gastan solos al
///   volver después de días sin jugar; nunca se compran.
/// - Viajes: si el día local salta por un cambio de zona, no se rompe. Se
///   mide el hueco también con el reloj de la zona del último día jugado y se
///   usa el menor.
/// - Si el día local se repite o retrocede (viaje al oeste, reloj atrasado),
///   no cambia nada: el historial no se reescribe.
abstract final class StreakRules {
  static const int maxSavers = 2;
  static const int daysPerSaver = 7;

  /// Días sin jugar entre el último día que contó y el día de [at].
  /// Negativo si [at] cae el mismo día o antes.
  static int missedDays(StreakState state, LocalNow at) {
    final last = state.lastCounted!;
    final local = last.daysUntil(at.day) - 1;
    if (local <= 0) return local;
    // El mismo instante con el reloj de la zona anterior: si el hueco es
    // menor, lo produjo el viaje y no el jugador.
    final previousZone = last.daysUntil(at.dayAtOffset(state.lastOffsetMinutes)) - 1;
    return math.min(local, math.max(previousZone, 0));
  }

  /// Cuenta el día en que se empezó un reto completado.
  static StreakUpdate count(StreakState state, LocalNow startedAt) {
    final last = state.lastCounted;
    if (last == null) return _advance(state, startedAt, current: 1);
    final missed = missedDays(state, startedAt);
    if (missed < 0) return StreakUpdate(state: state);
    if (missed == 0) return _advance(state, startedAt, current: state.current + 1);
    if (missed <= state.savers) {
      return _advance(
        state,
        startedAt,
        current: state.current + 1,
        savers: state.savers - missed,
        saversUsedOn: [for (var i = 1; i <= missed; i++) last.addDays(i)],
      );
    }
    return _advance(state, startedAt, current: 1, previous: state.current, brokeFrom: state.current);
  }

  /// La racha vista desde [now], sin modificar nada.
  static StreakStatus status(StreakState state, LocalNow now) {
    final last = state.lastCounted;
    if (last == null) {
      return StreakStatus(
        current: 0,
        best: state.best,
        savers: state.savers,
        playedToday: false,
        saversNeeded: 0,
        previous: state.previous,
      );
    }
    final missed = missedDays(state, now);
    final alive = missed <= state.savers;
    return StreakStatus(
      current: alive ? state.current : 0,
      best: state.best,
      savers: state.savers,
      playedToday: missed < 0,
      saversNeeded: alive ? math.max(missed, 0) : 0,
      previous: alive ? state.previous : state.current,
    );
  }

  static StreakUpdate _advance(
    StreakState state,
    LocalNow at, {
    required int current,
    int? savers,
    int? previous,
    int? brokeFrom,
    List<LocalDay> saversUsedOn = const [],
  }) {
    var available = savers ?? state.savers;
    if (current % daysPerSaver == 0) available = math.min(maxSavers, available + 1);
    return StreakUpdate(
      state: StreakState(
        current: current,
        best: math.max(state.best, current),
        savers: available,
        lastCounted: at.day,
        lastOffsetMinutes: at.offsetMinutes,
        previous: previous ?? state.previous,
      ),
      saversUsedOn: saversUsedOn,
      brokeFrom: brokeFrom,
    );
  }
}
