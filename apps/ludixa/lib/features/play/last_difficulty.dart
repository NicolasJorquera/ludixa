import 'package:puzzle_core/puzzle_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Último nivel elegido en cada juego: la hoja de dificultad lo recuerda.
abstract interface class LastDifficultyStore {
  Difficulty? load(GameId game);

  Future<void> save(GameId game, Difficulty difficulty);
}

final class InMemoryLastDifficultyStore implements LastDifficultyStore {
  final _values = <GameId, Difficulty>{};

  @override
  Difficulty? load(GameId game) => _values[game];

  @override
  Future<void> save(GameId game, Difficulty difficulty) async => _values[game] = difficulty;
}

final class PrefsLastDifficultyStore implements LastDifficultyStore {
  PrefsLastDifficultyStore._(this._prefs);

  static const _games = [GameId.sudoku, GameId.minesweeper, GameId.wordSearch];
  static String _key(GameId game) => 'play.lastDifficulty.${game.value}';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsLastDifficultyStore> create() async => PrefsLastDifficultyStore._(
    await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: {for (final g in _games) _key(g)}),
    ),
  );

  @override
  Difficulty? load(GameId game) {
    final value = _prefs.getString(_key(game));
    return value == null ? null : Difficulty(value);
  }

  @override
  Future<void> save(GameId game, Difficulty difficulty) => _prefs.setString(_key(game), difficulty.value);
}
