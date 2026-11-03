import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../games/game_settings.dart';
import 'dev_sudoku_page.dart' show DevGameHost;

/// Partida de Buscaminas de prueba, solo en el entorno dev. Usa los ajustes
/// guardados y un host en memoria (3 pistas, sin videos: el rescate responde
/// "no disponible"). La integración real llega en H4-05 y H5.
class DevMinesweeperPage extends ConsumerStatefulWidget {
  const DevMinesweeperPage({super.key});

  @override
  ConsumerState<DevMinesweeperPage> createState() => _DevMinesweeperPageState();
}

class _DevMinesweeperPageState extends ConsumerState<DevMinesweeperPage> {
  Difficulty _level = MinesweeperLevels.beginner;
  bool _daily = false;

  @override
  Widget build(BuildContext context) {
    final module = MinesweeperModule(store: ref.watch(minesweeperSettingsStoreProvider));
    final options = module.difficulties(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Minesweeper (dev)')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LudixaSegmentedControl<Difficulty>(
              segments: [for (final o in options) LudixaSegment(value: o.id, label: o.label)],
              selected: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
          ),
          LudixaSwitchRow(
            title: 'Today challenge (board and level of the day)',
            value: _daily,
            onChanged: (v) => setState(() => _daily = v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LudixaButton(label: 'Play', onPressed: () => _play(module)),
          ),
          ?module.buildSettings(context),
          LudixaListRow(title: MinesLocalizations.of(context).settingsTutorial, onTap: () => _tutorial(module)),
        ],
      ),
    );
  }

  void _play(MinesweeperModule module) {
    final today = LocalDay.fromDateTime(DateTime.now());
    final request = _daily
        ? PuzzleRequest(
            mode: PuzzleMode.daily,
            difficulty: module.dailySpec(today).difficulty,
            seed: PuzzleSeed.random(),
            day: today,
          )
        : PuzzleRequest(mode: PuzzleMode.free, difficulty: _level, seed: PuzzleSeed.random());
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => module.buildGame(context, request, DevGameHost()),
      ),
    );
  }

  void _tutorial(MinesweeperModule module) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => module.buildTutorial(context, DevGameHost()),
      ),
    );
  }
}
