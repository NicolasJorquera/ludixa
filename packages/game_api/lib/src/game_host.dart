import 'session.dart';

/// De dónde salió una pista concedida.
enum HintSource {
  /// Una de las pistas gratis del puzzle.
  free,

  /// Ganada viendo un video con recompensa completo.
  rewarded,

  /// Pista de cortesía cuando no hay videos disponibles.
  courtesy,
}

/// Por qué no se concedió una pista.
enum HintDenial {
  /// Se agotaron las gratis y las de video de este puzzle.
  limitReached,

  /// El jugador eligió no ver el video, o lo cerró antes de terminar.
  declined,

  /// No había video ni cortesía disponible.
  unavailable,
}

/// Respuesta del host a un pedido de pista.
sealed class HintGrant {
  const HintGrant();
}

final class HintGranted extends HintGrant {
  const HintGranted(this.source);

  final HintSource source;
}

final class HintDenied extends HintGrant {
  const HintDenied(this.reason);

  final HintDenial reason;
}

/// Respuesta del host a un pedido de rescate (deshacer el error fatal).
enum RescueOutcome { granted, declined, unavailable }

/// Servicios que la app ofrece a un módulo de juego.
///
/// El módulo no sabe si una pista sale de un crédito gratis, de un video o de
/// la cortesía sin conexión, ni dónde se guarda la partida. Eso permite usar
/// el mismo módulo en la colección, en una app satélite o sin anuncios.
abstract interface class GameHost {
  /// Pide una pista. El host decide si ofrecer un video y aplica los límites.
  Future<HintGrant> requestHint();

  /// Pide deshacer el movimiento que perdió la partida.
  Future<RescueOutcome> requestRescue();

  /// Guarda el estado de la partida en curso.
  Future<void> saveSnapshot(SessionSnapshot snapshot);

  /// Informa el resultado final. Se llama una sola vez por partida.
  Future<void> reportResult(GameResult result);
}
