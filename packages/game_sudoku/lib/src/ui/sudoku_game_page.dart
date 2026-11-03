import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../l10n/generated/sudoku_localizations.dart';
import '../controller.dart';
import 'board.dart';
import 'controls.dart';

/// Pantalla de partida de Sudoku. Sin anuncios.
///
/// Barra superior (atrás, nivel con % de avance, tiempo y pausa), grilla,
/// herramientas y teclado. Al resolver: ola de celebración (salvo con
/// "Reducir animaciones"), luego informa el resultado y llama a [onSolved].
class SudokuGamePage extends StatefulWidget {
  const SudokuGamePage({super.key, required this.controller, required this.levelLabel, this.onSolved, this.onExit});

  final SudokuController controller;

  /// Nombre traducido del nivel ("Medio").
  final String levelLabel;

  /// Después de la celebración; la app abre el Resultado (H4-05).
  final VoidCallback? onSolved;

  /// Botón atrás. Por defecto, cierra la ruta.
  final VoidCallback? onExit;

  @override
  State<SudokuGamePage> createState() => _SudokuGamePageState();
}

class _SudokuGamePageState extends State<SudokuGamePage> with SingleTickerProviderStateMixin {
  static const _tick = Duration(seconds: 1);

  late final AnimationController _celebration;
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  bool _celebrating = false;

  SudokuController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _celebration = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _c.addListener(_onChange);
    _startTimer();
    // Al salir de la app el tiempo se detiene y la partida queda guardada.
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
    _celebration.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _c.tick(_tick));
  }

  void _onChange() {
    if (_c.solved && !_celebrating) {
      _celebrating = true;
      _timer?.cancel();
      unawaited(_celebrate());
    }
    if (mounted) setState(() {});
  }

  Future<void> _celebrate() async {
    final l10n = SudokuLocalizations.of(context);
    final direction = Directionality.of(context);
    unawaited(LudixaHaptics.success(enabled: _c.settings.haptics));
    unawaited(SemanticsService.sendAnnouncement(View.of(context), l10n.solved, direction));
    if (!MediaQuery.disableAnimationsOf(context)) await _celebration.forward();
    await _c.reportSolved();
    widget.onSolved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;
    final gutter = compact ? 8.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          icon: const LudixaIcon(LudixaIcons.back),
          onPressed: widget.onExit ?? () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(l10n.topBarProgress(widget.levelLabel, _c.progressPercent)),
        actions: [
          if (_c.settings.showTimer)
            Semantics(
              label: l10n.elapsed(_format(_c.elapsed)),
              excludeSemantics: true,
              child: Text(
                _format(_c.elapsed),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          IconButton(
            tooltip: _c.paused ? l10n.resume : l10n.pause,
            icon: LudixaIcon(_c.paused ? LudixaIcons.play : LudixaIcons.pause),
            onPressed: _c.solved ? null : (_c.paused ? _c.resume : _c.pause),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 16),
          child: Column(
            children: [
              _c.paused
                  ? _PausedBoard(onResume: _c.resume, size: width - 2 * gutter, palette: p)
                  : SudokuBoard(controller: _c, maxCellExtent: 40, celebration: _celebrating ? _celebration : null),
              const SizedBox(height: 16),
              SudokuTools(controller: _c, freeHintsLeft: _c.host.freeHintsLeft),
              const SizedBox(height: 12),
              SudokuKeypad(controller: _c, keyHeight: compact ? 56 : 68),
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

/// El tablero queda oculto en pausa para que el tiempo detenido no sirva para
/// pensar. La pantalla de pausa completa llega en H4-05.
class _PausedBoard extends StatelessWidget {
  const _PausedBoard({required this.onResume, required this.size, required this.palette});

  final VoidCallback onResume;
  final double size;
  final LudixaPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final side = size.clamp(0.0, 360.0);
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(color: palette.surfaceMuted, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.pausedBoard, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          LudixaButton(label: l10n.resume, onPressed: onResume, expand: false),
        ],
      ),
    );
  }
}
