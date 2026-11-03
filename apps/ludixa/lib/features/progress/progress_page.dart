import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../app/router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../daily/challenge_rows.dart';
import '../play/play_providers.dart';
import 'progress_data.dart';

/// Pestaña Progreso: Estadísticas (4 totales y una tabla por nivel de cada
/// juego) y Logros (los 18, con su avance). Sin datos lleva al reto de hoy.
/// El banner llega con la monetización (H5).
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.progressTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.progressTabStats),
              Tab(text: l10n.progressTabAchievements),
            ],
          ),
        ),
        body: const TabBarView(children: [_StatsTab(), _AchievementsTab()]),
      ),
    );
  }
}

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab();

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  GameId _game = GameId.sudoku;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = ref.watch(progressTotalsProvider).value;
    if (totals == null) return const SizedBox.shrink();
    if (totals.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: LudixaEmptyState(
            icon: LudixaIcons.progress,
            title: l10n.progressEmptyTitle,
            message: l10n.progressEmpty,
            action: LudixaButton(label: l10n.progressEmptyAction, onPressed: () => context.go(AppRoutes.daily)),
          ),
        ),
      );
    }
    final modules = ref.watch(gameModulesProvider);
    final module = modules[_game]!;
    final levels = ref.watch(levelStatsProvider(_game)).value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Totals(totals: totals),
        const SizedBox(height: 24),
        Semantics(
          label: l10n.progressGame,
          container: true,
          child: LudixaSegmentedControl<GameId>(
            segments: [for (final m in modules.values) LudixaSegment(value: m.id, label: m.displayName(context))],
            selected: _game,
            onChanged: (game) => setState(() => _game = game),
            accent: _accent(context, _game),
          ),
        ),
        const SizedBox(height: 16),
        if (levels != null) _LevelTable(module: module, levels: levels),
        const SizedBox(height: 8),
        Text(
          l10n.progressTableHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.palette.inkMuted),
        ),
      ],
    );
  }
}

Color _accent(BuildContext context, GameId game) {
  final p = context.palette;
  return switch (game) {
    GameId.sudoku => p.sudoku,
    GameId.minesweeper => p.minesweeper,
    _ => p.wordSearch,
  };
}

/// Los 4 totales en una grilla de 2 × 2.
class _Totals extends StatelessWidget {
  const _Totals({required this.totals});

  final ProgressTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = [
      _Total(label: l10n.progressCompleted, value: '${totals.completed}'),
      _Total(label: l10n.progressTotalTime, value: formatDuration(totals.totalTime)),
      _Total(
        label: l10n.progressStreak,
        value: '${totals.currentStreak}',
        detail: l10n.progressStreakBest(totals.bestStreak),
      ),
      _Total(label: l10n.progressPerfectDays, value: '${totals.perfectDays}'),
    ];
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[row * 2]),
                const SizedBox(width: 12),
                Expanded(child: tiles[row * 2 + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    return Semantics(
      container: true,
      label: [label, value, ?detail].join('. '),
      excludeSemantics: true,
      child: LudixaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: text.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: text.bodySmall?.copyWith(color: p.inkMuted)),
            if (detail != null) Text(detail!, style: text.bodySmall?.copyWith(color: p.inkMuted)),
          ],
        ),
      ),
    );
  }
}

/// Tabla por nivel. El widget [Table] declara el rol de tabla y sus celdas,
/// y los encabezados se marcan como tales (lo aprovechan la web y VoiceOver).
/// Mantener pulsada una fila jugada ofrece reiniciar ese nivel.
class _LevelTable extends ConsumerWidget {
  const _LevelTable({required this.module, required this.levels});

  final GameModule module;
  final Map<Difficulty, DifficultyStats> levels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final percent = NumberFormat.percentPattern(Localizations.localeOf(context).toLanguageTag());
    final selectable = [for (final o in module.difficulties(context)) o.id];
    final order = [
      ...selectable,
      for (final level in levels.keys)
        if (!selectable.contains(level)) level,
    ];
    final showRate = module.id == GameId.minesweeper;

    Widget header(String label, {bool start = false}) => Semantics(
      role: SemanticsRole.columnHeader,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(
          label,
          style: text.labelLarge?.copyWith(color: p.inkMuted),
          textAlign: start ? TextAlign.start : TextAlign.end,
        ),
      ),
    );

    TableRow row(Difficulty level) {
      final stats = levels[level];
      final played = stats != null && stats.started > 0;
      final name = module.difficultyLabel(context, level);
      Widget cell(Widget child, {bool start = false}) {
        final padded = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Align(
            alignment: start ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
            child: child,
          ),
        );
        if (!played) return padded;
        return Semantics(
          onLongPressHint: l10n.progressResetLevel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => _confirmReset(context, ref, level, name),
            child: padded,
          ),
        );
      }

      // En Android, TalkBack no recibe el rol de tabla de Flutter: cada dato
      // lleva su encabezado ("Partidas: 2") para leerse bien celda a celda.
      Widget value(String header, String shown, {String? spoken}) => Semantics(
        label: '$header: ${spoken ?? shown}',
        excludeSemantics: true,
        child: Text(shown, style: text.bodyMedium),
      );

      Widget time(String header, Duration? d) =>
          d == null ? value(header, '—', spoken: l10n.progressNoTime) : value(header, formatDuration(d));

      return TableRow(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        children: [
          cell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.bodyLarge),
                if (!played) Text(l10n.progressNotPlayed, style: text.bodySmall?.copyWith(color: p.inkMuted)),
              ],
            ),
            start: true,
          ),
          cell(value(l10n.progressColPlayed, '${stats?.started ?? 0}')),
          cell(
            value(
              l10n.progressColWon,
              showRate && stats?.winRate != null
                  ? l10n.progressWonRate(stats!.won, percent.format(stats.winRate))
                  : '${stats?.won ?? 0}',
            ),
          ),
          cell(time(l10n.progressColBest, stats?.bestTime)),
          cell(time(l10n.progressColMean, stats?.meanTime)),
        ],
      );
    }

    return LudixaCard(
      padding: EdgeInsets.zero,
      child: Table(
        // El nivel toma el espacio que sobra, sin partir palabras.
        columnWidths: const {0: IntrinsicColumnWidth(flex: 1)},
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(color: p.surfaceMuted),
            children: [
              header(l10n.progressColLevel, start: true),
              header(l10n.progressColPlayed),
              header(l10n.progressColWon),
              header(l10n.progressColBest),
              header(l10n.progressColMean),
            ],
          ),
          for (final level in order) row(level),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref, Difficulty level, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => LudixaSheet(
        title: l10n.progressResetTitle(module.displayName(context), name),
        body: Text(l10n.progressResetBody, style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          LudixaButton(
            label: l10n.progressResetConfirm,
            onPressed: () => Navigator.pop(context, true),
            variant: LudixaButtonVariant.secondary,
          ),
          LudixaButton(
            label: l10n.pauseCancel,
            onPressed: () => Navigator.pop(context, false),
            variant: LudixaButtonVariant.tertiary,
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(progressServiceProvider).resetStats(module.id, difficulty: level);
    ref.read(progressRevisionProvider.notifier).bump();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.progressResetDone(name))));
  }
}

class _AchievementsTab extends ConsumerWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final achievements = ref.watch(achievementsProvider).value;
    if (achievements == null) return const SizedBox.shrink();
    final unlocked = achievements.where((a) => a.unlockedAt != null).length;
    final columns = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;
    final rows = <List<AchievementState>>[
      for (var i = 0; i < achievements.length; i += columns)
        achievements.sublist(i, (i + columns).clamp(0, achievements.length)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(l10n.achievementsCount(unlocked, achievements.length), style: Theme.of(context).textTheme.titleMedium),
        for (final row in rows) ...[
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: i < row.length ? _AchievementTile(state: row[i]) : const SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado de un logro en palabras: desbloqueado, su avance o pendiente.
String _status(AppLocalizations l10n, AchievementState a) {
  if (a.unlockedAt != null) return l10n.achievementUnlocked;
  if (a.id.target > 1) return l10n.achievementProgress(a.progress, a.id.target);
  return l10n.achievementLocked;
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.state});

  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final done = state.unlockedAt != null;
    final title = l10n.achievementTitle(state.id.key);
    final status = _status(l10n, state);
    return LudixaCard(
      semanticLabel: '$title. $status',
      color: done ? p.primarySoft : null,
      onTap: () => _showAchievement(context, state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LudixaIcon(LudixaIcons.trophy, color: done ? p.primary : p.inkMuted),
          const SizedBox(height: 8),
          Text(title, style: text.titleSmall),
          const Spacer(),
          const SizedBox(height: 8),
          if (!done && state.id.target > 1) ...[
            LudixaProgressBar(value: state.progress / state.id.target, semanticLabel: title),
            const SizedBox(height: 4),
          ],
          Text(status, style: text.bodySmall?.copyWith(color: done ? p.ink : p.inkMuted)),
        ],
      ),
    );
  }
}

Future<void> _showAchievement(BuildContext context, AchievementState state) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final p = context.palette;
  final unlockedAt = state.unlockedAt;
  final title = l10n.achievementTitle(state.id.key);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final text = Theme.of(context).textTheme;
      return LudixaSheet(
        leading: LudixaIcon(LudixaIcons.trophy, size: 32, color: unlockedAt != null ? p.primary : p.inkMuted),
        title: title,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.achievementDescription(state.id.key), style: text.bodyLarge),
            const SizedBox(height: 16),
            if (unlockedAt != null)
              Text(
                l10n.achievementUnlockedOn(DateFormat.yMMMMd(locale).format(unlockedAt.toLocal())),
                style: text.bodyMedium,
              )
            else ...[
              if (state.id.target > 1) ...[
                LudixaProgressBar(value: state.progress / state.id.target, semanticLabel: title),
                const SizedBox(height: 8),
              ],
              Text(_status(l10n, state), style: text.bodyMedium?.copyWith(color: p.inkMuted)),
            ],
          ],
        ),
      );
    },
  );
}
