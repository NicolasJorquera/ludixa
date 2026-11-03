import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/environment.dart';
import '../../../app/locales.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../play/play_providers.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

/// Versión instalada, para la fila "Versión".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber.isEmpty ? info.version : '${info.version} (${info.buildNumber})';
});

/// Ajustes: General, Juegos, Datos y privacidad, e Información. Cada cambio
/// se aplica al instante. Sin anuncios: aquí se gestiona la privacidad.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final environment = ref.watch(environmentProvider);
    final modules = ref.watch(gameModulesProvider);
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          LudixaSectionLabel(l10n.settingsGeneralSection),
          _GroupLabel(l10n.settingsLanguageSection),
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
          _GroupLabel(l10n.settingsThemeSection),
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
          _GroupLabel(l10n.settingsTextSize),
          RadioGroup<TextSizePreference>(
            groupValue: settings.textSize,
            onChanged: (value) {
              if (value != null) controller.setTextSize(value);
            },
            child: Column(
              children: [
                RadioListTile(value: TextSizePreference.system, title: Text(l10n.textSizeSystem)),
                RadioListTile(value: TextSizePreference.large, title: Text(l10n.textSizeLarge)),
                RadioListTile(value: TextSizePreference.larger, title: Text(l10n.textSizeLarger)),
              ],
            ),
          ),
          LudixaSwitchRow(
            title: l10n.settingsReduceMotion,
            subtitle: l10n.settingsReduceMotionHint,
            value: settings.reduceMotion,
            onChanged: controller.setReduceMotion,
          ),
          LudixaSwitchRow(
            title: l10n.settingsHaptics,
            subtitle: l10n.settingsHapticsHint,
            value: settings.haptics,
            onChanged: controller.setHaptics,
          ),
          LudixaSwitchRow(
            title: l10n.settingsShowTimer,
            subtitle: l10n.settingsShowTimerHint,
            value: settings.showTimer,
            onChanged: controller.setShowTimer,
          ),
          LudixaSectionLabel(l10n.settingsGamesSection),
          for (final module in modules.values)
            LudixaListRow(
              leading: module.buildIcon(context),
              title: module.displayName(context),
              onTap: () => context.go(AppRoutes.gameSettings(module.id)),
            ),
          LudixaSectionLabel(l10n.settingsDataSection),
          LudixaListRow(
            title: l10n.settingsResetStats,
            subtitle: l10n.settingsResetStatsHint,
            onTap: () => _resetStats(context, ref, modules.values.toList()),
          ),
          LudixaListRow(
            title: l10n.settingsResetAll,
            subtitle: l10n.settingsResetAllHint,
            onTap: () => _resetAll(context, ref),
          ),
          LudixaSectionLabel(l10n.settingsAboutSection),
          LudixaListRow(title: l10n.settingsAdsContract, onTap: () => context.go(AppRoutes.adsContract)),
          LudixaListRow(title: l10n.settingsLicenses, onTap: () => context.go(AppRoutes.licenses)),
          LudixaListRow(title: l10n.settingsVersion, value: version),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsComponentCatalog, onTap: () => context.go(AppRoutes.catalog)),
          if (!environment.isProduction)
            LudixaListRow(title: l10n.settingsDevGames, onTap: () => context.go(AppRoutes.devGames)),
        ],
      ),
    );
  }

  /// Elegir un juego en la hoja es la confirmación: cada botón dice qué reinicia.
  Future<void> _resetStats(BuildContext context, WidgetRef ref, List<GameModule> modules) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showModalBottomSheet<GameModule>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => LudixaSheet(
        title: l10n.settingsResetStats,
        body: Text(l10n.settingsResetStatsBody, style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          for (final module in modules)
            LudixaButton(
              label: l10n.settingsResetStatsGame(module.displayName(context)),
              onPressed: () => Navigator.pop(context, module),
              variant: LudixaButtonVariant.secondary,
            ),
          LudixaButton(
            label: l10n.pauseCancel,
            onPressed: () => Navigator.pop(context),
            variant: LudixaButtonVariant.tertiary,
          ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return;
    final name = chosen.displayName(context);
    await ref.read(progressServiceProvider).resetStats(chosen.id);
    ref.read(progressRevisionProvider.notifier).bump();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsResetStatsDone(name))));
  }

  Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _ResetAllSheet(),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(progressServiceProvider).resetAll();
    ref.read(progressRevisionProvider.notifier).bump();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsResetAllDone)));
  }
}

/// Subtítulo de un grupo de opciones dentro de una sección.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
    child: Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.titleSmall)),
  );
}

/// Confirmación de "Reiniciar todo el progreso": se habilita al escribir la
/// palabra (BORRAR, DELETE), sin distinguir mayúsculas.
class _ResetAllSheet extends StatefulWidget {
  const _ResetAllSheet();

  @override
  State<_ResetAllSheet> createState() => _ResetAllSheetState();
}

class _ResetAllSheetState extends State<_ResetAllSheet> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = l10n.settingsResetAllWord;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListenableBuilder(
        listenable: _typed,
        builder: (context, _) {
          final matches = _typed.text.trim().toUpperCase() == word.toUpperCase();
          return LudixaSheet(
            title: l10n.settingsResetAllTitle,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsResetAllBody, style: text.bodyLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: _typed,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.settingsResetAllPrompt(word),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              LudixaButton(
                label: l10n.settingsResetAllConfirm,
                onPressed: matches ? () => Navigator.pop(context, true) : null,
                variant: LudixaButtonVariant.secondary,
              ),
              LudixaButton(
                label: l10n.pauseCancel,
                onPressed: () => Navigator.pop(context, false),
                variant: LudixaButtonVariant.tertiary,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ajustes propios de un juego, los mismos que se abren desde la pausa.
class GameSettingsPage extends ConsumerWidget {
  const GameSettingsPage({super.key, required this.game});

  final String game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref.watch(gameModulesProvider).values.where((m) => m.id.value == game).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(module?.displayName(context) ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: module?.buildSettings(context) ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Las 5 promesas del PRD sobre los anuncios, en lenguaje llano.
class AdsContractPage extends StatelessWidget {
  const AdsContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final promises = [
      l10n.adsPromiseMidGame,
      l10n.adsPromiseOnOpen,
      l10n.adsPromiseRewarded,
      l10n.adsPromiseAfterVideo,
      l10n.adsPromiseOffline,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAdsContract)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.adsContractIntro, style: text.bodyLarge),
          const SizedBox(height: 16),
          for (final promise in promises)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LudixaIcon(LudixaIcons.check, color: p.success),
                  const SizedBox(width: 12),
                  Expanded(child: Text(promise, style: text.bodyLarge)),
                ],
              ),
            ),
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
