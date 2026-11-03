import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ajustes del Sudoku. En memoria por defecto (pruebas); bootstrap lo
/// reemplaza por [PrefsSudokuSettingsStore].
final sudokuSettingsStoreProvider = Provider<SudokuSettingsStore>((ref) => InMemorySudokuSettingsStore());

/// Ajustes del Sudoku en `shared_preferences`, como JSON en una sola clave.
final class PrefsSudokuSettingsStore implements SudokuSettingsStore {
  PrefsSudokuSettingsStore._(this._prefs);

  static const _key = 'games.sudoku.settings';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsSudokuSettingsStore> create() async => PrefsSudokuSettingsStore._(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key})),
  );

  @override
  SudokuSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const SudokuSettings();
    try {
      return SudokuSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      return const SudokuSettings();
    }
  }

  @override
  Future<void> save(SudokuSettings settings) => _prefs.setString(_key, jsonEncode(settings.toJson()));
}

/// Ajustes del Buscaminas. En memoria por defecto; bootstrap pone el real.
final minesweeperSettingsStoreProvider = Provider<MinesweeperSettingsStore>(
  (ref) => InMemoryMinesweeperSettingsStore(),
);

/// Ajustes del Buscaminas en `shared_preferences`, como JSON en una sola clave.
final class PrefsMinesweeperSettingsStore implements MinesweeperSettingsStore {
  PrefsMinesweeperSettingsStore._(this._prefs);

  static const _key = 'games.minesweeper.settings';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsMinesweeperSettingsStore> create() async => PrefsMinesweeperSettingsStore._(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key})),
  );

  @override
  MinesweeperSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const MinesweeperSettings();
    try {
      return MinesweeperSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      return const MinesweeperSettings();
    }
  }

  @override
  Future<void> save(MinesweeperSettings settings) => _prefs.setString(_key, jsonEncode(settings.toJson()));
}

/// Ajustes de la Sopa. En memoria por defecto; bootstrap pone el real.
final wordSearchSettingsStoreProvider = Provider<WordSearchSettingsStore>((ref) => InMemoryWordSearchSettingsStore());

/// Ajustes de la Sopa en `shared_preferences`, como JSON en una sola clave.
final class PrefsWordSearchSettingsStore implements WordSearchSettingsStore {
  PrefsWordSearchSettingsStore._(this._prefs);

  static const _key = 'games.wordsearch.settings';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsWordSearchSettingsStore> create() async => PrefsWordSearchSettingsStore._(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key})),
  );

  @override
  WordSearchSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const WordSearchSettings();
    try {
      return WordSearchSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      return const WordSearchSettings();
    }
  }

  @override
  Future<void> save(WordSearchSettings settings) => _prefs.setString(_key, jsonEncode(settings.toJson()));
}
