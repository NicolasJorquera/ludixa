import 'dart:async';
import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import '../../l10n/generated/words_localizations.dart';
import '../controller.dart';
import '../settings.dart';
import 'board.dart';

/// Pantalla de partida de Sopa de letras. Sin anuncios.
class WordSearchPage extends StatefulWidget {
  const WordSearchPage({super.key, required this.controller, this.onWon, this.onExit, this.onResume});

  final WordSearchController controller;
  final VoidCallback? onWon;
  final VoidCallback? onExit;

  /// Antes de reanudar tras la pausa: recarga los ajustes, que pudieron
  /// cambiar desde la pantalla de pausa.
  final VoidCallback? onResume;

  @override
  State<WordSearchPage> createState() => _WordSearchPageState();
}

class _WordSearchPageState extends State<WordSearchPage> {
  static const _tick = Duration(seconds: 1);

  /// Celda mínima cómoda (ficha UX); por debajo se ofrece zoom.
  static const _minCell = 28.0;

  final _zoom = GlobalKey<ZoomableBoardState>();
  late final GameLifecycle _lifecycle;
  Timer? _timer;
  bool _zoomed = false;
  bool _wonHandled = false;
  bool? _listOpen;

  /// Último aviso (palabra encontrada, pista o fin). Se muestra en la burbuja,
  /// que es una región en vivo: así lo lee TalkBack sin `announceForAccessibility`,
  /// obsoleto en Android (y que en Android 16 dejaba de recibir gestos).
  String? _status;

  WordSearchController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _startTimer();
    _lifecycle = GameLifecycle(
      onLeave: () {
        _timer?.cancel();
        unawaited(_c.host.saveSnapshot(_c.snapshot()));
      },
      onReturn: _startTimer,
      onAutoPause: _openPause,
    )..attach();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _timer?.cancel();
    _c.removeListener(_onChange);
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      final state = WidgetsBinding.instance.lifecycleState;
      if (state == null || state == AppLifecycleState.resumed) _c.tick(_tick);
    });
  }

  void _onChange() {
    // Al empezar otra selección, el aviso anterior deja lugar a las letras.
    if (_c.selection.length > 1 && !_c.complete) _status = null;
    if (_c.complete && !_wonHandled) {
      _wonHandled = true;
      unawaited(_finish());
    }
    if (mounted) setState(() {});
  }

  Future<void> _finish() async {
    final l10n = WordsLocalizations.of(context);
    unawaited(LudixaHaptics.success(enabled: _c.settings.haptics));
    setState(() => _status = l10n.announceAll);
    await _c.reportWon();
    widget.onWon?.call();
  }

  void _onResult(({SelectionOutcome outcome, int? wordIndex})? result) {
    if (result == null || result.outcome != SelectionOutcome.found) return;
    unawaited(LudixaHaptics.select(enabled: _c.settings.haptics));
    if (_c.complete) return;
    final word = _c.puzzle.placements[result.wordIndex!].display;
    setState(() => _status = WordsLocalizations.of(context).announceFound(word));
  }

  /// Pausa del host: el tablero queda oculto y el tiempo detenido.
  Future<void> _openPause() async {
    if (_c.paused || _c.complete) return;
    _c.pause();
    final choice = await _c.host.showPause();
    if (!mounted) return;
    switch (choice) {
      case PauseChoice.resume:
        widget.onResume?.call();
        _c.resume();
      case PauseChoice.restart:
        widget.onResume?.call();
        _c.restart();
        _c.resume();
      case PauseChoice.exit:
        // La partida quedó guardada al pausar.
        widget.onExit != null ? widget.onExit!() : await Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = WordsLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final media = MediaQuery.of(context);
    // Con TalkBack el arrastre no sirve: se usa tocar inicio y final.
    final tapMode = _c.settings.selection == SelectionMode.tap || media.accessibleNavigation;
    final gutter = LudixaLayout.gutter(context);
    final size = _c.size;
    final cellExtent = math.min(((media.size.width - 2 * gutter) / size).floorToDouble(), 48.0);
    final zoomable = cellExtent < _minCell;
    final boardSide = cellExtent * size;
    // Lista plegable en pantallas de menos de 700 dp de alto.
    final compact = media.size.height < 700;
    final listOpen = _listOpen ?? !compact;

    final board = WordSearchBoard(controller: _c, cellExtent: cellExtent, tapMode: tapMode, onResult: _onResult);
    final found = _c.game.foundOrder.length;
    final total = _c.puzzle.placements.length;

    final String bubble;
    if (_c.selectionText.length > 1) {
      bubble = _c.selectionText;
    } else if (_status != null) {
      bubble = _status!;
    } else if (tapMode) {
      bubble = _c.anchor == null ? l10n.tapModeStart : l10n.tapModeEnd;
    } else {
      bubble = '';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          icon: const LudixaIcon(LudixaIcons.back),
          onPressed: widget.onExit ?? () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(_c.themeNames.join(' · '), overflow: TextOverflow.ellipsis),
        actions: [
          if (_c.settings.showTimer)
            Semantics(
              label: l10n.elapsed(_format(_c.elapsed)),
              excludeSemantics: true,
              child: Text(
                _format(_c.elapsed),
                style: text.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          IconButton(
            tooltip: _c.paused ? l10n.resume : l10n.pause,
            icon: LudixaIcon(_c.paused ? LudixaIcons.play : LudixaIcons.pause),
            onPressed: _c.complete ? null : _openPause,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 12),
          child: Column(
            children: [
              // Burbuja con la palabra en curso (o la instrucción del modo toque).
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Center(
                          child: bubble.isEmpty
                              ? null
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _c.selectionText.length > 1 ? p.wordSearchSoft : null,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    bubble,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _c.selectionText.length > 1
                                        ? text.titleMedium?.copyWith(letterSpacing: 2)
                                        : text.bodyMedium,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (zoomable && !_c.paused)
                      IconButton(
                        tooltip: _zoomed ? l10n.zoomOut : l10n.zoomIn,
                        icon: Icon(_zoomed ? Icons.zoom_out_map : Icons.zoom_in),
                        onPressed: () {
                          _zoom.currentState?.toggleZoom();
                          setState(() => _zoomed = !_zoomed);
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _c.paused
                      ? Container(
                          width: boardSide,
                          height: boardSide,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.surface,
                            border: Border.all(color: p.line, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.pausedBoard, style: text.titleMedium),
                              const SizedBox(height: 16),
                              LudixaButton(label: l10n.resume, onPressed: _c.resume, expand: false),
                            ],
                          ),
                        )
                      : zoomable
                      ? SizedBox(
                          width: boardSide,
                          height: boardSide,
                          child: ClipRect(
                            // El arrastre sirve para seleccionar: el tablero se
                            // mueve con dos dedos.
                            child: ZoomableBoard(
                              key: _zoom,
                              boardSize: Size.square(boardSide),
                              cellExtent: cellExtent,
                              comfortableCellExtent: 36,
                              panEnabled: false,
                              child: board,
                            ),
                          ),
                        )
                      : board,
                ),
              ),
              const SizedBox(height: 8),
              // Lista de palabras con su ortografía real, contador y pista.
              Row(
                children: [
                  // Con texto grande, "Mostrar lista" baja a otra línea.
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Semantics(
                          label: l10n.wordsCountLabel(found, total),
                          excludeSemantics: true,
                          child: Text(l10n.wordsCount(found, total), style: text.titleMedium),
                        ),
                        if (compact)
                          TextButton(
                            onPressed: () => setState(() => _listOpen = !listOpen),
                            child: Text(listOpen ? l10n.wordsHide : l10n.wordsShow),
                          ),
                      ],
                    ),
                  ),
                  Semantics(
                    value: _c.hintsExhausted ? l10n.noMoreHints : l10n.hintsLeft(_c.host.freeHintsLeft),
                    child: IconButton(
                      tooltip: _c.hintsExhausted ? l10n.noMoreHints : l10n.hint,
                      onPressed: _c.paused || _c.complete || _c.hintsExhausted || _c.hintCell != null
                          ? null
                          : _requestHint,
                      icon: Badge(
                        isLabelVisible: !_c.hintsExhausted,
                        label: Text('${_c.host.freeHintsLeft}'),
                        backgroundColor: p.wordSearch,
                        textColor: p.onPrimary,
                        child: const LudixaIcon(LudixaIcons.hint),
                      ),
                    ),
                  ),
                ],
              ),
              if (listOpen)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final (i, word) in _c.puzzle.placements.indexed)
                      Semantics(
                        label: _c.game.isFound(i) ? l10n.wordFound(word.display) : l10n.wordPending(word.display),
                        excludeSemantics: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _c.game.isFound(i) ? p.wordSearchSoft : p.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.line),
                          ),
                          child: Text(
                            word.display,
                            style: text.labelLarge?.copyWith(
                              decoration: _c.game.isFound(i) ? TextDecoration.lineThrough : null,
                              color: _c.game.isFound(i) ? p.inkMuted : p.ink,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestHint() async {
    await _c.requestHint();
    final cell = _c.hintCell;
    if (cell == null || !mounted) return;
    final l10n = WordsLocalizations.of(context);
    setState(() => _status = l10n.hintAnnounce(cell ~/ _c.size + 1, cell % _c.size + 1));
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (minutes < 60) return '$minutes:$seconds';
    return '${d.inHours}:${(minutes % 60).toString().padLeft(2, '0')}:$seconds';
  }
}
