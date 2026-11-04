import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_api/game_api.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import 'settings.dart';

/// Paso de la hoja de pista.
enum HintStep {
  /// Señala un número equivocado del jugador (antes que cualquier deducción).
  error,

  /// 1 de 3: resalta la zona.
  zone,

  /// 2 de 3: nombra la técnica y resalta las celdas implicadas.
  technique,

  /// 3 de 3: coloca el número.
  number,
}

/// Pista abierta: la deducción y el paso en que va.
final class HintSession {
  const HintSession(this.hint, this.step);

  final SudokuHint hint;
  final HintStep step;

  /// Celda que se marca con borde (desde el paso 2, o el error).
  int? get target => switch (step) {
    HintStep.error => hint.errorCell,
    HintStep.zone => null,
    _ => hint.cell,
  };

  /// Celdas de la zona que se resaltan (filas, columnas y cajas).
  Set<int> get zoneCells {
    final cell = hint.cell;
    if (step == HintStep.error || cell == null) return const {};
    // Sin zonas propias (único candidato): su fila, columna y caja.
    final units = hint.units.isEmpty ? SudokuGrid.unitsOfCell[cell] : hint.units;
    return {for (final u in units) ...SudokuGrid.units[u]};
  }

  /// Celdas del patrón de la técnica (paso 2).
  Set<int> get patternCells => step == HintStep.technique ? hint.pattern.toSet() : const {};
}

/// Estado de una partida de Sudoku en la interfaz: envuelve [SudokuGame] y
/// agrega selección, modo de notas, tiempo y la comunicación con el host.
///
/// Cada cambio en la grilla envía una instantánea al host para que la
/// partida se retome exactamente donde quedó.
class SudokuController extends ChangeNotifier {
  SudokuController({
    required SudokuGame game,
    required this.host,
    this.settings = const SudokuSettings(),
    Duration elapsed = Duration.zero,
    this.freeHints = 0,
    this.rewardedHints = 0,
  }) : _game = game,
       _elapsed = elapsed {
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

  SudokuGame _game;
  SudokuGame get game => _game;
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

  HintSession? _hint;

  /// Pista abierta, o null. Mientras está abierta el tiempo no corre.
  HintSession? get hintSession => _hint;

  /// Pide una pista al host. Una pista es una cadena de hasta 3 pasos y
  /// consume un solo crédito (PRD). Si hay un número equivocado, lo señala
  /// primero; si la técnica no está implementada, revela la celda.
  Future<void> hint() async {
    if (_blocked || _hintsExhausted || _hint != null) return;
    final hint = SudokuHinter.hint(game.values, game.puzzle.solution);
    if (hint == null) return;
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
        if (hint.isError) {
          _hint = HintSession(hint, HintStep.error);
          _selected = hint.errorCell;
          _saveSnapshot();
          notifyListeners();
        } else if (hint.technique == null) {
          _hint = HintSession(hint, HintStep.number);
          _placeHint(hint);
        } else {
          _hint = HintSession(hint, HintStep.zone);
          _saveSnapshot();
          notifyListeners();
        }
    }
  }

  /// Avanza la pista: zona → técnica → número.
  void hintNext() {
    final session = _hint;
    if (session == null) return;
    switch (session.step) {
      case HintStep.zone:
        _hint = HintSession(session.hint, HintStep.technique);
        notifyListeners();
      case HintStep.technique:
        _hint = HintSession(session.hint, HintStep.number);
        _placeHint(session.hint);
      case HintStep.error || HintStep.number:
        hintClose();
    }
  }

  /// Borra el número equivocado que señaló la pista y la cierra.
  void hintEraseError() {
    final cell = _hint?.hint.errorCell;
    _hint = null;
    if (cell != null && game.erase(cell)) {
      _moved();
    } else {
      notifyListeners();
    }
  }

  /// Cierra la pista ("Lo intento yo"). El crédito ya se consumió.
  void hintClose() {
    if (_hint == null) return;
    _hint = null;
    notifyListeners();
  }

  void _placeHint(SudokuHint hint) {
    final cell = hint.cell!;
    _selected = cell;
    if (game.valueAt(cell) != hint.digit) game.place(cell, hint.digit!);
    _moved();
  }

  /// Empieza el mismo puzzle de cero ("Reiniciar" en la pausa).
  void restart() {
    _game = SudokuGame(_game.puzzle, removeNotesOnPlace: settings.removeNotesOnPlace);
    _selected = null;
    _activeDigit = null;
    _notesMode = false;
    _hint = null;
    _hintsExhausted = false;
    _elapsed = Duration.zero;
    freeHints = 0;
    rewardedHints = 0;
    _saveSnapshot();
    notifyListeners();
  }

  /// Aplica ajustes nuevos (por ejemplo, cambiados desde la pausa).
  void applySettings(SudokuSettings next) {
    settings = next;
    _game.removeNotesOnPlace = next.removeNotesOnPlace;
    if (next.inputMode == SudokuInputMode.cellFirst) _activeDigit = null;
    notifyListeners();
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
    if (_paused || solved || _hint != null) return;
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
    freeHintsUsed: freeHints,
    rewardedHintsUsed: rewardedHints,
  );

  bool get _blocked => _paused || solved || _hint != null;

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
