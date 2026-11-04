import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:game_wordsearch/game_wordsearch.dart';

import '../features/ads/ads_controller.dart';
import '../features/ads/ads_providers.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/settings/domain/app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'environment.dart';
import 'locales.dart';
import 'router.dart';

/// Raíz de la app: tema, paleta, idioma, tamaño de texto y animaciones salen
/// de los ajustes y cambian en caliente.
class LudixaApp extends ConsumerWidget {
  const LudixaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);
    final settings = ref.watch(settingsProvider);
    // Consentimiento y anuncios en segundo plano, en cada arranque. La
    // política se crea ya: abrir la app es una sesión, aunque no se juegue.
    ref.listen(adsReadyProvider, (_, _) {});
    ref.listen(adPolicyProvider, (_, _) {});
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
        MinesLocalizations.delegate,
        WordsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final app = _applyAccessibility(context, settings, child!);
        return environment.isProduction ? app : Banner(message: 'DEV', location: BannerLocation.topEnd, child: app);
      },
    );
  }
}

/// Tamaño de texto y animaciones de Ajustes, encima de lo que pide el
/// sistema: nunca achican el texto ni devuelven animaciones que el sistema
/// quitó.
Widget _applyAccessibility(BuildContext context, AppSettings settings, Widget child) {
  final media = MediaQuery.of(context);
  final factor = settings.textSize.factor;
  if (factor == 1 && !settings.reduceMotion) return child;
  return MediaQuery(
    data: media.copyWith(
      textScaler: factor == 1 ? media.textScaler : TextScaler.linear(media.textScaler.scale(1) * factor),
      disableAnimations: media.disableAnimations || settings.reduceMotion,
    ),
    child: child,
  );
}
