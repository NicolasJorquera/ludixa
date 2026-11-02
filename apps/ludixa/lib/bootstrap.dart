import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/environment.dart';

/// Punto de arranque común a todos los entornos.
void bootstrap(AppEnvironment environment) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LudixaApp(environment: environment));
}
