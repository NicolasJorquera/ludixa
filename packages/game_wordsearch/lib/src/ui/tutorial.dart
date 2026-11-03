import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/words_localizations.dart';
import '../controller.dart';
import 'board.dart';

enum _Kind { drag, directions, list }

/// Un paso del tutorial: una sopa de 6×6 con una palabra a encontrar.
final class _Lesson {
  const _Lesson(this.kind, this.rows, this.target, {this.words = const [], this.found = const []});

  final _Kind kind;
  final List<String> rows;
  final List<int> target;

  /// Lista del paso 3 (la primera ya encontrada) y sus celdas.
  final List<String> words;
  final List<int> found;
}

// Las letras de relleno no forman otras palabras de la lista.
const _lessons = {
  'es': [
    _Lesson(_Kind.drag, ['QWEXTB', 'NZRPUJ', 'KSOLVA', 'HYDCGF', 'IWMBTQ', 'JEXNPZ'], [13, 14, 15]),
    _Lesson(_Kind.directions, ['TQEXLB', 'NMRPUJ', 'KDAHVO', 'HYCRGF', 'IWEBTQ', 'JSXNPZ'], [7, 14, 21]),
    _Lesson(
      _Kind.list,
      ['PANQWX', 'BRTEJC', 'KHMOLV', 'DYCSUF', 'IWGBZQ', 'JEXNPT'],
      [16, 22, 28],
      words: ['PAN', 'LUZ'],
      found: [0, 1, 2],
    ),
  ],
  'en': [
    _Lesson(_Kind.drag, ['QWEXTB', 'NZRPUJ', 'KSUNVA', 'HYDCGF', 'IWMBTQ', 'JEXLPZ'], [13, 14, 15]),
    _Lesson(_Kind.directions, ['TQEXLB', 'NSRPUJ', 'KDEHVO', 'HYCAGF', 'IWUBTQ', 'JMXNPZ'], [7, 14, 21]),
    _Lesson(
      _Kind.list,
      ['CATQWX', 'BRMEJK', 'KHLUDV', 'PYZSOF', 'IWNBGQ', 'JEXNPT'],
      [16, 22, 28],
      words: ['CAT', 'DOG'],
      found: [0, 1, 2],
    ),
  ],
};

/// Tutorial jugable de la primera vez: arrastrar, direcciones y lista. Un
/// error se explica sin castigo y "Saltar tutorial" siempre está visible.
class WordSearchTutorial extends StatefulWidget {
  const WordSearchTutorial({super.key, required this.language, required this.onDone});

  /// Idioma de las palabras de práctica (`es` o `en`).
  final String language;
  final VoidCallback onDone;

  @override
  State<WordSearchTutorial> createState() => _WordSearchTutorialState();
}

class _WordSearchTutorialState extends State<WordSearchTutorial> {
  static const _size = 6;
  int _step = 0;
  int? _anchor;
  int? _end;
  bool _done = false;
  bool _wrong = false;

  List<_Lesson> get _set => _lessons[widget.language] ?? _lessons['en']!;
  _Lesson get _lesson => _set[_step];

  List<int> get _selection {
    final a = _anchor;
    if (a == null) return const [];
    final e = _end ?? a;
    final dr = (e ~/ _size - a ~/ _size).sign, dc = (e % _size - a % _size).sign;
    final steps = ((e ~/ _size - a ~/ _size).abs()).clamp((e % _size - a % _size).abs(), 99);
    return [for (var k = 0; k <= steps; k++) (a ~/ _size + dr * k) * _size + a % _size + dc * k];
  }

  void _start(int cell) => setState(() {
    if (_done) return;
    _anchor = cell;
    _end = null;
  });

  void _update(int cell) => setState(() {
    if (_anchor != null) _end = WordSearchController.snap(_anchor!, cell, _size);
  });

  void _release() => setState(() {
    final selection = _selection;
    _anchor = null;
    _end = null;
    if (_done || selection.length < 2) return;
    final target = _lesson.target;
    final hit =
        selection.length == target.length &&
        (List.generate(target.length, (k) => selection[k] == target[k]).every((x) => x) ||
            List.generate(target.length, (k) => selection[k] == target[target.length - 1 - k]).every((x) => x));
    _done = hit;
    _wrong = !hit;
  });

  /// Modo de toque (TalkBack): primera letra y luego la última.
  void _tap(int cell) {
    if (_anchor == null) {
      _start(cell);
    } else {
      _update(cell);
      _release();
    }
  }

  void _next() {
    if (_step == _set.length - 1) {
      widget.onDone();
    } else {
      setState(() {
        _step++;
        _done = false;
        _wrong = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = WordsLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final colors = Theme.of(context).extension<WordSearchColors>()!;
    final lesson = _lesson;
    final letters = lesson.rows.join().split('');
    final tapMode = MediaQuery.of(context).accessibleNavigation;
    final (rule, task) = switch (lesson.kind) {
      _Kind.drag => (l10n.tutorialRuleDrag, l10n.tutorialTaskDrag),
      _Kind.directions => (l10n.tutorialRuleDirections, l10n.tutorialTaskDirections),
      _Kind.list => (l10n.tutorialRuleList, l10n.tutorialTaskList),
    };
    final found = [if (lesson.found.isNotEmpty) lesson.found, if (_done) lesson.target];
    const extent = 48.0;
    final body = text.bodyLarge?.copyWith(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.tutorialStep(_step + 1)),
        actions: [TextButton(onPressed: widget.onDone, child: Text(l10n.tutorialSkip))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(rule, style: text.titleLarge),
              const SizedBox(height: 8),
              Text(task, style: body),
              const SizedBox(height: 16),
              Center(
                child: SizedBox.square(
                  dimension: extent * _size,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WordCapsulesPainter(
                            found: found,
                            selection: _selection,
                            size: _size,
                            extent: extent,
                            colors: colors,
                          ),
                        ),
                      ),
                      PuzzleGrid(
                        dimensions: const GridDimensions(columns: _size, rows: _size),
                        fixedCellExtent: extent,
                        semanticLabel: l10n.tutorialBoardLabel,
                        semanticLabelFor: (i) => l10n.cellLabel(i ~/ _size + 1, i % _size + 1, letters[i], ''),
                        onCellTap: tapMode ? _tap : null,
                        onDragStart: tapMode ? null : _start,
                        onDragUpdate: tapMode ? null : _update,
                        onDragEnd: tapMode ? null : _release,
                        cellBuilder: (context, i, extent) => Center(
                          child: Text(letters[i], style: LudixaTypography.gridLetter().copyWith(color: colors.letter)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (lesson.words.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (i, word) in lesson.words.indexed)
                      Text(
                        word,
                        style: text.labelLarge?.copyWith(
                          decoration: i == 0 || _done ? TextDecoration.lineThrough : null,
                          color: i == 0 || _done ? p.inkMuted : p.ink,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  _done
                      ? l10n.tutorialRight
                      : _wrong
                      ? l10n.tutorialWrong
                      : '',
                  style: body?.copyWith(color: _done ? p.successInk : p.ink),
                ),
              ),
              const SizedBox(height: 16),
              if (_done)
                LudixaButton(
                  label: _step == _set.length - 1 ? l10n.tutorialStart : l10n.tutorialNext,
                  onPressed: _next,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
