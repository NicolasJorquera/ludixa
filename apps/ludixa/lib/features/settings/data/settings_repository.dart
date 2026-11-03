import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Dónde se guardan las preferencias generales.
abstract interface class SettingsRepository {
  /// Lectura síncrona: los ajustes se necesitan antes del primer fotograma.
  AppSettings load();

  Future<void> save(AppSettings settings);
}

/// Implementación sobre `shared_preferences` con caché en memoria.
final class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository._(this._prefs);

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _colorblindKey = 'settings.colorblind';
  static const _textSizeKey = 'settings.textSize';
  static const _reduceMotionKey = 'settings.reduceMotion';
  static const _hapticsKey = 'settings.haptics';
  static const _showTimerKey = 'settings.showTimer';

  final SharedPreferencesWithCache _prefs;

  static Future<SharedPreferencesSettingsRepository> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_themeKey, _localeKey, _colorblindKey, _textSizeKey, _reduceMotionKey, _hapticsKey, _showTimerKey},
      ),
    );
    return SharedPreferencesSettingsRepository._(prefs);
  }

  @override
  AppSettings load() {
    final themeName = _prefs.getString(_themeKey);
    final theme = ThemePreference.values.where((t) => t.name == themeName).firstOrNull ?? ThemePreference.system;
    final tag = _prefs.getString(_localeKey);
    return AppSettings(
      theme: theme,
      locale: tag == null ? null : _parseTag(tag),
      colorblindPalette: _prefs.getBool(_colorblindKey) ?? false,
      textSize:
          TextSizePreference.values.where((t) => t.name == _prefs.getString(_textSizeKey)).firstOrNull ??
          TextSizePreference.system,
      reduceMotion: _prefs.getBool(_reduceMotionKey) ?? false,
      haptics: _prefs.getBool(_hapticsKey) ?? true,
      showTimer: _prefs.getBool(_showTimerKey) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_themeKey, settings.theme.name);
    await _prefs.setBool(_colorblindKey, settings.colorblindPalette);
    await _prefs.setString(_textSizeKey, settings.textSize.name);
    await _prefs.setBool(_reduceMotionKey, settings.reduceMotion);
    await _prefs.setBool(_hapticsKey, settings.haptics);
    await _prefs.setBool(_showTimerKey, settings.showTimer);
    final locale = settings.locale;
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.toLanguageTag());
    }
  }

  static Locale _parseTag(String tag) {
    final parts = tag.split('-');
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
