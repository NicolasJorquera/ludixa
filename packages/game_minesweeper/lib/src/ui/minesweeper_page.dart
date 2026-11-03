import 'dart:async';
import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';

import '../../l10n/generated/mines_localizations.dart';
import '../controller.dart';
import '../settings.dart';
import 'board.dart';

/// Pantalla de partida de Buscaminas. Sin anuncios, salvo el video de
/// rescate opcional que el jugador pide tras perder.
class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({
    super.key,
    required this.controller,
    required this.levelLabel,
    this.onWon,
    this.onNewBoard,
    this.onExit,
  });

  final MinesweeperController controller;
  final String levelLabel;

  /// Al ganar, después de informar el resultado (la app abre el Resultado).
  final VoidCallback? onWon;

  /// "Tablero nuevo" tras perder.
  final VoidCallback? onNewBoard;
  final VoidCallback? onExit;

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  static const _tick = Duration(seconds: 1);
  static const _comfortable = 36.0;

  final _zoom = GlobalKey<ZoomableBoardState>();
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  bool _defeatCollapsed = false;
  bool _wonHandled = false;
  bool _zoomed = false;

  MinesweeperController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _startTimer();
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _timer?.cancel();
        unawaited(_c.host.saveSnapshot(_c.snapshot()));
      },
      onShow: _startTimer,
    );
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
    // Solo cuenta con la app al frente (en Android el temporizador puede
    // seguir disparando de fondo).
    _timer = Timer.periodic(_tick, (_) {
      final state = WidgetsBinding.instance.lifecycleState;
      if (state == null || state == AppLifecycleState.resumed) _c.tick(_tick);
    });
  }

  void _onChange() {
    if (_c.won && !_wonHandled) {
      _wonHandled = true;
      unawaited(_finishWon());
    }
    if (!_c.lost) _defeatCollapsed = false;
    if (mounted) setState(() {});
  }

  Future<void> _finishWon() async {
    final l10n = MinesLocalizations.of(context);
    unawaited(LudixaHaptics.success(enabled: _c.settings.haptics));
    unawaited(SemanticsService.sendAnnouncement(View.of(context), l10n.won, Directionality.of(context)));
    await _c.reportFinished();
    widget.onWon?.call();
  }

  Future<void> _handle(Future<MinesweeperEvent> move) async {
    final event = await move;
    if (!mounted) return;
    switch (event) {
      case MinesweeperEvent.flagged:
        unawaited(LudixaHaptics.flag(enabled: _c.settings.haptics));
      case MinesweeperEvent.lost:
        final l10n = MinesLocalizations.of(context);
        final fatal = _c.game.fatal!;
        final width = _c.game.spec.width;
        unawaited(
          SemanticsService.sendAnnouncement(
            View.of(context),
            '${l10n.lostTitle}. ${l10n.lostWhere(fatal ~/ width + 1, fatal % width + 1)}',
            Directionality.of(context),
          ),
        );
      case _:
        break;
    }
  }

  Future<void> _leaveDefeat(VoidCallback? then) async {
    await _c.reportFinished();
    then?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final spec = _c.game.spec;
    final width = MediaQuery.sizeOf(context).width;
    const gutter = 16.0;
    final available = width - 2 * gutter;
    final fit = ((available - minesweeperGap * (spec.width - 1)) / spec.width).floorToDouble();
    final cellExtent = math.min(fit, 44.0);
    final zoomable = cellExtent < _comfortable;
    final boardSize = Size(
      cellExtent * spec.width + minesweeperGap * (spec.width - 1),
      cellExtent * spec.height + minesweeperGap * (spec.height - 1),
    );

    final board = MinesweeperBoard(
      controller: _c,
      cellExtent: cellExtent,
      onTap: (i) => _handle(_c.tapCell(i)),
      onLongPress: (i) => _handle(_c.longPressCell(i)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          icon: const LudixaIcon(LudixaIcons.back),
          onPressed: () async {
            if (_c.game.isOver) await _c.reportFinished();
            if (!context.mounted) return;
            widget.onExit != null ? widget.onExit!() : Navigator.maybePop(context);
          },
        ),
        centerTitle: true,
        title: Text(widget.levelLabel),
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
            onPressed: _c.game.isOver ? null : (_c.paused ? _c.resume : _c.pause),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(gutter, 4, gutter, 12),
          child: Column(
            children: [
              // Minas restantes y zoom.
              Row(
                children: [
                  Semantics(
                    label: l10n.minesLeft(_c.game.minesRemaining),
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        LudixaIcon(LudixaIcons.mine, color: p.minesweeper),
                        const SizedBox(width: 6),
                        Text('${_c.game.minesRemaining}', style: text.titleLarge),
                      ],
                    ),
                  ),
                  const Spacer(),
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
              _StatusLine(controller: _c),
              const SizedBox(height: 4),
              Expanded(
                child: _c.paused
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: p.surface,
                          border: Border.all(color: p.line, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
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
                    ? ClipRect(
                        child: ZoomableBoard(
                          key: _zoom,
                          boardSize: boardSize,
                          cellExtent: cellExtent,
                          comfortableCellExtent: _comfortable,
                          child: board,
                        ),
                      )
                    : Align(alignment: Alignment.topCenter, child: board),
              ),
              const SizedBox(height: 8),
              if (_c.lost)
                _DefeatPanel(
                  controller: _c,
                  collapsed: _defeatCollapsed,
                  onToggle: () => setState(() => _defeatCollapsed = !_defeatCollapsed),
                  onRetry: () => _c.retrySameBoard(),
                  onNewBoard: () => _leaveDefeat(widget.onNewBoard),
                )
              else if (_c.hint != null)
                _HintPanel(controller: _c, onApply: () => _handle(Future.value(_c.applyHint())))
              else
                _Controls(controller: _c),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (minutes < 60) return '$minutes:$seconds';
    return '${d.inHours}:${(minutes % 60).toString().padLeft(2, '0')}:$seconds';
  }
}

/// Mensaje sobre el tablero: antes del primer toque, generando o la ayuda de
/// la pulsación larga de las primeras partidas.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.controller});

  final MinesweeperController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final c = controller;
    final style = Theme.of(context).textTheme.bodyMedium;
    final String? message;
    if (c.generating) {
      message = l10n.generating;
    } else if (c.waitingFirstTap) {
      message = l10n.tapToStart;
    } else if (c.game.suggestedStart != null &&
        c.game.status == GameStatus.playing &&
        [for (var i = 0; i < c.game.spec.cellCount; i++) c.game.viewAt(i)].every((v) => v == CellView.hidden)) {
      message = l10n.startHere;
    } else if (!c.settings.longPressTipDone && !c.game.isOver) {
      message = l10n.longPressTip(c.mode == TapAction.reveal ? l10n.longPressTipFlag : l10n.longPressTipReveal);
    } else {
      message = null;
    }
    return SizedBox(
      height: 28,
      child: message == null
          ? null
          : Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  if (c.generating)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  Expanded(
                    child: Text(message, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Revelar / Bandera, Deshacer y Pista.
class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final MinesweeperController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final c = controller;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final active = !c.paused && !c.game.isOver && !c.generating;
    final free = c.host.freeHintsLeft;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: LudixaSegmentedControl<TapAction>(
            segments: [
              LudixaSegment(value: TapAction.reveal, label: l10n.modeReveal, icon: LudixaIcons.reveal),
              LudixaSegment(value: TapAction.flag, label: l10n.modeFlag, icon: LudixaIcons.flag),
            ],
            selected: c.mode,
            onChanged: (v) {
              if (v != c.mode) c.toggleMode();
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: l10n.undo,
          onPressed: active && c.game.canUndo ? c.undo : null,
          icon: const LudixaIcon(LudixaIcons.undo),
        ),
        Semantics(
          value: c.hintsExhausted ? l10n.noMoreHints : l10n.hintsLeft(free),
          child: IconButton(
            tooltip: c.hintsExhausted ? l10n.noMoreHints : l10n.hint,
            onPressed: active && !c.hintsExhausted && !c.game.needsBoard ? c.requestHint : null,
            icon: Badge(
              isLabelVisible: !c.hintsExhausted,
              label: Text('$free'),
              backgroundColor: p.minesweeper,
              textColor: p.onPrimary,
              child: const LudixaIcon(LudixaIcons.hint),
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _HintPanel extends StatelessWidget {
  const _HintPanel({required this.controller, required this.onApply});

  final MinesweeperController controller;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final hint = controller.hint!;
    final wrongFlag = hint.reason == HintReason.wrongFlag;
    return _Panel(
      children: [
        Text(l10n.hintTitle, style: text.labelLarge),
        const SizedBox(height: 8),
        Text(
          wrongFlag
              ? l10n.hintWrongFlag
              : hint.isMine
              ? l10n.hintMine
              : l10n.hintSafe,
          style: text.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.hintReason(hint.reason.name), style: text.bodyMedium?.copyWith(color: p.inkMuted)),
        const SizedBox(height: 16),
        LudixaButton(
          label: wrongFlag
              ? l10n.hintApplyUnflag
              : hint.isMine
              ? l10n.hintApplyFlag
              : l10n.hintApplyReveal,
          onPressed: onApply,
          variant: LudixaButtonVariant.secondary,
        ),
        const SizedBox(height: 8),
        LudixaButton(label: l10n.hintTryMyself, onPressed: controller.closeHint),
      ],
    );
  }
}

/// Derrota: mensaje neutro, el tablero completo sigue a la vista y la hoja se
/// puede bajar para revisarlo. El video es opcional y una vez por partida.
class _DefeatPanel extends StatelessWidget {
  const _DefeatPanel({
    required this.controller,
    required this.collapsed,
    required this.onToggle,
    required this.onRetry,
    required this.onNewBoard,
  });

  final MinesweeperController controller;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onRetry;
  final VoidCallback onNewBoard;

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final c = controller;
    final fatal = c.game.fatal ?? 0;
    final width = c.game.spec.width;
    if (collapsed) {
      return LudixaButton(label: l10n.showOptions, onPressed: onToggle, variant: LudixaButtonVariant.secondary);
    }
    return _Panel(
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.lostTitle, style: text.titleMedium)),
            TextButton(onPressed: onToggle, child: Text(l10n.showBoard)),
          ],
        ),
        Text(
          l10n.lostWhere(fatal ~/ width + 1, fatal % width + 1),
          style: text.bodyMedium?.copyWith(color: p.inkMuted),
        ),
        const SizedBox(height: 16),
        LudixaButton(label: l10n.retryBoard, onPressed: onRetry),
        const SizedBox(height: 8),
        LudixaButton(label: l10n.newBoard, onPressed: onNewBoard, variant: LudixaButtonVariant.secondary),
        if (c.game.canRescue) ...[
          const SizedBox(height: 8),
          if (c.rescueUnavailable)
            Text(l10n.rescueUnavailable, style: text.bodySmall)
          else ...[
            LudixaButton(label: l10n.rescue, onPressed: c.rescue, variant: LudixaButtonVariant.rewarded),
            Text(l10n.rescueRule, style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ],
      ],
    );
  }
}
