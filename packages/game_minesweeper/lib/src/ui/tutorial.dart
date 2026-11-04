import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/mines_localizations.dart';
import '../settings.dart';

enum _Kind { number, flag, chord }

/// Un paso del tutorial sobre un tablero de 5×5. Solo importa el 3×3 del
/// centro: el resto queda cerrado y no responde.
final class _Lesson {
  const _Lesson(this.kind, {required this.mine, required this.flagged, required this.revealed});

  final _Kind kind;
  final int mine;
  final bool flagged;

  /// Vecinas del centro que empiezan abiertas.
  final Set<int> revealed;
}

const _center = 12;
const _neighbors = [6, 7, 8, 11, 13, 16, 17, 18];
const _lessons = [
  _Lesson(_Kind.number, mine: 6, flagged: true, revealed: {}),
  _Lesson(_Kind.flag, mine: 8, flagged: false, revealed: {6, 7, 11, 13, 16, 17, 18}),
  _Lesson(_Kind.chord, mine: 6, flagged: true, revealed: {}),
];

/// Tutorial jugable de la primera vez: qué significa un número, poner
/// bandera y abrir vecinas tocando un número. Un error se explica sin
/// castigo y "Saltar tutorial" siempre está visible. Sin anuncios.
class MinesweeperTutorial extends StatefulWidget {
  const MinesweeperTutorial({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<MinesweeperTutorial> createState() => _MinesweeperTutorialState();
}

class _MinesweeperTutorialState extends State<MinesweeperTutorial> {
  int _step = 0;
  late Set<int> _revealed;
  late bool _flagged;
  TapAction _mode = TapAction.reveal;
  String? _feedback;
  bool _done = false;

  _Lesson get _lesson => _lessons[_step];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _revealed = {..._lesson.revealed};
    _flagged = _lesson.flagged;
    _mode = TapAction.reveal;
    _feedback = null;
    _done = false;
  }

  int _numberAt(int cell) {
    final mine = _lesson.mine;
    final dr = (cell ~/ 5 - mine ~/ 5).abs(), dc = (cell % 5 - mine % 5).abs();
    return cell != mine && dr <= 1 && dc <= 1 ? 1 : 0;
  }

  void _act(int cell, TapAction action) {
    if (_done || (cell != _center && !_neighbors.contains(cell))) return;
    final l10n = MinesLocalizations.of(context);
    final lesson = _lesson;
    setState(() {
      if (action == TapAction.flag) {
        if (cell == lesson.mine && !_flagged && lesson.kind == _Kind.flag) {
          _flagged = true;
          _finish(l10n);
        }
        return;
      }
      if (cell == lesson.mine) {
        _feedback = _flagged ? l10n.tutorialWrongFlagged : l10n.tutorialWrongMine;
        return;
      }
      if (cell == _center) {
        if (lesson.kind == _Kind.chord) {
          _revealed.addAll(_neighbors.where((n) => n != lesson.mine));
          _finish(l10n);
        }
        return;
      }
      if (_revealed.contains(cell)) return;
      _revealed.add(cell);
      switch (lesson.kind) {
        case _Kind.number:
          _finish(l10n);
        case _Kind.chord:
          _feedback = l10n.tutorialWrongChord;
          if (_neighbors.every((n) => n == lesson.mine || _revealed.contains(n))) _finish(l10n);
        case _Kind.flag:
          break;
      }
    });
  }

  void _finish(MinesLocalizations l10n) {
    _done = true;
    _feedback = l10n.tutorialRight;
  }

  void _next() {
    if (_step == _lessons.length - 1) {
      widget.onDone();
    } else {
      setState(() {
        _step++;
        _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final colors = Theme.of(context).extension<MinesweeperColors>()!;
    final (rule, task) = switch (_lesson.kind) {
      _Kind.number => (l10n.tutorialRuleNumber, l10n.tutorialTaskNumber),
      _Kind.flag => (l10n.tutorialRuleFlag, l10n.tutorialTaskFlag),
      _Kind.chord => (l10n.tutorialRuleChord, l10n.tutorialTaskChord),
    };
    final body = text.bodyLarge?.copyWith(fontSize: 16);

    Widget cell(BuildContext context, int i, double extent) {
      final active = i == _center || _neighbors.contains(i);
      final open = i == _center || _revealed.contains(i);
      final flag = i == _lesson.mine && _flagged;
      final n = i == _center ? 1 : _numberAt(i);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: open ? colors.open : (active ? colors.closed : colors.closedFaded),
          borderRadius: BorderRadius.circular(6),
          border: open ? null : Border(bottom: BorderSide(color: colors.closedEdge, width: 2)),
        ),
        child: Center(
          child: flag
              ? LudixaIcon(LudixaIcons.flagFilled, color: colors.flag, size: extent * 0.6)
              : open && n > 0
              ? Text('$n', style: LudixaTypography.gridLetter().copyWith(color: colors.number(n)))
              : null,
        ),
      );
    }

    String label(int i) {
      final open = i == _center || _revealed.contains(i);
      final content = i == _lesson.mine && _flagged
          ? l10n.cellFlagged
          : open
          ? ((i == _center ? 1 : _numberAt(i)) == 0 ? l10n.cellEmpty : l10n.cellNumber(i == _center ? 1 : _numberAt(i)))
          : l10n.cellHidden;
      return l10n.cellLabel(i ~/ 5 + 1, i % 5 + 1, content);
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.tutorialStep(_step + 1))),
      // Al pie y no en la barra: siempre visible, también con texto grande.
      persistentFooterButtons: [TextButton(onPressed: widget.onDone, child: Text(l10n.tutorialSkip))],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: LudixaLayout.page(context, top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(rule, style: text.titleLarge),
              const SizedBox(height: 8),
              Text(task, style: body),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 5 * 52 + 4 * 4,
                  child: PuzzleGrid(
                    dimensions: const GridDimensions(columns: 5, rows: 5),
                    fixedCellExtent: 52,
                    gap: 4,
                    semanticLabel: l10n.tutorialBoardLabel,
                    semanticLabelFor: label,
                    cellBuilder: cell,
                    onCellTap: (i) => _act(i, _mode),
                    onCellLongPress: (i) => _act(i, _mode == TapAction.reveal ? TapAction.flag : TapAction.reveal),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_lesson.kind == _Kind.flag)
                LudixaSegmentedControl<TapAction>(
                  segments: [
                    LudixaSegment(value: TapAction.reveal, label: l10n.modeReveal, icon: LudixaIcons.reveal),
                    LudixaSegment(value: TapAction.flag, label: l10n.modeFlag, icon: LudixaIcons.flag),
                  ],
                  selected: _mode,
                  onChanged: (v) => setState(() => _mode = v),
                ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(_feedback ?? '', style: body?.copyWith(color: _done ? p.successInk : p.ink)),
              ),
              const SizedBox(height: 16),
              if (_done)
                LudixaButton(
                  label: _step == _lessons.length - 1 ? l10n.tutorialStart : l10n.tutorialNext,
                  onPressed: _next,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
