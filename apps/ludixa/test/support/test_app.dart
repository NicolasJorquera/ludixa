import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/app.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/features/ads/ads_providers.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:ludixa/features/settings/application/settings_controller.dart';
import 'package:ludixa/features/settings/data/settings_repository.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';
import 'package:monetization/monetization.dart';
import 'package:progress/progress.dart';

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

/// Consentimiento falso: no toca el plugin de UMP. [gate] deja el pedido
/// pendiente hasta completarlo.
class FakeConsent implements ConsentService {
  FakeConsent({this.allowed = false, this.privacyRequired = false, this.gate});

  bool allowed;
  bool privacyRequired;
  Completer<void>? gate;
  int gathered = 0;
  int privacyFormsShown = 0;

  @override
  Future<void> gather() async {
    gathered++;
    await gate?.future;
  }

  @override
  Future<bool> canRequestAds() async => allowed;

  @override
  Future<bool> privacyOptionsRequired() async => privacyRequired;

  @override
  Future<void> showPrivacyOptions() async => privacyFormsShown++;
}

/// SDK de anuncios falso: cuenta las inicializaciones.
class FakeAdsSdk implements AdsSdk {
  int initialized = 0;

  @override
  Future<void> initialize() async => initialized++;
}

/// Monta la app completa con ajustes en memoria y, por defecto, el sistema en español.
Future<InMemorySettingsRepository> pumpLudixa(
  WidgetTester tester, {
  AppEnvironment environment = AppEnvironment.dev,
  AppSettings initial = const AppSettings(),
  List<Locale> deviceLocales = const [Locale('es', 'CL')],
  List<Override> overrides = const [],

  /// Progreso en memoria: la app real abre la base Drift en bootstrap.
  ProgressRepository? progress,
  ConsentService? consent,
  AdsSdk? adsSdk,
}) async {
  tester.platformDispatcher.localesTestValue = deviceLocales;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final repository = InMemorySettingsRepository(initial);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(environment),
        settingsRepositoryProvider.overrideWithValue(repository),
        progressRepositoryProvider.overrideWithValue(progress ?? InMemoryProgressRepository()),
        consentServiceProvider.overrideWithValue(consent ?? FakeConsent()),
        adsSdkProvider.overrideWithValue(adsSdk ?? FakeAdsSdk()),
        ...overrides,
      ],
      child: const LudixaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
