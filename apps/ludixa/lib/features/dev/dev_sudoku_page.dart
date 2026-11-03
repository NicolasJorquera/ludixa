import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../games/game_settings.dart';

/// Partida de Sudoku de prueba, solo en el entorno dev. Usa los ajustes
/// guardados del juego y un host en memoria: 3 pistas gratis, sin videos y
/// sin guardar la partida. La integración real llega en H4-05 y H5.
class DevSudokuPage extends ConsumerStatefulWidget {
  const DevSudokuPage({super.key});

  @override
  ConsumerState<DevSudokuPage> createState() => _DevSudokuPageState();
}

class _DevSudokuPageState extends ConsumerState<DevSudokuPage> {
  String _level = 'easy';

  @override
  Widget build(BuildContext context) {
    final module = SudokuModule(store: ref.watch(sudokuSettingsStoreProvider));
    final options = module.difficulties(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku (dev)')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LudixaSegmentedControl<String>(
              segments: [for (final o in options) LudixaSegment(value: o.id.value, label: o.label)],
              selected: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LudixaButton(label: 'Play', onPressed: () => _play(module)),
          ),
          ?module.buildSettings(context),
          LudixaListRow(title: SudokuLocalizations.of(context).settingsTutorial, onTap: () => _tutorial(module)),
        ],
      ),
    );
  }

  void _play(SudokuModule module) {
    final host = DevGameHost();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SudokuGameLoader(
          request: PuzzleRequest(mode: PuzzleMode.free, difficulty: Difficulty(_level), seed: PuzzleSeed.random()),
          host: host,
          settings: module.store.load(),
          onSolved: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  void _tutorial(SudokuModule module) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => module.buildTutorial(context, DevGameHost()),
      ),
    );
  }
}

/// Host en memoria para probar módulos de juego.
class DevGameHost implements GameHost {
  int _free = 3;
  final snapshots = <SessionSnapshot>[];
  final results = <GameResult>[];

  @override
  int get freeHintsLeft => _free;

  @override
  Future<HintGrant> requestHint() async {
    if (_free == 0) return const HintDenied(HintDenial.limitReached);
    _free--;
    return const HintGranted(HintSource.free);
  }

  @override
  Future<RescueOutcome> requestRescue() async => RescueOutcome.unavailable;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async => snapshots.add(snapshot);

  @override
  Future<void> reportResult(GameResult result) async => results.add(result);
}
