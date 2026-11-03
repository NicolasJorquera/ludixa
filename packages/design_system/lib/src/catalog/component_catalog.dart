import 'package:flutter/material.dart';

import '../components/ad_slot.dart';
import '../components/buttons.dart';
import '../components/chips.dart';
import '../components/rows.dart';
import '../components/segmented.dart';
import '../components/sheet.dart';
import '../components/surfaces.dart';
import '../grid/puzzle_grid.dart';
import '../grid/zoomable_board.dart';
import '../icons.dart';
import '../theme.dart';
import '../typography.dart';

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
  bool _showAd = true;
  int _selectedCell = 40;
  final _flags = <int>{};
  final _boardKey = GlobalKey<ZoomableBoardState>();

  static const _sudoku = GridDimensions(columns: 9, rows: 9);
  static const _expert = GridDimensions(columns: 16, rows: 30);
  static const _digits = '530070000600195000098000060800060003400803001700020006060000280000419005000080079';

  Widget _sudokuCell(BuildContext context, int index, double extent) {
    final colors = context.sudokuColors;
    final row = _sudoku.rowOf(index);
    final column = _sudoku.columnOf(index);
    final selectedRow = _sudoku.rowOf(_selectedCell);
    final selectedColumn = _sudoku.columnOf(_selectedCell);
    final sameBox = row ~/ 3 == selectedRow ~/ 3 && column ~/ 3 == selectedColumn ~/ 3;
    final background = index == _selectedCell
        ? colors.selected
        : (row == selectedRow || column == selectedColumn || sameBox)
        ? colors.zone
        : colors.cell;
    final digit = _digits[index];
    BorderSide side(bool thick) => BorderSide(color: thick ? colors.thickLine : colors.thinLine, width: thick ? 2 : 1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          right: column == 8 ? BorderSide.none : side(column % 3 == 2),
          bottom: row == 8 ? BorderSide.none : side(row % 3 == 2),
        ),
      ),
      child: Center(
        child: Text(
          digit == '0' ? '' : digit,
          style: LudixaTypography.gridDigit(entered: false).copyWith(color: colors.given),
        ),
      ),
    );
  }

  Widget _mineCell(BuildContext context, int index, double extent) {
    final colors = context.minesweeperColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.closed,
        borderRadius: BorderRadius.circular(LudixaRadii.cell * extent / 36),
        border: Border(bottom: BorderSide(color: colors.closedEdge, width: 2)),
      ),
      child: _flags.contains(index)
          ? Center(
              child: LudixaIcon(LudixaIcons.flagFilled, size: extent * 0.6, color: colors.flag),
            )
          : null,
    );
  }

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
          const LudixaSectionLabel('Grilla 9×9'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: context.sudokuColors.thickLine, width: 2.5)),
              child: PuzzleGrid(
                dimensions: _sudoku,
                semanticLabel: 'Tablero de ejemplo',
                semanticLabelFor: (i) =>
                    'Fila ${_sudoku.rowOf(i) + 1}, columna ${_sudoku.columnOf(i) + 1}'
                    '${_digits[i] == '0' ? ', vacía' : ', ${_digits[i]}'}',
                cellBuilder: _sudokuCell,
                onCellTap: (i) => setState(() => _selectedCell = i),
              ),
            ),
          ),
          const LudixaSectionLabel('Tablero Experto con zoom'),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 2.0;
                final extent = PuzzleGrid.fitCellExtent(constraints.maxWidth, _expert, gap: gap).floorToDouble();
                final board = Size(
                  extent * _expert.columns + gap * (_expert.columns - 1),
                  extent * _expert.rows + gap * (_expert.rows - 1),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 320,
                      child: ClipRect(
                        child: ZoomableBoard(
                          key: _boardKey,
                          boardSize: board,
                          cellExtent: extent,
                          child: PuzzleGrid(
                            dimensions: _expert,
                            gap: gap,
                            fixedCellExtent: extent,
                            semanticLabel: 'Tablero Experto de ejemplo',
                            semanticLabelFor: (i) =>
                                'Fila ${_expert.rowOf(i) + 1}, columna ${_expert.columnOf(i) + 1}'
                                '${_flags.contains(i) ? ', con bandera' : ', cerrada'}',
                            cellBuilder: _mineCell,
                            onCellLongPress: (i) =>
                                setState(() => _flags.contains(i) ? _flags.remove(i) : _flags.add(i)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LudixaButton(
                      label: 'Alternar zoom',
                      variant: LudixaButtonVariant.secondary,
                      onPressed: () => _boardKey.currentState?.toggleZoom(),
                    ),
                  ],
                );
              },
            ),
          ),
          const LudixaSectionLabel('Espacio publicitario'),
          LudixaSwitchRow(
            title: 'Hay anuncio disponible',
            value: _showAd,
            onChanged: (value) => setState(() => _showAd = value),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: LudixaAdSlot(
              label: 'Anuncio',
              ad: _showAd
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: p.adOutline, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('Banner adaptable de prueba', style: text.bodySmall),
                    )
                  : null,
            ),
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
