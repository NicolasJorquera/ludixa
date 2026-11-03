import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/sudoku_localizations.dart';

enum _Rule { row, column, box }

/// Un paso del tutorial: una regla, un tablero de 4×4 y la celda a llenar.
final class _Lesson {
  const _Lesson(this.rule, this.cells, this.target, this.answer);

  final _Rule rule;

  /// 16 celdas, 0 = vacía.
  final List<int> cells;
  final int target;
  final int answer;

  /// Celdas de la zona que explica la regla.
  Set<int> get zone => switch (rule) {
    _Rule.row => {for (var c = 0; c < 4; c++) (target ~/ 4) * 4 + c},
    _Rule.column => {for (var r = 0; r < 4; r++) r * 4 + target % 4},
    _Rule.box => {
      for (var r = 0; r < 2; r++)
        for (var c = 0; c < 2; c++) ((target ~/ 4) ~/ 2 * 2 + r) * 4 + (target % 4) ~/ 2 * 2 + c,
    },
  };
}

// La respuesta sale solo de la regla del paso: los demás números no ayudan.
const _lessons = [
  _Lesson(_Rule.row, [1, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 2, 3),
  _Lesson(_Rule.column, [0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0], 5, 2),
  _Lesson(_Rule.box, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0, 0, 2, 0], 15, 3),
];

/// Tutorial jugable de la primera vez: fila, columna y caja en un tablero de
/// 4×4. Un error se explica sin penalizar, y "Saltar tutorial" siempre está
/// visible. Sin anuncios.
class SudokuTutorial extends StatefulWidget {
  const SudokuTutorial({super.key, required this.onDone});

  /// Al terminar o al saltarlo.
  final VoidCallback onDone;

  @override
  State<SudokuTutorial> createState() => _SudokuTutorialState();
}

class _SudokuTutorialState extends State<SudokuTutorial> {
  int _step = 0;
  int? _tried;

  _Lesson get _lesson => _lessons[_step];
  bool get _solved => _tried == _lesson.answer;

  void _answer(int digit) => setState(() => _tried = digit);

  void _next() {
    if (_step == _lessons.length - 1) {
      widget.onDone();
    } else {
      setState(() {
        _step++;
        _tried = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final lesson = _lesson;
    final rule = switch (lesson.rule) {
      _Rule.row => l10n.tutorialRuleRow,
      _Rule.column => l10n.tutorialRuleColumn,
      _Rule.box => l10n.tutorialRuleBox,
    };
    final tried = _tried;
    final String? feedback = tried == null
        ? null
        : _solved
        ? l10n.tutorialRight(tried)
        : switch (lesson.rule) {
            _Rule.row => l10n.tutorialWrongRow(tried),
            _Rule.column => l10n.tutorialWrongColumn(tried),
            _Rule.box => l10n.tutorialWrongBox(tried),
          };
    // Texto de al menos 16 sp (ficha UX del tutorial).
    final body = text.bodyLarge?.copyWith(fontSize: 16);

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
              Text(l10n.tutorialAsk, style: body),
              const SizedBox(height: 16),
              Center(
                child: _MiniBoard(lesson: lesson, entered: _solved ? lesson.answer : null),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var d = 1; d <= 4; d++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: _solved ? null : () => _answer(d),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                          child: Text('$d', style: LudixaTypography.gridDigit(entered: true)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(feedback ?? '', style: body?.copyWith(color: _solved ? p.successInk : p.ink)),
              ),
              const SizedBox(height: 16),
              if (_solved)
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

class _MiniBoard extends StatelessWidget {
  const _MiniBoard({required this.lesson, required this.entered});

  final _Lesson lesson;
  final int? entered;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final colors = Theme.of(context).extension<SudokuColors>()!;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    const extent = 56.0;
    final zone = lesson.zone;
    return Semantics(
      label: l10n.tutorialBoardLabel,
      container: true,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: colors.thickLine, width: 2)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < 4; r++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 4; c++)
                    Builder(
                      builder: (context) {
                        final i = r * 4 + c;
                        final value = i == lesson.target ? (entered ?? 0) : lesson.cells[i];
                        final target = i == lesson.target;
                        return Semantics(
                          label: l10n.cellLabel(
                            r + 1,
                            c + 1,
                            [if (value == 0) l10n.cellEmpty else '$value', if (target) l10n.cellSelected].join(', '),
                          ),
                          child: ExcludeSemantics(
                            child: Container(
                              width: extent,
                              height: extent,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: target ? colors.selected : (zone.contains(i) ? colors.zone : colors.cell),
                                border: Border(
                                  right: BorderSide(
                                    color: c == 1 ? colors.thickLine : colors.thinLine,
                                    width: c == 1 ? 2 : 1,
                                  ),
                                  bottom: BorderSide(
                                    color: r == 1 ? colors.thickLine : colors.thinLine,
                                    width: r == 1 ? 2 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                value == 0 ? '' : '$value',
                                style: LudixaTypography.gridDigit(
                                  entered: target,
                                ).copyWith(color: target ? p.sudoku : colors.given),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
