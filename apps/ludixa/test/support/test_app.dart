import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/app.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/features/settings/application/settings_controller.dart';
import 'package:ludixa/features/settings/data/settings_repository.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';

/// Repositorio en memoria. Solo para pruebas.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this.stored = const AppSettings()]);

  AppSettings stored;
  int saves = 0;

  @override
  AppSettings load() => stored;

  @override
  Future<void> save(AppSettings settings) async {
    stored = settings;
    saves++;
  }
}

/// Monta la app completa con ajustes en memoria y, por defecto, el sistema en español.
Future<InMemorySettingsRepository> pumpLudixa(
  WidgetTester tester, {
  AppEnvironment environment = AppEnvironment.dev,
  AppSettings initial = const AppSettings(),
  List<Locale> deviceLocales = const [Locale('es', 'CL')],
  List<Override> overrides = const [],
}) async {
  tester.platformDispatcher.localesTestValue = deviceLocales;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final repository = InMemorySettingsRepository(initial);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(environment),
        settingsRepositoryProvider.overrideWithValue(repository),
        ...overrides,
      ],
      child: const LudixaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
