import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../app/router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../play/game_session_page.dart';
import '../play/play_providers.dart';
import 'home_data.dart';

/// Portada: lleva al próximo puzzle en un toque (el reto de hoy o la partida
/// en curso), con el catálogo, la maestría y "Tu semana". El banner llega con
/// la monetización (H5).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(homeDataProvider);
    final streak = data.value?.streak.current ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          if (streak > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: LudixaStatChip(
                icon: LudixaIcons.streak,
                value: '$streak',
                semanticLabel: l10n.homeStreak(streak),
                onTap: () => context.go(AppRoutes.daily),
              ),
            ),
        ],
      ),
      body: switch (data) {
        AsyncData(:final value) => _HomeContent(data: value),
        AsyncError() => _HomeError(onRetry: () => ref.invalidate(homeDataProvider)),
        _ => const _HomeSkeleton(),
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final modules = ref.watch(gameModulesProvider);
    final running = data.inProgress;
    final runningModule = running == null ? null : modules[running.game];
    return ListView(
      padding: LudixaLayout.page(context, top: 8),
      children: [
        _DailyCard(data: data, modules: modules),
        if (running != null && runningModule != null) ...[
          const SizedBox(height: 12),
          _ContinueCard(session: running, module: runningModule),
        ],
        LudixaSectionLabel(l10n.homeGames, padding: const EdgeInsetsDirectional.fromSTEB(4, 24, 4, 8)),
        _Catalog(data: data, modules: modules),
        LudixaSectionLabel(l10n.homeWeek, padding: const EdgeInsetsDirectional.fromSTEB(4, 24, 4, 8)),
        _WeekCard(week: data.week, modules: modules),
      ],
    );
  }
}

String _format(Duration d) {
  final minutes = d.inMinutes;
  final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  if (minutes < 60) return '$minutes:$seconds';
  return '${d.inHours}:${(minutes % 60).toString().padLeft(2, '0')}:$seconds';
}

String _levelLabel(BuildContext context, GameModule module, Difficulty level) =>
    module.difficulties(context).where((o) => o.id == level).firstOrNull?.label ??
    AppLocalizations.of(context).homeDailyTitle;

/// "Reto de hoy": estado de los tres juegos y el botón principal al primer
/// pendiente. Completo: "Hoy: hecho ✓" con el tiempo total y el archivo.
class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.data, required this.modules});

  final HomeData data;
  final Map<GameId, GameModule> modules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final pending = [
      for (final g in dailyGames)
        if (!data.dailyDone.contains(g)) modules[g],
    ].nonNulls;
    final next = pending.firstOrNull;
    return LudixaCard(
      onTap: () => context.go(AppRoutes.daily),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(data.dailyComplete ? l10n.homeDailyDone : l10n.homeDailyTitle, style: text.titleLarge),
              ),
              if (data.dailyComplete) ...[const SizedBox(width: 8), LudixaIcon(LudixaIcons.check, color: p.success)],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data.dailyComplete
                ? l10n.homeDailyDoneTime(_format(data.dailyTime))
                : data.firstTime
                ? l10n.homeDailyFirst
                : l10n.homeDailyProgress(data.dailyDone.length),
            style: text.bodyMedium?.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: 12),
          for (final game in dailyGames)
            if (modules[game] case final module?)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    module.buildIcon(context, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LudixaSplitLine(
                        start: Text(module.displayName(context), style: text.bodyLarge),
                        end: data.dailyDone.contains(game)
                            ? LudixaIcon(LudixaIcons.check, color: p.success, semanticLabel: l10n.homeDailyStateDone)
                            : Text(l10n.homeDailyStatePending, style: text.bodySmall),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 12),
          if (next != null)
            LudixaButton(
              label: l10n.homeDailyPlay(next.displayName(context)),
              onPressed: () => GameFlow.play(context, next, GameFlow.dailyRequest(next, data.today)),
            )
          else
            LudixaButton(
              label: l10n.homeDailyArchive,
              onPressed: () => context.go(AppRoutes.archive),
              variant: LudixaButtonVariant.tertiary,
            ),
        ],
      ),
    );
  }
}

/// "Continuar": abre la partida en el estado exacto en que quedó.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.session, required this.module});

  final SessionRecord session;
  final GameModule module;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final detail = l10n.homeContinueDetail(
      module.displayName(context),
      session.mode == PuzzleMode.daily ? l10n.homeDailyTitle : _levelLabel(context, module, session.difficulty),
      _format(session.elapsed),
    );
    return LudixaCard(
      onTap: () => GameFlow.resume(context, module, session),
      semanticLabel: '${l10n.homeContinue}: $detail',
      child: Row(
        children: [
          module.buildIcon(context, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeContinue, style: text.titleMedium),
                Text(detail, style: text.bodyMedium),
              ],
            ),
          ),
          const LudixaIcon(LudixaIcons.play),
        ],
      ),
    );
  }
}

/// Catálogo: cada juego con su maestría; abre la hoja de dificultad. Bajo
/// 360 dp pasa a una lista de 3 filas.
class _Catalog extends ConsumerWidget {
  const _Catalog({required this.data, required this.modules});

  final HomeData data;
  final Map<GameId, GameModule> modules;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;

    String mastery(GameModule module) {
      final best = data.bestLevel(module.id);
      if (best == null) return l10n.homeNoMastery;
      final medal = Mastery.forWins(best.$2);
      if (medal == Mastery.none) return l10n.homeNoMastery;
      return l10n.homeMastery(
        l10n.masteryLevel(medal.name).toLowerCase(),
        _levelLabel(context, module, best.$1).toLowerCase(),
      );
    }

    Widget card(GameModule module, {required bool row}) {
      final line = mastery(module);
      final name = module.displayName(context);
      return LudixaCard(
        onTap: () => GameFlow.chooseAndPlay(context, ref, module),
        semanticLabel: l10n.homeGameLabel(name, line),
        child: row
            ? Row(
                children: [
                  module.buildIcon(context, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: text.titleMedium),
                        Text(line, style: text.bodySmall?.copyWith(color: p.inkMuted)),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  module.buildIcon(context, size: 28),
                  const SizedBox(height: 8),
                  // Una sola línea: "Buscaminas" no debe partirse a mitad de palabra.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(name, style: text.titleSmall, maxLines: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(line, style: text.bodySmall?.copyWith(color: p.inkMuted), maxLines: 3),
                ],
              ),
      );
    }

    final games = [for (final g in dailyGames) modules[g]].nonNulls.toList();
    // La ficha habla del ancho de la pantalla, no del contenido. Con texto
    // grande, los juegos también van en lista.
    return LudixaLayout.compact(context) || LudixaLayout.largeText(context)
        ? Column(
            children: [
              for (final m in games) Padding(padding: const EdgeInsets.only(bottom: 8), child: card(m, row: true)),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, m) in games.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: card(m, row: false)),
                ],
              ],
            ),
          );
  }
}

/// "Tu semana": partidas por juego, mejor marca y tiempo jugado.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week, required this.modules});

  final WeekSummary week;
  final Map<GameId, GameModule> modules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LudixaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final game in dailyGames)
            if (modules[game] case final module?)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: LudixaSplitLine(
                  start: Text(module.displayName(context), style: text.bodyLarge),
                  end: Text(
                    [
                      l10n.homeWeekGames(week.completedByGame[game] ?? 0),
                      if (week.bestTimeByGame[game] case final best?) l10n.homeWeekBest(_format(best)),
                    ].join(' · '),
                    style: text.bodyMedium,
                  ),
                ),
              ),
          const Divider(height: 20),
          Text(l10n.homeWeekTime(_format(week.time)), style: text.titleSmall),
        ],
      ),
    );
  }
}

/// Esqueleto de carga: los datos son locales y llegan en menos de 300 ms.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: p.surfaceMuted, borderRadius: BorderRadius.circular(16)),
    );
    return ListView(
      padding: LudixaLayout.page(context, top: 16, bottom: 16),
      children: [block(220), block(80), block(120), block(140)],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.homeLoadError, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            LudixaButton(label: l10n.homeRetry, onPressed: onRetry, expand: false),
          ],
        ),
      ),
    );
  }
}
