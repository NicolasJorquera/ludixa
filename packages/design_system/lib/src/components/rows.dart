import 'package:flutter/material.dart';

import '../icons.dart';
import '../layout.dart';
import '../theme.dart';

/// Fila de lista: título, subtítulo y valor opcionales, y chevron si navega.
class LudixaListRow extends StatelessWidget {
  const LudixaListRow({super.key, required this.title, this.subtitle, this.value, this.onTap, this.leading});

  final String title;
  final String? subtitle;

  /// Valor actual a la derecha ("Como el sistema").
  final String? value;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    // Con texto grande, el valor baja bajo el título en vez de apretarlo.
    final below = value != null && LudixaLayout.largeText(context);
    final valueStyle = textTheme.bodyMedium!.copyWith(color: p.inkMuted);
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: below
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) Text(subtitle!),
                Text(value!, style: valueStyle),
              ],
            )
          : subtitle == null
          ? null
          : Text(subtitle!),
      minTileHeight: 56,
      onTap: onTap,
      trailing: below
          ? (onTap == null ? null : LudixaIcon(LudixaIcons.chevronRight, color: p.inkMuted))
          : (value == null && onTap == null)
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(value!, style: valueStyle, textAlign: TextAlign.end),
                  ),
                if (onTap != null) LudixaIcon(LudixaIcons.chevronRight, color: p.inkMuted),
              ],
            ),
    );
  }
}

/// Fila con interruptor: toda la fila es tocable y se anuncia como un interruptor.
class LudixaSwitchRow extends StatelessWidget {
  const LudixaSwitchRow({super.key, required this.title, required this.value, required this.onChanged, this.subtitle});

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}
