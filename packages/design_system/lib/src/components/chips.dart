import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';

/// Píldora con icono y cifra (por ejemplo, la racha en la portada).
class LudixaStatChip extends StatelessWidget {
  const LudixaStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.semanticLabel,
    this.iconColor,
    this.onTap,
  });

  final LudixaIcons icon;
  final String value;

  /// Frase completa para lectores de pantalla ("Racha de 12 días").
  final String semanticLabel;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 14, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LudixaIcon(icon, size: 20, color: iconColor ?? p.minesweeper),
          const SizedBox(width: 6),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: p.surface,
            shape: StadiumBorder(side: BorderSide(color: p.line)),
            clipBehavior: Clip.antiAlias,
            child: onTap == null ? content : InkWell(onTap: onTap, child: content),
          ),
        ),
      ),
    );
  }
}

/// Insignia de estado positivo ("Sin ayuda", "Nuevo récord").
class LudixaBadge extends StatelessWidget {
  const LudixaBadge({super.key, required this.label, this.icon});

  final String label;
  final LudixaIcons? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: ShapeDecoration(color: p.successSoft, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[LudixaIcon(icon!, size: 16, color: p.successInk), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: p.successInk, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
