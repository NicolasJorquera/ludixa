import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_api/game_api.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import 'settings.dart';

/// Estado de una partida de Sudoku en la interfaz: envuelve [SudokuGame] y
/// agrega selección, modo de notas, tiempo y la comunicación con el host.
///
/// Cada cambio en la grilla envía una instantánea al host para que la
/// partida se retome exactamente donde quedó.
class SudokuController extends ChangeNotifier {
  SudokuController({
    required this.game,
    required this.host,
    this.settings = const SudokuSettings(),
    Duration elapsed = Duration.zero,
    this.freeHints = 0,
    this.rewardedHints = 0,
  }) : _elapsed = elapsed {
    game.removeNotesOnPlace = settings.removeNotesOnPlace;
  }

  /// Formato del estado guardado en [SessionSnapshot.state].
  static const int snapshotVersion = 1;

  /// Retoma una partida guardada.
  factory SudokuController.resume(SessionSnapshot snapshot, {required GameHost host, SudokuSettings? settings}) {
    final state = snapshot.state;
    if (state['v'] != snapshotVersion) throw FormatException('Instantánea desconocida', state['v']);
    return SudokuController(
      game: SudokuGame.fromJson((state['game']! as Map).cast<String, Object?>()),
      host: host,
      settings: settings ?? const SudokuSettings(),
      elapsed: snapshot.elapsed,
      freeHints: state['freeHints'] as int? ?? 0,
      rewardedHints: state['rewardedHints'] as int? ?? 0,
    );
  }

  final SudokuGame game;
  final GameHost host;
  SudokuSettings settings;

  int? _selected;
  int? _activeDigit;
  bool _notesMode = false;
  bool _paused = false;
  bool _hintsExhausted = false;
  bool _reported = false;
  Duration _elapsed;
  int freeHints;
  int rewardedHints;

  int? get selected => _selected;

  /// Número elegido en el modo "número primero".
  int? get activeDigit => _activeDigit;
  bool get notesMode => _notesMode;
  bool get paused => _paused;
  bool get solved => game.isSolved;
  bool get hintsExhausted => _hintsExhausted;
  Duration get elapsed => _elapsed;

  int get progressPercent => game.emptyAtStart == 0 ? 100 : (100 * game.filledByPlayer / game.emptyAtStart).round();

  /// Número que se resalta en toda la grilla.
  int? get highlightedDigit {
    if (!settings.highlightSameNumber) return null;
    if (settings.inputMode == SudokuInputMode.numberFirst && _activeDigit != null) return _activeDigit;
    final s = _selected;
    if (s == null) return null;
    final v = game.valueAt(s);
    return v == 0 ? null : v;
  }

  /// Celdas que se marcan como error según el modo elegido.
  Set<int> get errorCells => switch (settings.errorMode) {
    SudokuErrorMode.conflicts => game.conflicts,
    SudokuErrorMode.solution => game.mistakes,
    SudokuErrorMode.none => const {},
  };

  bool inSelectedZone(int cell) {
    final s = _selected;
    return s != null && (s == cell || SudokuGrid.arePeers(s, cell));
  }

  void tapCell(int cell) {
    if (_blocked) return;
    _selected = cell;
    final digit = _activeDigit;
    if (settings.inputMode == SudokuInputMode.numberFirst && digit != null) {
      _apply(cell, digit);
    } else {
      notifyListeners();
    }
  }

  void tapDigit(int digit) {
    if (_blocked) return;
    if (settings.inputMode == SudokuInputMode.numberFirst) {
      _activeDigit = _activeDigit == digit ? null : digit;
      notifyListeners();
      return;
    }
    final cell = _selected;
    if (cell != null) _apply(cell, digit);
  }

  void toggleNotes() {
    if (_blocked) return;
    _notesMode = !_notesMode;
    notifyListeners();
  }

  void erase() {
    final cell = _selected;
    if (_blocked || cell == null) return;
    if (game.erase(cell)) _moved();
  }

  void undo() {
    if (_blocked) return;
    if (game.undo()) _moved();
  }

  /// Pide una pista al host. La hoja de 3 pasos llega en H4-02: por ahora, si
  /// hay un número equivocado se selecciona; si no, se coloca el siguiente.
  Future<void> hint() async {
    if (_blocked || _hintsExhausted) return;
    final grant = await host.requestHint();
    switch (grant) {
      case HintDenied(reason: HintDenial.limitReached):
        _hintsExhausted = true;
        notifyListeners();
      case HintDenied():
        return;
      case HintGranted(:final source):
        if (source == HintSource.free) {
          freeHints++;
        } else {
          rewardedHints++;
        }
        final hint = SudokuHinter.hint(game.values, game.puzzle.solution);
        if (hint == null) return;
        if (hint.isError) {
          _selected = hint.errorCell;
          _saveSnapshot();
          notifyListeners();
        } else {
          _selected = hint.cell;
          game.place(hint.cell!, hint.digit!);
          _moved();
        }
    }
  }

  void pause() {
    if (_paused || solved) return;
    _paused = true;
    _saveSnapshot();
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    notifyListeners();
  }

  /// Suma tiempo de juego. Lo llama el temporizador de la pantalla.
  void tick(Duration delta) {
    if (_paused || solved) return;
    _elapsed += delta;
    notifyListeners();
  }

  /// Informa el resultado una sola vez, después de la celebración.
  Future<void> reportSolved() async {
    if (!solved || _reported) return;
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
    state: {'v': snapshotVersion, 'game': game.toJson(), 'freeHints': freeHints, 'rewardedHints': rewardedHints},
    elapsed: _elapsed,
  );

  bool get _blocked => _paused || solved;

  void _apply(int cell, int digit) {
    final changed = _notesMode ? game.toggleNote(cell, digit) : game.place(cell, digit);
    if (changed) {
      _moved();
    } else {
      notifyListeners();
    }
  }

  void _moved() {
    _saveSnapshot();
    notifyListeners();
  }

  void _saveSnapshot() => unawaited(host.saveSnapshot(snapshot()));
}
