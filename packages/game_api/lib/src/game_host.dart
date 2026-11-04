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

/// Lo que eligió el jugador en la pantalla de pausa.
enum PauseChoice {
  resume,

  /// Empezar este mismo puzzle de cero (el jugador ya lo confirmó).
  restart,

  /// "Guardar y salir": la partida queda guardada para continuarla.
  exit,
}

/// Servicios que la app ofrece a un módulo de juego.
///
/// El módulo no sabe si una pista sale de un crédito gratis, de un video o de
/// la cortesía sin conexión, ni dónde se guarda la partida. Eso permite usar
/// el mismo módulo en la colección, en una app satélite o sin anuncios.
abstract interface class GameHost {
  /// Pide una pista. El host decide si ofrecer un video y aplica los límites.
  Future<HintGrant> requestHint();

  /// Pistas gratis que quedan en este puzzle (el contador del botón Pista).
  int get freeHintsLeft;

  /// Pide deshacer el movimiento que perdió la partida.
  Future<RescueOutcome> requestRescue();

  /// Hay un video para ofrecer ahora. Sin él (sin conexión, sin inventario o
  /// sin anuncios) el Buscaminas no muestra "Deshacer con video".
  bool get rewardedAvailable;

  /// Guarda el estado de la partida en curso.
  Future<void> saveSnapshot(SessionSnapshot snapshot);

  /// Informa el resultado final. Se llama una sola vez por partida.
  Future<void> reportResult(GameResult result);

  /// Muestra la pantalla de pausa (tablero oculto, reanudar, reiniciar, cómo
  /// se juega, ajustes del juego, guardar y salir) y devuelve la elección.
  /// El juego ya detuvo su tiempo; los ajustes pueden haber cambiado.
  Future<PauseChoice> showPause();

  /// Otra partida del mismo juego y nivel ("Tablero nuevo" del Buscaminas).
  void playAgain();
}
