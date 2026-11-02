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

Future<void> _openLicenses(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('Licencias de código abierto'), 200);
  await tester.tap(find.text('Licencias de código abierto'));
  await tester.pumpAndSettle();
}

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
      await tester.scrollUntilVisible(find.text('English'), 200);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
      expect(repository.stored.locale, const Locale('en'));
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
