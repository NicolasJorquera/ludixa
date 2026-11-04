import 'package:design_system/design_system.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress/progress.dart';

import 'app/app.dart';
import 'app/environment.dart';
import 'features/ads/ads_controller.dart';
import 'features/games/game_settings.dart';
import 'features/play/last_difficulty.dart';
import 'features/play/play_providers.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_repository.dart';

/// Punto de arranque común a todos los entornos.
///
/// Carga los ajustes antes del primer fotograma para que el tema y el idioma
/// correctos se vean desde el inicio.
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPhonesToPortrait();
  registerDesignSystemLicenses();
  final settingsRepository = await SharedPreferencesSettingsRepository.create();
  final sudokuSettings = await PrefsSudokuSettingsStore.create();
  final minesweeperSettings = await PrefsMinesweeperSettingsStore.create();
  final wordSearchSettings = await PrefsWordSearchSettingsStore.create();
  final lastDifficulty = await PrefsLastDifficultyStore.create();
  final adPolicyStore = await PrefsAdPolicyStore.create();
  // Archivo SQLite en el almacenamiento de la app; drift_flutter lo abre en
  // otro isolate para no frenar la interfaz.
  final progress = DriftProgressRepository(ProgressDatabase(driftDatabase(name: 'progress')));
  runApp(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(environment),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        sudokuSettingsStoreProvider.overrideWithValue(sudokuSettings),
        minesweeperSettingsStoreProvider.overrideWithValue(minesweeperSettings),
        wordSearchSettingsStoreProvider.overrideWithValue(wordSearchSettings),
        lastDifficultyStoreProvider.overrideWithValue(lastDifficulty),
        progressRepositoryProvider.overrideWithValue(progress),
        adPolicyStoreProvider.overrideWithValue(adPolicyStore),
      ],
      child: const LudixaApp(),
    ),
  );
}

/// Vertical en teléfonos y libre en tablets (ficha UX, "Adaptación a
/// tamaños"): un teléfono tiene menos de 600 dp en su lado corto.
Future<void> lockPhonesToPortrait() async {
  final display = WidgetsBinding.instance.platformDispatcher.displays.first;
  final shortestSide = display.size.shortestSide / display.devicePixelRatio;
  if (shortestSide < 600) await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
