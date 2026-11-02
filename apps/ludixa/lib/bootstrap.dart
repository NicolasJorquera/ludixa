import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/environment.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_repository.dart';

/// Punto de arranque común a todos los entornos.
///
/// Carga los ajustes antes del primer fotograma para que el tema y el idioma
/// correctos se vean desde el inicio.
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsRepository = await SharedPreferencesSettingsRepository.create();
  runApp(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(environment),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const LudixaApp(),
    ),
  );
}
