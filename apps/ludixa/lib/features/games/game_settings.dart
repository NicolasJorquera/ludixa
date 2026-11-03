import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_sudoku/game_sudoku.dart';
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
