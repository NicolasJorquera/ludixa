import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../features/daily/archive_page.dart';
import '../features/daily/daily_page.dart';
import '../features/dev/dev_games_page.dart';
import '../features/home/home_page.dart';
import '../features/progress/progress_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../l10n/generated/app_localizations.dart';
import 'environment.dart';
import 'shell.dart';

/// Rutas de primer nivel, una por pestaña, en el orden de la barra.
abstract final class AppRoutes {
  static const home = '/';
  static const daily = '/daily';
  static const archive = '/daily/archive';
  static String dailyDay(LocalDay day) => '/daily/day/${day.toIso8601()}';
  static const progress = '/progress';
  static const settings = '/settings';
  static const licenses = '/settings/licenses';

  /// Catálogo de componentes. Solo existe en el entorno dev.
  static const catalog = '/settings/catalog';

  /// Juegos de prueba con el flujo real. Solo existe en el entorno dev.
  static const devGames = '/settings/dev-games';
}

/// Router de la app: 4 pestañas que conservan cada una su pila de navegación.
/// Las partidas (H4) se abrirán como rutas de pantalla completa fuera del shell.
final routerProvider = Provider<GoRouter>((ref) {
  final environment = ref.watch(environmentProvider);
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.daily,
                builder: (context, state) => const DailyPage(),
                routes: [
                  GoRoute(path: 'archive', builder: (context, state) => const ArchivePage()),
                  GoRoute(
                    path: 'day/:date',
                    builder: (context, state) => DayPage(day: LocalDay.parse(state.pathParameters['date']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.progress, builder: (context, state) => const ProgressPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'licenses',
                    builder: (context, state) => LicensePage(applicationName: AppLocalizations.of(context).appName),
                  ),
                  if (!environment.isProduction)
                    GoRoute(path: 'catalog', builder: (context, state) => const ComponentCatalog()),
                  if (!environment.isProduction)
                    GoRoute(path: 'dev-games', builder: (context, state) => const DevGamesPage()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
