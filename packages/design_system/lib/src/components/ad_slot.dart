import 'package:flutter/material.dart';

import '../theme.dart';

/// Espacio para un banner en línea.
///
/// Reglas del contrato de anuncios:
/// - siempre lleva el rótulo [label] ("Anuncio"), traducido por quien lo usa;
/// - deja al menos [minSeparation] por encima y por debajo, para alejarlo de
///   cualquier control y evitar toques accidentales;
/// - si no hay anuncio ([ad] nulo: cargando, sin inventario o sin
///   consentimiento) no ocupa espacio: no deja un hueco vacío.
class LudixaAdSlot extends StatelessWidget {
  const LudixaAdSlot({super.key, required this.label, required this.ad});

  /// Separación mínima con los controles vecinos.
  static const minSeparation = 24.0;

  final String label;
  final Widget? ad;

  @override
  Widget build(BuildContext context) {
    final ad = this.ad;
    if (ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: minSeparation),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: context.palette.inkMuted),
          ),
          const SizedBox(height: 4),
          Center(child: ad),
        ],
      ),
    );
  }
}
