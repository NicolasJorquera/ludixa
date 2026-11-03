import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress/progress.dart';

import '../../l10n/generated/app_localizations.dart';
import '../play/game_session_page.dart';
import '../play/play_providers.dart';
import 'daily_data.dart';

String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  if (minutes < 60) return '$minutes:$seconds';
  return '${d.inHours}:${(minutes % 60).toString().padLeft(2, '0')}:$seconds';
}

/// Las 3 filas de un día: juego, nivel (y tema) y su estado o "Jugar". El
/// primer pendiente lleva el botón principal. Hoy juega el reto diario; un
/// día pasado lo juega desde el archivo.
class ChallengeRows extends ConsumerWidget {
  const ChallengeRows({super.key, required this.status, required this.isToday});

  final DayStatus status;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final modules = ref.watch(gameModulesProvider);
    final day = status.day;
    final firstPending = dailyGames.where((g) => !status.done(g)).firstOrNull;
    return Column(
      children: [
        for (final game in dailyGames)
          if (modules[game] case final module?)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LudixaCard(
                child: Row(
                  children: [
                    module.buildIcon(context, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [
                              module.displayName(context),
                              module.difficultyLabel(context, module.dailySpec(day).difficulty),
                              ?module.dailyDetail(context, day),
                            ].join(' · '),
                            style: text.titleSmall,
                          ),
                          if (status.done(game))
                            Text(
                              status.completed.contains(game)
                                  ? l10n.dailyCompletedIn(formatDuration(status.timeByGame[game] ?? Duration.zero))
                                  : l10n.dailyCompletedArchive,
                              style: text.bodySmall?.copyWith(color: p.successInk),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (status.done(game))
                      LudixaIcon(LudixaIcons.check, color: p.success)
                    else
                      LudixaButton(
                        expand: false,
                        label: status.running.containsKey(game) ? l10n.dailyContinue : l10n.dailyPlay,
                        variant: game == firstPending ? LudixaButtonVariant.primary : LudixaButtonVariant.secondary,
                        onPressed: () {
                          final running = status.running[game];
                          if (running != null) {
                            GameFlow.resume(context, module, running);
                          } else {
                            GameFlow.play(
                              context,
                              module,
                              isToday ? GameFlow.dailyRequest(module, day) : GameFlow.archiveRequest(module, day),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
