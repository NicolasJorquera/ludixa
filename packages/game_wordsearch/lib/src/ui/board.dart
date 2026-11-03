import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import '../../l10n/generated/words_localizations.dart';
import '../controller.dart';

/// Grilla de la Sopa: letras normalizadas, cápsulas bajo las palabras
/// encontradas y la selección en curso, y el parpadeo de la pista.
class WordSearchBoard extends StatefulWidget {
  const WordSearchBoard({
    super.key,
    required this.controller,
    required this.cellExtent,
    required this.tapMode,
    required this.onResult,
  });

  /// Resultado de cada selección terminada (para anunciar y vibrar).
  final ValueChanged<({SelectionOutcome outcome, int? wordIndex})?> onResult;

  final WordSearchController controller;
  final double cellExtent;

  /// Toque inicial y final en lugar de arrastre.
  final bool tapMode;

  @override
  State<WordSearchBoard> createState() => _WordSearchBoardState();
}

class _WordSearchBoardState extends State<WordSearchBoard> with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = WordsLocalizations.of(context);
    final colors = Theme.of(context).extension<WordSearchColors>()!;
    final c = widget.controller;
    final size = c.size;
    final extent = widget.cellExtent;
    final found = c.foundCells;
    final selection = c.selection.toSet();
    final hint = c.hintCell;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (hint != null && !reduceMotion && !_blink.isAnimating) {
      _blink.repeat(reverse: true);
    } else if (hint == null && _blink.isAnimating) {
      _blink.stop();
    }

    String label(int i) {
      final state = [
        if (found.contains(i)) l10n.cellInWord,
        if (selection.contains(i)) l10n.cellSelected,
        if (hint == i) l10n.cellHint,
      ].join();
      return l10n.cellLabel(i ~/ size + 1, i % size + 1, c.puzzle.letters[i], state);
    }

    final grid = PuzzleGrid(
      dimensions: GridDimensions(columns: size, rows: size),
      fixedCellExtent: extent,
      semanticLabel: l10n.boardLabel(size),
      semanticLabelFor: label,
      onCellTap: widget.tapMode ? (i) => widget.onResult(c.tapCell(i)) : null,
      onDragStart: widget.tapMode ? null : c.dragStart,
      onDragUpdate: widget.tapMode ? null : c.dragUpdate,
      onDragEnd: widget.tapMode ? null : () => widget.onResult(c.dragEnd()),
      cellBuilder: (context, i, extent) {
        final selected = selection.contains(i);
        final letter = Text(
          c.puzzle.letters[i],
          style: LudixaTypography.gridLetter().copyWith(
            fontSize: (extent * 0.6).clamp(12.0, 22.0),
            color: selected ? colors.onSelecting : (found.contains(i) ? colors.foundInk : colors.letter),
          ),
        );
        if (i != hint) return Center(child: letter);
        return AnimatedBuilder(
          animation: _blink,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.selecting.withValues(alpha: reduceMotion ? 0.35 : 0.15 + 0.45 * _blink.value),
            ),
            child: child,
          ),
          child: Center(child: letter),
        );
      },
    );

    return SizedBox(
      width: extent * size,
      height: extent * size,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WordCapsulesPainter(
                found: [for (final w in c.game.foundOrder) c.puzzle.placements[w].cells],
                selection: c.selection,
                size: size,
                extent: extent,
                colors: colors,
              ),
            ),
          ),
          grid,
        ],
      ),
    );
  }
}

/// Cápsulas redondeadas de centro a centro de la primera y la última letra.
/// También las usa el tutorial.
class WordCapsulesPainter extends CustomPainter {
  WordCapsulesPainter({
    required this.found,
    required this.selection,
    required this.size,
    required this.extent,
    required this.colors,
  });

  final List<List<int>> found;
  final List<int> selection;
  final int size;
  final double extent;
  final WordSearchColors colors;

  Offset _center(int cell) => Offset((cell % size + 0.5) * extent, (cell ~/ size + 0.5) * extent);

  void _capsule(Canvas canvas, List<int> cells, Color color) {
    if (cells.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = extent * 0.78
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(_center(cells.first), _center(cells.last), paint);
  }

  @override
  void paint(Canvas canvas, Size _) {
    for (final cells in found) {
      _capsule(canvas, cells, colors.found);
    }
    _capsule(canvas, selection, colors.selecting);
  }

  @override
  bool shouldRepaint(WordCapsulesPainter old) => true;
}
