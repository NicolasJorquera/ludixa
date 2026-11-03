import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../play/game_session_page.dart';
import '../play/play_providers.dart';

/// Juegos de prueba, solo en el entorno dev, con el flujo real: hoja de
/// dificultad, partida, pausa y resultado, guardando en el progreso en
/// memoria. La portada (H4-06) y el reto (H4-07) lo usarán igual.
class DevGamesPage extends ConsumerWidget {
  const DevGamesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(gameModulesProvider).values;
    final today = ref.watch(clockProvider).now().day;
    return Scaffold(
      appBar: AppBar(title: const Text('Games (dev)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final module in modules) ...[
            LudixaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      module.buildIcon(context),
                      const SizedBox(width: 12),
                      Text(module.displayName(context), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LudixaButton(label: 'Play', onPressed: () => GameFlow.chooseAndPlay(context, ref, module)),
                  const SizedBox(height: 8),
                  LudixaButton(
                    label: 'Today challenge',
                    variant: LudixaButtonVariant.secondary,
                    onPressed: () => GameFlow.play(context, module, GameFlow.dailyRequest(module, today)),
                  ),
                  LudixaButton(
                    label: 'Tutorial',
                    variant: LudixaButtonVariant.tertiary,
                    onPressed: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (context) => module.buildTutorial(context, const TutorialHost()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
