import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';

/// Tarjeta: superficie con borde fino. Con [onTap] es un botón accesible.
class LudixaCard extends StatelessWidget {
  const LudixaCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Nombre completo para lectores de pantalla cuando la tarjeta es tocable.
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  /// Fondo alternativo (por ejemplo, el tinte de un juego).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(LudixaRadii.card);
    final content = Padding(padding: padding, child: child);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      // Con una etiqueta propia se excluyen los hijos, y con ellos la acción
      // del InkWell: se repite aquí.
      onTap: semanticLabel != null ? onTap : null,
      excludeSemantics: semanticLabel != null,
      child: Material(
        color: color ?? p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Etiqueta de sección: mayúsculas pequeñas con espaciado, marcada como encabezado.
class LudixaSectionLabel extends StatelessWidget {
  const LudixaSectionLabel(this.text, {super.key, this.padding = const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8)});

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: context.palette.inkMuted),
        ),
      ),
    );
  }
}

/// Barra de progreso determinada (0 a 1), con su valor para lectores de pantalla.
class LudixaProgressBar extends StatelessWidget {
  const LudixaProgressBar({super.key, required this.value, required this.semanticLabel, this.color});

  final double value;
  final String semanticLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final clamped = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: clamped,
          minHeight: 8,
          color: color ?? p.primary,
          backgroundColor: p.line,
          semanticsLabel: semanticLabel,
        ),
      ),
    );
  }
}

/// Estado vacío: qué falta, por qué y qué hacer.
class LudixaEmptyState extends StatelessWidget {
  const LudixaEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final LudixaIcons icon;
  final String title;
  final String message;

  /// Acción opcional, normalmente un [LudixaButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LudixaIcon(icon, size: 40, color: p.inkMuted),
          const SizedBox(height: 12),
          Text(title, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            message,
            style: text.bodyMedium!.copyWith(color: p.inkMuted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Aviso breve en la parte inferior (por ejemplo, "Sin conexión: pista de cortesía").
void showLudixaToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
