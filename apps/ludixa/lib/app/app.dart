import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_sudoku/game_sudoku.dart';

import '../features/settings/application/settings_controller.dart';
import '../features/settings/domain/app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'environment.dart';
import 'locales.dart';
import 'router.dart';

/// Raíz de la app: tema, paleta e idioma salen de los ajustes y cambian en caliente.
class LudixaApp extends ConsumerWidget {
  const LudixaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);
    final settings = ref.watch(settingsProvider);
    final supported = supportedLocalesFor(environment);
    final variant = settings.colorblindPalette ? PaletteVariant.colorblind : PaletteVariant.standard;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: buildLudixaTheme(brightness: Brightness.light, variant: variant),
      darkTheme: buildLudixaTheme(brightness: Brightness.dark, variant: variant),
      themeMode: switch (settings.theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      locale: settings.locale,
      supportedLocales: supported,
      localeListResolutionCallback: (preferred, _) => resolveLocale(preferred, supported),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        SudokuLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          environment.isProduction ? child! : Banner(message: 'DEV', location: BannerLocation.topEnd, child: child),
    );
  }
}
