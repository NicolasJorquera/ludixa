import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';

import 'support/test_app.dart';

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

String _appBarTitle(WidgetTester tester) {
  final titles = tester.widgetList<AppBar>(find.byType(AppBar)).where((bar) => bar.title is Text);
  return (titles.last.title! as Text).data!;
}

/// Desplaza la lista hasta que la fila quede entera a la vista y la toca.
Future<void> _tapListItem(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 200);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openLicenses(WidgetTester tester) => _tapListItem(tester, 'Licencias de código abierto');

void main() {
  group('entorno', () {
    testWidgets('en desarrollo muestra la marca DEV', (tester) async {
      await pumpLudixa(tester);
      expect(find.byType(Banner), findsOneWidget);
    });

    testWidgets('en producción no hay marca DEV ni pseudolocalización', (tester) async {
      await pumpLudixa(tester, environment: AppEnvironment.prod);
      expect(find.byType(Banner), findsNothing);
      await _tapTab(tester, 'Ajustes');
      expect(find.textContaining('Pseudolocalización'), findsNothing);
      expect(find.textContaining('Catálogo de componentes'), findsNothing);
    });

    testWidgets('en desarrollo Ajustes abre el catálogo de componentes', (tester) async {
      await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await _tapListItem(tester, 'Catálogo de componentes (desarrollo)');
      expect(find.byType(ComponentCatalog), findsOneWidget);
    });
  });

  group('navegación', () {
    testWidgets('las 4 pestañas llevan a su pantalla', (tester) async {
      await pumpLudixa(tester);
      expect(_appBarTitle(tester), 'Inicio');
      await _tapTab(tester, 'Reto');
      expect(_appBarTitle(tester), 'Reto de hoy');
      await _tapTab(tester, 'Progreso');
      expect(_appBarTitle(tester), 'Progreso');
      await _tapTab(tester, 'Ajustes');
      expect(_appBarTitle(tester), 'Ajustes');
    });

    testWidgets('cada pestaña conserva su pila al cambiar de pestaña', (tester) async {
      await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await _openLicenses(tester);
      expect(find.byType(LicensePage), findsOneWidget);

      await _tapTab(tester, 'Inicio');
      expect(find.byType(LicensePage), findsNothing);

      await _tapTab(tester, 'Ajustes');
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('tocar la pestaña activa vuelve a su raíz', (tester) async {
      await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await _openLicenses(tester);
      await _tapTab(tester, 'Ajustes');
      expect(find.byType(LicensePage), findsNothing);
      expect(_appBarTitle(tester), 'Ajustes');
    });

    testWidgets('atrás retrocede en la pestaña y desde la raíz de otra pestaña vuelve a Inicio', (tester) async {
      await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await _openLicenses(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsNothing);
      expect(_appBarTitle(tester), 'Ajustes');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_appBarTitle(tester), 'Inicio');
    });
  });

  group('ajustes en caliente', () {
    testWidgets('cambiar el tema se aplica al instante y se guarda', (tester) async {
      final repository = await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
      expect(Theme.of(tester.element(find.byType(NavigationBar))).brightness, Brightness.dark);
      expect(repository.stored.theme, ThemePreference.dark);
    });

    testWidgets('cambiar el idioma traduce la app sin reiniciar y se guarda', (tester) async {
      final repository = await pumpLudixa(tester);
      await _tapTab(tester, 'Ajustes');
      await _tapListItem(tester, 'English');

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
      expect(repository.stored.locale, const Locale('en'));
    });

    testWidgets('la paleta para daltonismo se aplica al instante y se guarda', (tester) async {
      final repository = await pumpLudixa(tester);
      PaletteVariant activeVariant() =>
          Theme.of(tester.element(find.byType(NavigationBar))).extension<LudixaColors>()!.variant;
      expect(activeVariant(), PaletteVariant.standard);

      await _tapTab(tester, 'Ajustes');
      await _tapListItem(tester, 'Paleta para daltonismo');

      expect(activeVariant(), PaletteVariant.colorblind);
      expect(repository.stored.colorblindPalette, isTrue);
    });

    testWidgets('la app usa las fuentes del sistema visual', (tester) async {
      await pumpLudixa(tester);
      final style = Theme.of(tester.element(find.byType(NavigationBar))).textTheme.bodyMedium!;
      expect(style.fontFamily, 'packages/design_system/Lexend');
    });

    testWidgets('los ajustes guardados se aplican al abrir la app', (tester) async {
      await pumpLudixa(
        tester,
        initial: const AppSettings(theme: ThemePreference.dark, locale: Locale('en')),
      );
      expect(find.text('Home'), findsWidgets);
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    });
  });
}
