import 'dart:math' as math;

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
import '../ads/ad_banner.dart';
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
            // Con texto grande, las pestañas se desplazan en vez de cortarse.
            isScrollable: LudixaLayout.largeText(context),
            tabAlignment: LudixaLayout.largeText(context) ? TabAlignment.start : null,
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
      padding: LudixaLayout.page(context, top: 16),
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
        const AdBanner(),
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

/// Tarjetas en filas de [columns], todas del alto de la más alta de su fila.
Widget _grid(List<Widget> tiles, int columns, {double gap = 12}) => Column(
  children: [
    for (var i = 0; i < tiles.length; i += columns) ...[
      if (i > 0) SizedBox(height: gap),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: gap),
              Expanded(child: i + c < tiles.length ? tiles[i + c] : const SizedBox.shrink()),
            ],
          ],
        ),
      ),
    ],
  ],
);

/// Los 4 totales en una grilla de 2 × 2; en una columna si no caben.
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
    return LayoutBuilder(
      builder: (context, constraints) =>
          _grid(tiles, LudixaLayout.columns(context, constraints.maxWidth, minWidth: 130, max: 2)),
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
    String wonText(DifficultyStats? stats) => showRate && stats?.winRate != null
        ? l10n.progressWonRate(stats!.won, percent.format(stats.winRate))
        : '${stats?.won ?? 0}';
    String timeText(Duration? d) => d == null ? '—' : formatDuration(d);

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
        // 48 dp de alto como mínimo: la fila se mantiene pulsada para reiniciar.
        final padded = ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Align(
              alignment: start ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
              child: child,
            ),
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
          cell(value(l10n.progressColWon, wonText(stats))),
          cell(time(l10n.progressColBest, stats?.bestTime)),
          cell(time(l10n.progressColMean, stats?.meanTime)),
        ],
      );
    }

    final table = LudixaCard(
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

    // Lista por nivel: cuando la tabla no cabe (pantalla angosta o texto
    // grande). Cada dato en su línea, con su nombre.
    Widget listEntry(Difficulty level) {
      final stats = levels[level];
      final played = stats != null && stats.started > 0;
      final name = module.difficultyLabel(context, level);
      final best = stats?.bestTime, mean = stats?.meanTime;
      final lines = [
        (l10n.progressColPlayed, '${stats?.started ?? 0}', null),
        (l10n.progressColWon, wonText(stats), null),
        (l10n.progressColBest, timeText(best), best == null ? l10n.progressNoTime : null),
        (l10n.progressColMean, timeText(mean), mean == null ? l10n.progressNoTime : null),
      ];
      final content = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: text.titleMedium),
            if (!played) Text(l10n.progressNotPlayed, style: text.bodySmall?.copyWith(color: p.inkMuted)),
            for (final (label, shown, spoken) in lines)
              Semantics(
                label: '$label: ${spoken ?? shown}',
                excludeSemantics: true,
                child: LudixaSplitLine(
                  start: Text(label, style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                  end: Text(shown, style: text.bodyMedium),
                ),
              ),
          ],
        ),
      );
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: !played
            ? content
            : Semantics(
                onLongPressHint: l10n.progressResetLevel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () => _confirmReset(context, ref, level, name),
                  child: content,
                ),
              ),
      );
    }

    // La tabla solo se muestra si cabe con el idioma y el tamaño de texto
    // actuales: el nivel y las ganadas ("3 (60 %)") pueden partirse entre
    // palabras; las otras cifras y los encabezados, no. Si no cabe, se
    // cortaría por la derecha.
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    double width(String s, TextStyle? style) {
      final painter = TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    double column(String header, Iterable<(String, TextStyle?)> cells) =>
        [width(header, text.labelLarge), for (final (s, style) in cells) width(s, style)].reduce(math.max) + 12;
    final tableWidth = [
      column(l10n.progressColLevel, [
        for (final level in order) ...[
          for (final word in module.difficultyLabel(context, level).split(' ')) (word, text.bodyLarge),
          if ((levels[level]?.started ?? 0) == 0)
            for (final word in l10n.progressNotPlayed.split(' ')) (word, text.bodySmall),
        ],
      ]),
      column(l10n.progressColPlayed, [for (final level in order) ('${levels[level]?.started ?? 0}', text.bodyMedium)]),
      column(l10n.progressColWon, [
        for (final level in order)
          for (final word in wonText(levels[level]).split(' ')) (word, text.bodyMedium),
      ]),
      column(l10n.progressColBest, [for (final level in order) (timeText(levels[level]?.bestTime), text.bodyMedium)]),
      column(l10n.progressColMean, [for (final level in order) (timeText(levels[level]?.meanTime), text.bodyMedium)]),
    ].fold(0.0, (a, b) => a + b);

    return LayoutBuilder(
      builder: (context, constraints) => tableWidth <= constraints.maxWidth
          ? table
          : LudixaCard(
              padding: EdgeInsets.zero,
              child: Column(children: [for (final level in order) listEntry(level)]),
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
    return ListView(
      padding: LudixaLayout.page(context, top: 16),
      children: [
        Text(l10n.achievementsCount(unlocked, achievements.length), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => _grid([
            for (final a in achievements) _AchievementTile(state: a),
          ], LudixaLayout.columns(context, constraints.maxWidth, minWidth: 140)),
        ),
        const AdBanner(),
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
