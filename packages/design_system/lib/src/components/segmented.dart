import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';

/// Opción de un [LudixaSegmentedControl].
final class LudixaSegment<T> {
  const LudixaSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final LudixaIcons? icon;
}

/// Control segmentado de 2 a 4 opciones (por ejemplo, Revelar / Bandera).
///
/// Se anuncia como un grupo de radios. [accent] colorea la opción elegida.
class LudixaSegmentedControl<T> extends StatelessWidget {
  const LudixaSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.accent,
    this.height = 52,
  }) : assert(segments.length >= 2 && segments.length <= 4, 'De 2 a 4 opciones');

  final List<LudixaSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color? accent;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final labelStyle = Theme.of(context).textTheme.labelLarge!;
    final light = p.brightness == Brightness.light;
    final scaler = MediaQuery.textScalerOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: p.surfaceMuted, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tres intentos, en orden: con iconos, sin iconos y apiladas.
            // Así nunca se parte una palabra (pantalla angosta o texto grande).
            final perSegment = constraints.maxWidth / segments.length - 16;
            bool fits({required bool icons}) => segments.every(
              (s) => _longestWord(s.label, labelStyle, scaler) + (icons && s.icon != null ? 30 : 0) <= perSegment,
            );
            final withIcons = fits(icons: true);
            final inRow = withIcons || fits(icons: false);
            final buttons = [
              for (final segment in segments)
                Semantics(
                  inMutuallyExclusiveGroup: true,
                  checked: segment.value == selected,
                  button: true,
                  child: _SegmentButton(
                    label: segment.label,
                    icon: withIcons || !inRow ? segment.icon : null,
                    selected: segment.value == selected,
                    onTap: () => onChanged(segment.value),
                    height: height,
                    selectedBackground: light ? p.surface : p.outline.withValues(alpha: 0.35),
                    selectedForeground: accent ?? p.primary,
                    foreground: p.inkMuted,
                    style: labelStyle,
                  ),
                ),
            ];
            if (inRow) return Row(children: [for (final b in buttons) Expanded(child: b)]);
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons);
          },
        ),
      ),
    );
  }

  static double _longestWord(String label, TextStyle style, TextScaler scaler) {
    var widest = 0.0;
    for (final word in label.split(' ')) {
      final painter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    return widest;
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.height,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.foreground,
    required this.style,
  });

  final String label;
  final LudixaIcons? icon;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color foreground;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedForeground : foreground;
    return Material(
      color: selected ? selectedBackground : const Color(0x00000000),
      borderRadius: BorderRadius.circular(LudixaRadii.control),
      elevation: selected ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(LudixaRadii.control),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[LudixaIcon(icon!, size: 22, color: color), const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label,
                    style: style.copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
