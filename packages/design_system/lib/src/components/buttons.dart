import 'package:flutter/material.dart';

import '../icons.dart';

/// Variantes de botón del sistema visual.
enum LudixaButtonVariant {
  /// Una sola acción principal por pantalla.
  primary,

  /// Alternativa con borde.
  secondary,

  /// Acción de menor peso, solo texto.
  tertiary,

  /// Acción que reproduce un video con recompensa. Lleva siempre el icono de
  /// video para que el jugador sepa qué va a pasar antes de tocar.
  rewarded,
}

/// Botón de Ludixa. Sin [onPressed] se muestra desactivado.
class LudixaButton extends StatelessWidget {
  const LudixaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LudixaButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final LudixaButtonVariant variant;

  /// Icono inicial opcional. En [LudixaButtonVariant.rewarded] se ignora: se usa
  /// el icono de video.
  final Widget? icon;

  /// Ocupa todo el ancho disponible.
  final bool expand;

  /// Icono de video con recompensa.
  static const rewardedIcon = LudixaIcon(LudixaIcons.video);

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final leading = variant == LudixaButtonVariant.rewarded ? rewardedIcon : icon;
    final Widget button = switch (variant) {
      LudixaButtonVariant.primary =>
        leading == null
            ? FilledButton(onPressed: onPressed, child: text)
            : FilledButton.icon(onPressed: onPressed, icon: leading, label: text),
      LudixaButtonVariant.secondary =>
        leading == null
            ? OutlinedButton(onPressed: onPressed, child: text)
            : OutlinedButton.icon(onPressed: onPressed, icon: leading, label: text),
      LudixaButtonVariant.tertiary || LudixaButtonVariant.rewarded =>
        leading == null
            ? TextButton(onPressed: onPressed, child: text)
            : TextButton.icon(onPressed: onPressed, icon: leading, label: text),
    };
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
