import 'package:flutter/material.dart';

import '../components/buttons.dart';
import '../components/chips.dart';
import '../components/rows.dart';
import '../components/segmented.dart';
import '../components/sheet.dart';
import '../components/surfaces.dart';
import '../icons.dart';
import '../theme.dart';

/// Catálogo de componentes. Herramienta de desarrollo: la app solo lo enlaza
/// en el entorno dev, y sus textos de muestra no se traducen.
class ComponentCatalog extends StatefulWidget {
  const ComponentCatalog({super.key});

  @override
  State<ComponentCatalog> createState() => _ComponentCatalogState();
}

enum _Mode { reveal, flag }

class _ComponentCatalogState extends State<ComponentCatalog> {
  _Mode _mode = _Mode.reveal;
  bool _sounds = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de componentes')),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(bottom: 32),
        children: [
          const LudixaSectionLabel('Botones'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              children: [
                LudixaButton(label: 'Seguir con el reto', onPressed: () {}),
                const SizedBox(height: 10),
                LudixaButton(label: 'Volver al inicio', variant: LudixaButtonVariant.secondary, onPressed: () {}),
                const SizedBox(height: 10),
                LudixaButton(label: 'Cómo se juega', variant: LudixaButtonVariant.tertiary, onPressed: () {}),
                const SizedBox(height: 10),
                LudixaButton(
                  label: 'Ver video y obtener la pista',
                  variant: LudixaButtonVariant.rewarded,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                const LudixaButton(label: 'Sin pistas disponibles', onPressed: null),
              ],
            ),
          ),
          const LudixaSectionLabel('Chips e insignias'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LudixaStatChip(icon: LudixaIcons.streak, value: '12', semanticLabel: 'Racha de 12 días', onTap: () {}),
                const LudixaBadge(label: 'Sin ayuda', icon: LudixaIcons.saver),
              ],
            ),
          ),
          const LudixaSectionLabel('Control segmentado'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: LudixaSegmentedControl<_Mode>(
              segments: const [
                LudixaSegment(value: _Mode.reveal, label: 'Revelar', icon: LudixaIcons.reveal),
                LudixaSegment(value: _Mode.flag, label: 'Bandera', icon: LudixaIcons.flag),
              ],
              selected: _mode,
              accent: p.minesweeper,
              onChanged: (mode) => setState(() => _mode = mode),
            ),
          ),
          const LudixaSectionLabel('Tarjeta y progreso'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: LudixaCard(
              semanticLabel: 'Continuar Sudoku Medio, 58% completado',
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continuar Sudoku · Medio', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text('6:41 · 58% completado', style: text.bodySmall),
                  const SizedBox(height: 12),
                  const LudixaProgressBar(value: 0.58, semanticLabel: 'Progreso del puzzle'),
                ],
              ),
            ),
          ),
          const LudixaSectionLabel('Filas'),
          LudixaListRow(title: 'Idioma', value: 'Como el sistema', onTap: () {}),
          LudixaSwitchRow(
            title: 'Sonidos',
            subtitle: 'Efectos suaves al jugar',
            value: _sounds,
            onChanged: (value) => setState(() => _sounds = value),
          ),
          const LudixaSectionLabel('Estado vacío'),
          LudixaEmptyState(
            icon: LudixaIcons.progress,
            title: 'Aún no hay estadísticas',
            message: 'Aparecerán al completar tu primer puzzle.',
            action: LudixaButton(label: 'Ir al reto de hoy', expand: false, onPressed: () {}),
          ),
          const LudixaSectionLabel('Hoja inferior y aviso'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Column(
              children: [
                LudixaButton(
                  label: 'Abrir hoja de ejemplo',
                  variant: LudixaButtonVariant.secondary,
                  onPressed: () => showLudixaSheet<void>(
                    context,
                    builder: (context) => LudixaSheet(
                      title: '¿Quieres una pista más?',
                      body: const Text('Mira un video de unos 30 segundos y recibirás 1 pista.'),
                      actions: [
                        LudixaButton(
                          label: 'Ver video y obtener la pista',
                          variant: LudixaButtonVariant.rewarded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        LudixaButton(
                          label: 'Ahora no',
                          variant: LudixaButtonVariant.tertiary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                LudixaButton(
                  label: 'Mostrar aviso',
                  variant: LudixaButtonVariant.tertiary,
                  onPressed: () => showLudixaToast(context, 'Sin conexión: te regalamos una pista de cortesía.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
