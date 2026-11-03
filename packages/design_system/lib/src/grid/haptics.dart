import 'package:flutter/services.dart';

/// Vibraciones de las partidas. Todas respetan el ajuste "Vibración": con
/// [enabled] en falso no hacen nada.
abstract final class LudixaHaptics {
  /// Seleccionar una celda o una tecla.
  static Future<void> select({required bool enabled}) async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  /// Poner o quitar una bandera.
  static Future<void> flag({required bool enabled}) async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  /// Completar un puzzle o encontrar una palabra.
  static Future<void> success({required bool enabled}) async {
    if (enabled) await HapticFeedback.mediumImpact();
  }
}
