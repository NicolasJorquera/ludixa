import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:puzzle_core/puzzle_core.dart';

/// Partida de Sudoku de prueba, solo en el entorno dev. Usa un host en
/// memoria: 3 pistas gratis, sin videos y sin guardar entre sesiones. La
/// integración real (resultado, guardado, anuncios) llega en H4-05 y H5.
class DevSudokuPage extends StatefulWidget {
  const DevSudokuPage({super.key});

  @override
  State<DevSudokuPage> createState() => _DevSudokuPageState();
}

class _DevSudokuPageState extends State<DevSudokuPage> {
  String _level = 'easy';
  bool _numberFirst = false;
  bool _solutionErrors = false;

  @override
  Widget build(BuildContext context) {
    const module = SudokuModule();
    final options = module.difficulties(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku (dev)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LudixaSegmentedControl<String>(
            segments: [for (final o in options) LudixaSegment(value: o.id.value, label: o.label)],
            selected: _level,
            onChanged: (v) => setState(() => _level = v),
          ),
          LudixaSwitchRow(
            title: 'Número primero',
            value: _numberFirst,
            onChanged: (v) => setState(() => _numberFirst = v),
          ),
          LudixaSwitchRow(
            title: 'Errores contra la solución',
            value: _solutionErrors,
            onChanged: (v) => setState(() => _solutionErrors = v),
          ),
          const SizedBox(height: 16),
          LudixaButton(label: 'Jugar', onPressed: _play),
        ],
      ),
    );
  }

  void _play() {
    final host = DevGameHost();
    final settings = SudokuSettings(
      inputMode: _numberFirst ? SudokuInputMode.numberFirst : SudokuInputMode.cellFirst,
      errorMode: _solutionErrors ? SudokuErrorMode.solution : SudokuErrorMode.conflicts,
    );
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SudokuGameLoader(
          request: PuzzleRequest(mode: PuzzleMode.free, difficulty: Difficulty(_level), seed: PuzzleSeed.random()),
          host: host,
          settings: settings,
          onSolved: () => Navigator.of(context).maybePop(),
        ),
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
