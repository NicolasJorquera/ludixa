import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:game_api/game_api.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';

import 'settings.dart';

/// Qué pasó con una jugada, para la vibración y los anuncios.
enum MinesweeperEvent { none, flagged, revealed, won, lost }

/// Estado de una partida de Buscaminas en la interfaz: envuelve
/// [MinesweeperGame] y agrega el modo de toque, la generación tras el primer
/// toque, el tiempo, la pista, el rescate y la comunicación con el host.
class MinesweeperController extends ChangeNotifier {
  MinesweeperController({
    required MinesweeperGame game,
    required this.host,
    required this.store,
    Duration elapsed = Duration.zero,
    this.freeHints = 0,
    this.rewardedHints = 0,
    int? start,
    this.generate = _generateInIsolate,
  }) : _game = game,
       _elapsed = elapsed,
       _start = start ?? game.suggestedStart,
       settings = store.load() {
    _mode = settings.tapAction;
  }

  static const int snapshotVersion = 1;

  factory MinesweeperController.resume(
    SessionSnapshot snapshot, {
    required GameHost host,
    required MinesweeperSettingsStore store,
  }) {
    final state = snapshot.state;
    if (state['v'] != snapshotVersion) throw FormatException('Instantánea desconocida', state['v']);
    return MinesweeperController(
      game: MinesweeperGame.fromJson((state['game']! as Map).cast<String, Object?>()),
      host: host,
      store: store,
      elapsed: snapshot.elapsed,
      freeHints: state['freeHints'] as int? ?? 0,
      rewardedHints: state['rewardedHints'] as int? ?? 0,
      start: state['start'] as int?,
    );
  }

  /// Genera el tablero de la partida libre tras el primer toque. Las pruebas
  /// pasan una versión síncrona.
  final Future<MineLayout> Function(BoardSpec spec, String seedKey, int start) generate;

  static Future<MineLayout> _generateInIsolate(BoardSpec spec, String seedKey, int start) =>
      Isolate.run(() => MinesweeperGame.generateBoard(spec, seedKey, start));

  final GameHost host;
  final MinesweeperSettingsStore store;
  MinesweeperSettings settings;

  MinesweeperGame _game;
  MinesweeperGame get game => _game;

  late TapAction _mode;
  int? _start;
  bool _generating = false;
  bool _paused = false;
  bool _hintsExhausted = false;
  bool _rescueUnavailable = false;
  bool _reported = false;
  MinesweeperHint? _hint;
  Duration _elapsed;
  int freeHints;
  int rewardedHints;

  /// Lo que hace un toque ahora (la pulsación larga hace lo contrario).
  TapAction get mode => _mode;
  bool get generating => _generating;
  bool get paused => _paused;
  bool get hintsExhausted => _hintsExhausted;
  bool get rescueUnavailable => _rescueUnavailable;
  MinesweeperHint? get hint => _hint;
  Duration get elapsed => _elapsed;
  bool get won => _game.status == GameStatus.won;
  bool get lost => _game.status == GameStatus.lost;
  bool get waitingFirstTap => _game.status == GameStatus.ready;

  void toggleMode() {
    _mode = _mode == TapAction.reveal ? TapAction.flag : TapAction.reveal;
    notifyListeners();
  }

  /// Toque: ejecuta el modo activo.
  Future<MinesweeperEvent> tapCell(int cell) => _act(cell, _mode);

  /// Pulsación larga: lo contrario del modo activo.
  Future<MinesweeperEvent> longPressCell(int cell) {
    if (!settings.longPressTipDone) {
      settings = settings.copyWith(longPressTipDone: true);
      unawaited(store.save(settings));
    }
    return _act(cell, _mode == TapAction.reveal ? TapAction.flag : TapAction.reveal);
  }

  Future<MinesweeperEvent> _act(int cell, TapAction action) async {
    if (_paused || _generating || _game.isOver || _hint != null) return MinesweeperEvent.none;
    if (_game.needsBoard) {
      // El primer toque siempre revela y abre una zona: ahí se genera el tablero.
      _generating = true;
      notifyListeners();
      final layout = await generate(_game.spec, _game.seed.key, cell);
      _generating = false;
      _game.begin(layout);
      _start = cell;
      return _after(_game.reveal(cell), revealed: true);
    }
    if (action == TapAction.flag) {
      return _after(_game.toggleFlag(cell), revealed: false);
    }
    if (_game.viewAt(cell) == CellView.revealed) {
      if (!settings.chord) return MinesweeperEvent.none;
      return _after(_game.chord(cell), revealed: true);
    }
    if (_game.viewAt(cell) == CellView.flagged) return MinesweeperEvent.none;
    return _after(_game.reveal(cell), revealed: true);
  }

  MinesweeperEvent _after(MoveOutcome outcome, {required bool revealed}) {
    if (outcome == MoveOutcome.ignored) {
      notifyListeners();
      return MinesweeperEvent.none;
    }
    _saveSnapshot();
    notifyListeners();
    return switch (outcome) {
      MoveOutcome.won => MinesweeperEvent.won,
      MoveOutcome.lost => MinesweeperEvent.lost,
      _ => revealed ? MinesweeperEvent.revealed : MinesweeperEvent.flagged,
    };
  }

  void undo() {
    if (_paused || _hint != null) return;
    if (_game.undo()) {
      _saveSnapshot();
      notifyListeners();
    }
  }

  /// Pide una pista: señala una celda deducible y explica por qué. Un crédito.
  Future<void> requestHint() async {
    if (_paused || _hintsExhausted || _hint != null || _game.status != GameStatus.playing) return;
    final hint = _game.hint();
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
        _hint = hint;
        _saveSnapshot();
    }
    notifyListeners();
  }

  /// Aplica la pista (revelar, poner o quitar la bandera) y la cierra.
  MinesweeperEvent applyHint() {
    final hint = _hint;
    if (hint == null) return MinesweeperEvent.none;
    _hint = null;
    if (hint.reason == HintReason.wrongFlag || hint.isMine) {
      return _after(_game.toggleFlag(hint.cell), revealed: false);
    }
    return _after(_game.reveal(hint.cell), revealed: true);
  }

  void closeHint() {
    _hint = null;
    notifyListeners();
  }

  /// Rescate con video: deshace el toque fatal. Una vez por partida y solo si
  /// el jugador lo pide.
  Future<bool> rescue() async {
    if (!_game.canRescue) return false;
    final outcome = await host.requestRescue();
    if (outcome == RescueOutcome.unavailable) {
      _rescueUnavailable = true;
      notifyListeners();
      return false;
    }
    if (outcome != RescueOutcome.granted || !_game.rescue()) return false;
    _saveSnapshot();
    notifyListeners();
    return true;
  }

  /// "Reintentar este tablero": mismas minas desde cero. Cuenta como derrota
  /// de la partida anterior.
  Future<void> retrySameBoard() async {
    final start = _start;
    if (start == null) return;
    await reportFinished();
    _game = _game.replay(start: start);
    _elapsed = Duration.zero;
    _reported = false;
    freeHints = 0;
    rewardedHints = 0;
    _hintsExhausted = false;
    _rescueUnavailable = false;
    _mode = settings.tapAction;
    _saveSnapshot();
    notifyListeners();
  }

  /// Empieza el mismo tablero de cero ("Reiniciar" en la pausa). Sin tablero
  /// todavía (antes del primer toque) solo reinicia el tiempo.
  void restart() {
    final start = _start;
    if (!_game.needsBoard && start != null) _game = _game.replay(start: start);
    _elapsed = Duration.zero;
    _hint = null;
    _hintsExhausted = false;
    _rescueUnavailable = false;
    freeHints = 0;
    rewardedHints = 0;
    _mode = settings.tapAction;
    _saveSnapshot();
    notifyListeners();
  }

  /// Relee los ajustes guardados (por ejemplo, cambiados desde la pausa).
  void reloadSettings() {
    settings = store.load();
    notifyListeners();
  }

  void pause() {
    if (_paused || _game.isOver) return;
    _paused = true;
    _saveSnapshot();
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    notifyListeners();
  }

  /// El tiempo corre desde el primer toque, sin pausa ni pista abierta.
  void tick(Duration delta) {
    if (_paused || _hint != null || _game.status != GameStatus.playing) return;
    _elapsed += delta;
    notifyListeners();
  }

  /// Informa el resultado una sola vez: al ganar, o al salir de la derrota
  /// (reintentar, tablero nuevo o volver), porque antes se puede rescatar.
  Future<void> reportFinished() async {
    if (_reported || !_game.isOver) return;
    _reported = true;
    await host.reportResult(
      GameResult(
        outcome: won ? GameOutcome.won : GameOutcome.lost,
        elapsed: _elapsed,
        freeHintsUsed: freeHints,
        rewardedHintsUsed: rewardedHints,
        rescued: _game.rescueUsed,
      ),
    );
  }

  SessionSnapshot snapshot() => SessionSnapshot(
    state: {
      'v': snapshotVersion,
      'game': _game.toJson(),
      'start': _start,
      'freeHints': freeHints,
      'rewardedHints': rewardedHints,
    },
    elapsed: _elapsed,
    freeHintsUsed: freeHints,
    rewardedHintsUsed: rewardedHints,
  );

  void _saveSnapshot() => unawaited(host.saveSnapshot(snapshot()));
}
