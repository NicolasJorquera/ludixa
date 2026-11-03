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
    return DecoratedBox(
      decoration: BoxDecoration(color: p.surfaceMuted, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(4),
        child: Row(
          children: [
            for (final segment in segments)
              Expanded(
                child: Semantics(
                  inMutuallyExclusiveGroup: true,
                  checked: segment.value == selected,
                  button: true,
                  child: _SegmentButton(
                    label: segment.label,
                    icon: segment.icon,
                    selected: segment.value == selected,
                    onTap: () => onChanged(segment.value),
                    height: height,
                    selectedBackground: light ? p.surface : p.outline.withValues(alpha: 0.35),
                    selectedForeground: accent ?? p.primary,
                    foreground: p.inkMuted,
                    style: labelStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
