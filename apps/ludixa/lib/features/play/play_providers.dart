import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../games/game_settings.dart';
import 'last_difficulty.dart';

/// Reloj de la app. Las pruebas lo reemplazan por uno falso.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Progreso en memoria: así lo usan las pantallas de H4. H5-02 lo cambia por
/// Drift sin tocar el dominio.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) => InMemoryProgressRepository());

final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(ref.watch(progressRepositoryProvider), clock: ref.watch(clockProvider)),
);

final lastDifficultyStoreProvider = Provider<LastDifficultyStore>((ref) => InMemoryLastDifficultyStore());

/// Los juegos de la colección, en el orden de la portada.
final gameModulesProvider = Provider<Map<GameId, GameModule>>(
  (ref) => {
    GameId.sudoku: SudokuModule(store: ref.watch(sudokuSettingsStoreProvider)),
    GameId.minesweeper: MinesweeperModule(store: ref.watch(minesweeperSettingsStoreProvider)),
    GameId.wordSearch: WordSearchModule(store: ref.watch(wordSearchSettingsStoreProvider)),
  },
);

/// Sube cada vez que el progreso cambia (partida guardada o terminada). Las
/// pantallas que muestran progreso lo vigilan para refrescarse.
final progressRevisionProvider = NotifierProvider<ProgressRevision, int>(ProgressRevision.new);

class ProgressRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
