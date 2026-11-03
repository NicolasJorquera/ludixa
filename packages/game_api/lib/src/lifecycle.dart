import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

/// Ciclo de vida común de las partidas: al salir de la app el tiempo se
/// detiene y se guarda; al volver tras más de [autoPauseAfter], la partida se
/// abre en pausa (PRD y ficha UX de Pausa).
///
/// Usa `clock` para que las pruebas puedan adelantar el tiempo.
class GameLifecycle {
  GameLifecycle({required this.onLeave, required this.onReturn, required this.onAutoPause});

  static const autoPauseAfter = Duration(seconds: 60);

  final VoidCallback onLeave;
  final VoidCallback onReturn;
  final VoidCallback onAutoPause;

  late final AppLifecycleListener _listener = AppLifecycleListener(onHide: _hide, onShow: _show);
  DateTime? _leftAt;

  /// Empieza a escuchar. Llamar en `initState`.
  void attach() => _listener;

  void dispose() => _listener.dispose();

  void _hide() {
    _leftAt = clock.now();
    onLeave();
  }

  void _show() {
    final left = _leftAt;
    _leftAt = null;
    onReturn();
    if (left != null && clock.now().difference(left) > autoPauseAfter) onAutoPause();
  }
}
