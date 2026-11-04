import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:game_api/game_api.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'settings.dart';

/// Estado de una partida de Sopa de letras en la interfaz: envuelve
/// [WordSearchGame] y agrega la selección en curso (arrastre ajustado a 8
/// direcciones, o toque inicial y final), el tiempo, la pista y el host.
class WordSearchController extends ChangeNotifier {
  WordSearchController({
    required WordSearchGame game,
    required this.host,
    required this.themeNames,
    this.settings = const WordSearchSettings(),
    Duration elapsed = Duration.zero,
    this.freeHints = 0,
    this.rewardedHints = 0,
  }) : _game = game,
       _elapsed = elapsed;

  static const int snapshotVersion = 1;

  factory WordSearchController.resume(
    SessionSnapshot snapshot, {
    required GameHost host,
    WordSearchSettings settings = const WordSearchSettings(),
  }) {
    final state = snapshot.state;
    if (state['v'] != snapshotVersion) throw FormatException('Instantánea desconocida', state['v']);
    return WordSearchController(
      game: WordSearchGame.fromJson((state['game']! as Map).cast<String, Object?>()),
      host: host,
      themeNames: (state['themes'] as List? ?? const []).cast<String>(),
      settings: settings,
      elapsed: snapshot.elapsed,
      freeHints: state['freeHints'] as int? ?? 0,
      rewardedHints: state['rewardedHints'] as int? ?? 0,
    );
  }

  WordSearchGame _game;
  WordSearchGame get game => _game;
  final GameHost host;

  /// Nombres de los temas, en el idioma de las palabras.
  final List<String> themeNames;
  WordSearchSettings settings;

  int? _anchor;
  int? _end;
  int? _hintCell;
  int? _hintWord;
  bool _paused = false;
  bool _hintsExhausted = false;
  bool _reported = false;
  Duration _elapsed;
  int freeHints;
  int rewardedHints;

  WordSearchPuzzle get puzzle => game.puzzle;
  int get size => puzzle.size;
  bool get paused => _paused;
  bool get complete => game.isComplete;
  bool get hintsExhausted => _hintsExhausted;
  Duration get elapsed => _elapsed;

  /// Celda que parpadea por la pista (inicio de una palabra pendiente).
  int? get hintCell => _hintCell;

  /// Primera letra elegida en el modo de toque, o el inicio del arrastre.
  int? get anchor => _anchor;

  /// Celdas de la selección en curso.
  List<int> get selection {
    final a = _anchor;
    if (a == null) return const [];
    final e = _end;
    return e == null ? [a] : game.lineBetween(a, e);
  }

  /// Letras de la selección en curso, para la burbuja.
  String get selectionText => [for (final c in selection) puzzle.letters[c]].join();

  /// Celdas de las palabras ya encontradas.
  Set<int> get foundCells => {for (final i in game.foundOrder) ...puzzle.placements[i].cells};

  bool get _blocked => _paused || complete;

  // ── Arrastre ───────────────────────────────────────────────────────────

  void dragStart(int cell) {
    if (_blocked) return;
    _anchor = cell;
    _end = null;
    notifyListeners();
  }

  void dragUpdate(int cell) {
    final a = _anchor;
    if (_blocked || a == null) return;
    _end = snap(a, cell, size);
    notifyListeners();
  }

  /// Al soltar se valida la selección. Si no es una palabra, se desvanece sin
  /// penalización.
  ({SelectionOutcome outcome, int? wordIndex}) dragEnd() {
    final a = _anchor, e = _end;
    _anchor = null;
    _end = null;
    if (_blocked || a == null || e == null) {
      notifyListeners();
      return (outcome: SelectionOutcome.miss, wordIndex: null);
    }
    return _select(a, e);
  }

  // ── Toque inicial y final ──────────────────────────────────────────────

  ({SelectionOutcome outcome, int? wordIndex})? tapCell(int cell) {
    if (_blocked) return null;
    final a = _anchor;
    if (a == null) {
      _anchor = cell;
      _end = null;
      notifyListeners();
      return null;
    }
    _anchor = null;
    _end = null;
    if (a == cell) {
      notifyListeners();
      return null;
    }
    return _select(a, snap(a, cell, size));
  }

  ({SelectionOutcome outcome, int? wordIndex}) _select(int from, int to) {
    final result = game.select(from, to);
    if (result.outcome == SelectionOutcome.found) {
      if (result.wordIndex == _hintWord) {
        _hintCell = null;
        _hintWord = null;
      }
      _saveSnapshot();
    }
    notifyListeners();
    return result;
  }

  /// Ajusta [to] a la recta más cercana desde [from] (8 direcciones) y la
  /// recorta para que no salga de la grilla.
  static int snap(int from, int to, int size) {
    final fr = from ~/ size, fc = from % size;
    final dr = to ~/ size - fr, dc = to % size - fc;
    if (dr == 0 && dc == 0) return from;
    final step = (math.atan2(dr.toDouble(), dc.toDouble()) / (math.pi / 4)).round();
    final sr = math.sin(step * math.pi / 4).round(), sc = math.cos(step * math.pi / 4).round();
    var length = math.max(dr.abs(), dc.abs());
    while (length > 0) {
      final r = fr + sr * length, c = fc + sc * length;
      if (r >= 0 && r < size && c >= 0 && c < size) return r * size + c;
      length--;
    }
    return from;
  }

  // ── Pista, pausa y tiempo ──────────────────────────────────────────────

  /// Hace parpadear la primera letra de una palabra pendiente. Un crédito.
  Future<void> requestHint() async {
    if (_blocked || _hintsExhausted || _hintCell != null) return;
    final hint = game.hint();
    if (hint == null) return;
    final grant = await host.requestHint();
    switch (grant) {
      case HintDenied(reason: HintDenial.limitReached):
        _hintsExhausted = true;
      case HintDenied():
        return;
      case HintGranted(:final source):
        if (source == HintSource.free) {
          freeHints++;
        } else {
          rewardedHints++;
        }
        _hintCell = hint.startCell;
        _hintWord = hint.wordIndex;
        _saveSnapshot();
    }
    notifyListeners();
  }

  /// Aplica ajustes nuevos (por ejemplo, cambiados desde la pausa).
  void applySettings(WordSearchSettings next) {
    settings = next;
    _anchor = null;
    _end = null;
    notifyListeners();
  }

  /// Empieza la misma sopa de cero ("Reiniciar" en la pausa).
  void restart() {
    _game = WordSearchGame(_game.puzzle);
    _anchor = null;
    _end = null;
    _hintCell = null;
    _hintWord = null;
    _hintsExhausted = false;
    _elapsed = Duration.zero;
    freeHints = 0;
    rewardedHints = 0;
    _saveSnapshot();
    notifyListeners();
  }

  void pause() {
    if (_paused || complete) return;
    _paused = true;
    _anchor = null;
    _end = null;
    _saveSnapshot();
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    notifyListeners();
  }

  void tick(Duration delta) {
    if (_blocked) return;
    _elapsed += delta;
    notifyListeners();
  }

  Future<void> reportWon() async {
    if (!complete || _reported) return;
    _reported = true;
    await host.reportResult(
      GameResult(
        outcome: GameOutcome.won,
        elapsed: _elapsed,
        freeHintsUsed: freeHints,
        rewardedHintsUsed: rewardedHints,
      ),
    );
  }

  SessionSnapshot snapshot() => SessionSnapshot(
    state: {
      'v': snapshotVersion,
      'game': game.toJson(),
      'themes': themeNames,
      'freeHints': freeHints,
      'rewardedHints': rewardedHints,
    },
    elapsed: _elapsed,
    freeHintsUsed: freeHints,
    rewardedHintsUsed: rewardedHints,
  );

  void _saveSnapshot() => unawaited(host.saveSnapshot(snapshot()));
}
