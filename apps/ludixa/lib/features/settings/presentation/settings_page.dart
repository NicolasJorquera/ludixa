import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/environment.dart';
import '../../../app/locales.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

/// Ajustes generales. Por ahora: tema, paleta, idioma y licencias. El resto llega en H4-09.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final environment = ref.watch(environmentProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          LudixaSectionLabel(l10n.settingsThemeSection),
          RadioGroup<ThemePreference>(
            groupValue: settings.theme,
            onChanged: (value) {
              if (value != null) controller.setTheme(value);
            },
            child: Column(
              children: [
                RadioListTile(value: ThemePreference.system, title: Text(l10n.themeSystem)),
                RadioListTile(value: ThemePreference.light, title: Text(l10n.themeLight)),
                RadioListTile(value: ThemePreference.dark, title: Text(l10n.themeDark)),
              ],
            ),
          ),
          LudixaSwitchRow(
            title: l10n.colorblindPalette,
            subtitle: l10n.colorblindPaletteHint,
            value: settings.colorblindPalette,
            onChanged: controller.setColorblindPalette,
          ),
          LudixaSectionLabel(l10n.settingsLanguageSection),
          RadioGroup<_LanguageOption>(
            groupValue: _LanguageOption.fromLocale(settings.locale),
            onChanged: (value) {
              if (value != null) controller.setLocale(value.locale);
            },
            child: Column(
              children: [
                RadioListTile(value: _LanguageOption.system, title: Text(l10n.languageSystem)),
                RadioListTile(value: _LanguageOption.spanish, title: Text(l10n.languageSpanish)),
                RadioListTile(value: _LanguageOption.english, title: Text(l10n.languageEnglish)),
                if (!environment.isProduction)
                  RadioListTile(value: _LanguageOption.pseudo, title: Text(l10n.languagePseudo)),
              ],
            ),
          ),
          LudixaSectionLabel(l10n.settingsAboutSection),
          LudixaListRow(title: l10n.settingsLicenses, onTap: () => context.go(AppRoutes.licenses)),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsComponentCatalog, onTap: () => context.go(AppRoutes.catalog)),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsDevSudoku, onTap: () => context.go(AppRoutes.devSudoku)),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsDevMinesweeper, onTap: () => context.go(AppRoutes.devMinesweeper)),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsDevWordSearch, onTap: () => context.go(AppRoutes.devWordSearch)),
        ],
      ),
    );
  }
}

enum _LanguageOption {
  system(null),
  spanish(Locale('es')),
  english(Locale('en')),
  pseudo(pseudoLocale);

  const _LanguageOption(this.locale);

  final Locale? locale;

  static _LanguageOption fromLocale(Locale? locale) =>
      values.firstWhere((option) => option.locale == locale, orElse: () => _LanguageOption.system);
}
