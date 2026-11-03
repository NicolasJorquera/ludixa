import 'package:puzzle_core/puzzle_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Último nivel elegido en cada juego (la hoja de dificultad lo recuerda) y
/// si ya se vio el tutorial (la primera partida pasa por él).
abstract interface class LastDifficultyStore {
  Difficulty? load(GameId game);

  Future<void> save(GameId game, Difficulty difficulty);

  bool tutorialSeen(GameId game);

  Future<void> markTutorialSeen(GameId game);
}

final class InMemoryLastDifficultyStore implements LastDifficultyStore {
  final _values = <GameId, Difficulty>{};
  final _tutorials = <GameId>{};

  @override
  Difficulty? load(GameId game) => _values[game];

  @override
  Future<void> save(GameId game, Difficulty difficulty) async => _values[game] = difficulty;

  @override
  bool tutorialSeen(GameId game) => _tutorials.contains(game);

  @override
  Future<void> markTutorialSeen(GameId game) async => _tutorials.add(game);
}

final class PrefsLastDifficultyStore implements LastDifficultyStore {
  PrefsLastDifficultyStore._(this._prefs);

  static const _games = [GameId.sudoku, GameId.minesweeper, GameId.wordSearch];
  static String _key(GameId game) => 'play.lastDifficulty.${game.value}';
  static String _tutorialKey(GameId game) => 'play.tutorialSeen.${game.value}';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsLastDifficultyStore> create() async => PrefsLastDifficultyStore._(
    await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: {
          for (final g in _games) ...[_key(g), _tutorialKey(g)],
        },
      ),
    ),
  );

  @override
  Difficulty? load(GameId game) {
    final value = _prefs.getString(_key(game));
    return value == null ? null : Difficulty(value);
  }

  @override
  Future<void> save(GameId game, Difficulty difficulty) => _prefs.setString(_key(game), difficulty.value);

  @override
  bool tutorialSeen(GameId game) => _prefs.getBool(_tutorialKey(game)) ?? false;

  @override
  Future<void> markTutorialSeen(GameId game) => _prefs.setBool(_tutorialKey(game), true);
}
