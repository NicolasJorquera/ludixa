import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Iconos propios de Ludixa: trazo de 1,8 en caja de 24, extremos redondeados.
///
/// Se dibujan con el color del [IconTheme] vigente (o el que se indique), así
/// que funcionan dentro de botones, barras y listas igual que los de Material.
enum LudixaIcons {
  // Juegos.
  sudoku('<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 3v18M15 3v18M3 9h18M3 15h18"/>'),
  mine(
    '<circle cx="12" cy="12" r="5"/>'
    '<path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1"/>',
  ),
  mineFilled(
    '<circle cx="12" cy="12" r="5" fill="currentColor"/>'
    '<path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1"/>',
  ),
  wordSearch(
    '<rect x="3" y="3" width="13" height="13" rx="2"/><circle cx="16" cy="16" r="4"/><path d="M19 19l2.5 2.5"/>',
  ),

  // Progreso y recompensas.
  streak('<path d="M12 3c1 3 5 5 5 10a5 5 0 0 1-10 0c0-2 1-3.5 2-4.5 0 2 1 3 2 3 0-3-1-5 1-8.5z"/>'),
  saver('<path d="M12 3l7 3v6c0 4-3 7.5-7 9-4-1.5-7-5-7-9V6z"/>'),
  trophy('<path d="M8 4h8v5a4 4 0 0 1-8 0zM8 6H5a3 3 0 0 0 3 4M16 6h3a3 3 0 0 1-3 4M12 13v4M8 21h8M9 17h6"/>'),
  video('<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M10 9l5 3-5 3z"/>'),

  // Herramientas de partida.
  hint('<path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.5 1 2.5h6c0-1 .3-1.8 1-2.5A6 6 0 0 0 12 3z"/>'),
  notes('<path d="M4 20l4-1 11-11-3-3L5 16z"/>'),
  undo('<path d="M9 14L4 9l5-5M4 9h10a6 6 0 0 1 0 12h-3"/>', mirrorInRtl: true),
  erase('<path d="M16 4l4 4-10 10H6l-2-2z"/><path d="M12 8l4 4M8 20h12"/>'),
  flag('<path d="M6 21V4M6 4h11l-2.5 4L17 12H6"/>'),
  flagFilled('<path d="M6 21V4"/><path d="M6 4h11l-2.5 4L17 12H6z" fill="currentColor"/>'),
  reveal(
    '<path d="M9 11V5a1.5 1.5 0 0 1 3 0v5M12 10V4a1.5 1.5 0 0 1 3 0v6M15 10.5V6a1.5 1.5 0 0 1 3 0v7a7 7 0 0 1-7 7h-.5'
    'a6 6 0 0 1-5-2.7L3.5 14a1.5 1.5 0 0 1 2.4-1.8L9 15"/>',
  ),
  pause('<path d="M9 6v12M15 6v12"/>'),
  play('<path d="M8 5l11 7-11 7z"/>', mirrorInRtl: true),
  restart('<path d="M20 11a8 8 0 1 0-2.3 5.7M20 5v6h-6"/>'),
  clock('<circle cx="12" cy="13" r="8"/><path d="M12 9v4l3 2M9 2h6"/>'),

  // Navegación.
  home('<path d="M4 11l8-7 8 7v8a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1z"/>'),
  daily('<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M4 10h16M9 3v4M15 3v4"/>'),
  progress('<path d="M5 20V10M12 20V4M19 20v-7"/>'),
  settings('<path d="M4 7h10M18 7h2M4 17h4M12 17h8"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="17" r="2"/>'),
  back('<path d="M15 6l-6 6 6 6"/>', mirrorInRtl: true),
  chevronRight('<path d="M9 6l6 6-6 6"/>', mirrorInRtl: true),
  close('<path d="M6 6l12 12M18 6L6 18"/>'),

  // Estado.
  check('<path d="M5 12l5 5 9-10"/>'),
  help('<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .8-1 1.5v.7M12 17h.01"/>'),
  offline('<path d="M2 8.5a15 15 0 0 1 20 0M5 12a10 10 0 0 1 14 0M8.5 15.5a5 5 0 0 1 7 0M12 19h.01M3 3l18 18"/>');

  const LudixaIcons(this._body, {this.mirrorInRtl = false});

  final String _body;

  /// Se refleja en idiomas de derecha a izquierda (flechas, deshacer, reproducir).
  final bool mirrorInRtl;

  /// Documento SVG completo. El color sale de `currentColor`.
  String get svg =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
      'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">$_body</svg>';
}

/// Dibuja un [LudixaIcons].
///
/// Sin [semanticLabel] es decorativo y los lectores de pantalla lo omiten:
/// el texto que lo acompaña ya dice lo necesario.
class LudixaIcon extends StatelessWidget {
  const LudixaIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final LudixaIcons icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    final base = color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    final tint = base.withValues(alpha: base.a * (theme.opacity ?? 1));
    Widget picture = SvgPicture.string(
      icon.svg,
      width: side,
      height: side,
      theme: SvgTheme(currentColor: tint),
      excludeFromSemantics: true,
    );
    if (icon.mirrorInRtl && Directionality.of(context) == TextDirection.rtl) {
      picture = Transform.flip(flipX: true, child: picture);
    }
    final sized = SizedBox.square(dimension: side, child: picture);
    if (semanticLabel == null) return ExcludeSemantics(child: sized);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(child: sized),
    );
  }
}
