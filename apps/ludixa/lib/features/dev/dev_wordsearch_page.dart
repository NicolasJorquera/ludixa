import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../games/game_settings.dart';
import 'dev_sudoku_page.dart' show DevGameHost;

/// Sopa de letras de prueba, solo en el entorno dev. Usa los ajustes guardados
/// y un host en memoria. La integración real llega en H4-05 y H5.
class DevWordSearchPage extends ConsumerStatefulWidget {
  const DevWordSearchPage({super.key});

  @override
  ConsumerState<DevWordSearchPage> createState() => _DevWordSearchPageState();
}

class _DevWordSearchPageState extends ConsumerState<DevWordSearchPage> {
  String _level = 'easy';
  bool _daily = false;

  @override
  Widget build(BuildContext context) {
    final module = WordSearchModule(store: ref.watch(wordSearchSettingsStoreProvider));
    final options = module.difficulties(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Word search (dev)')),
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
          LudixaSwitchRow(
            title: 'Today challenge (theme and level of the day)',
            value: _daily,
            onChanged: (v) => setState(() => _daily = v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LudixaButton(label: 'Play', onPressed: () => _play(module)),
          ),
          ?module.buildSettings(context),
          LudixaListRow(title: WordsLocalizations.of(context).settingsTutorial, onTap: () => _tutorial(module)),
        ],
      ),
    );
  }

  void _play(WordSearchModule module) {
    final today = LocalDay.fromDateTime(DateTime.now());
    final request = _daily
        ? PuzzleRequest(
            mode: PuzzleMode.daily,
            difficulty: module.dailySpec(today).difficulty,
            seed: PuzzleSeed.random(),
            day: today,
          )
        : PuzzleRequest(mode: PuzzleMode.free, difficulty: Difficulty(_level), seed: PuzzleSeed.random());
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => module.buildGame(context, request, DevGameHost()),
      ),
    );
  }

  void _tutorial(WordSearchModule module) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => module.buildTutorial(context, DevGameHost()),
      ),
    );
  }
}
