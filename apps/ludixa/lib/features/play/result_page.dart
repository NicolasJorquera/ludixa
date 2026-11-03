import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_game_host.dart';

/// Resultado de una partida ganada: sello, métricas, maestría (o el bloque
/// del reto diario), logros nuevos y siguiente acción. El banner llega con la
/// monetización (H5).
class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.module,
    required this.finished,
    required this.levelLabel,
    required this.onHome,
    this.onPlayAgain,
    this.onNextDaily,
  });

  final GameModule module;
  final FinishedGame finished;
  final String levelLabel;
  final VoidCallback onHome;

  /// Partida libre: otra del mismo nivel.
  final VoidCallback? onPlayAgain;

  /// Reto diario con retos pendientes: el siguiente.
  final VoidCallback? onNextDaily;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final f = widget.finished;
    final s = f.session;
    final daily = s.mode == PuzzleMode.daily;
    final color = switch (s.game) {
      GameId.sudoku => p.sudoku,
      GameId.minesweeper => p.minesweeper,
      _ => p.wordSearch,
    };
    final mastery = Mastery.forWins(f.winsAtLevel);
    final toNext = Mastery.toNext(f.winsAtLevel);
    final nextLevel = toNext == null ? null : Mastery.values[mastery.index + 1];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: IconTheme(
                  data: IconThemeData(color: p.onPrimary, size: 44),
                  child: widget.module.buildIcon(context, size: 44),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Región en vivo: el título se lee al entrar.
            Semantics(
              liveRegion: true,
              header: true,
              child: Text(l10n.resultSolved, style: text.headlineMedium, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.module.displayName(context)} · ${widget.levelLabel}',
              style: text.bodyLarge?.copyWith(color: p.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (!s.assisted) LudixaBadge(label: l10n.resultUnassisted),
                if (f.isNewRecord) LudixaBadge(label: l10n.resultNewRecord, icon: LudixaIcons.trophy),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Metric(label: l10n.resultTime, value: _format(s.elapsed)),
                _Metric(
                  label: l10n.resultBest,
                  value: f.bestAfter == null ? '—' : _format(f.bestAfter!),
                  highlight: f.isNewRecord,
                ),
                _Metric(label: l10n.resultHints, value: '${s.hintsUsed}'),
              ],
            ),
            const SizedBox(height: 16),
            LudixaCard(
              child: daily
                  ? Text(l10n.resultDaily(f.dailyDone, f.streakBefore, f.streakAfter), style: text.titleMedium)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.resultMastery(widget.levelLabel), style: text.titleSmall),
                        const SizedBox(height: 4),
                        Text(l10n.masteryLevel(mastery.name), style: text.titleMedium),
                        const SizedBox(height: 8),
                        LudixaProgressBar(
                          value: nextLevel == null ? 1 : f.winsAtLevel / nextLevel.wins,
                          semanticLabel: nextLevel == null
                              ? l10n.masteryComplete
                              : l10n.masteryToNext(toNext!, l10n.masteryLevel(nextLevel.name)),
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextLevel == null
                              ? l10n.masteryComplete
                              : l10n.masteryToNext(toNext!, l10n.masteryLevel(nextLevel.name)),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
            ),
            for (final id in f.outcome.newAchievements) ...[
              const SizedBox(height: 12),
              LudixaCard(
                child: Row(
                  children: [
                    LudixaIcon(LudixaIcons.trophy, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.resultAchievement, style: text.labelMedium),
                          Text(l10n.achievementTitle(id.key), style: text.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (daily && widget.onNextDaily != null)
              LudixaButton(label: l10n.resultNextDaily, onPressed: widget.onNextDaily)
            else if (!daily && widget.onPlayAgain != null)
              LudixaButton(label: l10n.resultPlayAgain(widget.levelLabel), onPressed: widget.onPlayAgain),
            const SizedBox(height: 8),
            LudixaButton(label: l10n.resultHome, onPressed: widget.onHome, variant: LudixaButtonVariant.secondary),
          ],
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    return Expanded(
      child: Semantics(
        container: true,
        label: '$label $value',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(value, style: text.titleLarge?.copyWith(color: highlight ? p.success : null)),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
