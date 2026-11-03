import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('en', 'XA'), Locale('es')];

  /// Nombre de la app.
  ///
  /// In es, this message translates to:
  /// **'Ludixa'**
  String get appName;

  /// Pestaña de la portada.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// Pestaña del reto diario.
  ///
  /// In es, this message translates to:
  /// **'Reto'**
  String get navDaily;

  /// Pestaña de estadísticas y logros.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get navProgress;

  /// Pestaña de ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Etiqueta de accesibilidad de la barra de pestañas.
  ///
  /// In es, this message translates to:
  /// **'Navegación principal'**
  String get navigationLabel;

  /// Título de la portada.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// Título de la pantalla del reto diario.
  ///
  /// In es, this message translates to:
  /// **'Reto de hoy'**
  String get dailyTitle;

  /// Título de la pantalla de progreso.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressTitle;

  /// Título de la pantalla de ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Aviso provisional en pantallas que aún no están construidas.
  ///
  /// In es, this message translates to:
  /// **'Esta pantalla llega en una próxima versión de desarrollo.'**
  String get comingSoon;

  /// Encabezado de la sección de tema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsThemeSection;

  /// Opción de tema que sigue al sistema.
  ///
  /// In es, this message translates to:
  /// **'Como el sistema'**
  String get themeSystem;

  /// Opción de tema claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Opción de tema oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// Interruptor de la paleta que no depende de distinguir rojo y verde.
  ///
  /// In es, this message translates to:
  /// **'Paleta para daltonismo'**
  String get colorblindPalette;

  /// Explicación breve bajo el interruptor de daltonismo.
  ///
  /// In es, this message translates to:
  /// **'Cambia rojos y verdes por naranjas y azules'**
  String get colorblindPaletteHint;

  /// Encabezado de la sección de idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageSection;

  /// Opción de idioma que sigue al sistema.
  ///
  /// In es, this message translates to:
  /// **'Como el sistema'**
  String get languageSystem;

  /// Nombre del español, siempre en español.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Nombre del inglés, siempre en inglés.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Idioma de prueba que alarga y acentúa los textos. Solo en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Pseudolocalización (desarrollo)'**
  String get languagePseudo;

  /// Encabezado de la sección de información.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsAboutSection;

  /// Entrada al catálogo del sistema visual. Solo en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de componentes (desarrollo)'**
  String get settingsComponentCatalog;

  /// Entrada que abre las licencias de las dependencias.
  ///
  /// In es, this message translates to:
  /// **'Licencias de código abierto'**
  String get settingsLicenses;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'XA':
            return AppLocalizationsEnXa();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
