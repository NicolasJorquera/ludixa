import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Se reemplaza en el arranque con la implementación real (ver bootstrap).
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('settingsRepositoryProvider se configura en bootstrap'),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Ajustes vigentes. Cada cambio se aplica al instante y se guarda.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setTheme(ThemePreference theme) => _update(state.copyWith(theme: theme));

  /// `null` vuelve a seguir el idioma del sistema.
  Future<void> setLocale(Locale? locale) => _update(state.copyWith(locale: () => locale));

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
