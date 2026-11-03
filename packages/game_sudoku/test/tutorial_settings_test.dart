import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLudixaTheme(brightness: Brightness.light),
      locale: const Locale('es'),
      supportedLocales: SudokuLocalizations.supportedLocales,
      localizationsDelegates: const [
        SudokuLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
  await tester.pump();
}

Future<void> _press(WidgetTester tester, int digit) async {
  await tester.tap(find.widgetWithText(OutlinedButton, '$digit'));
  await tester.pump();
}

void main() {
  group('tutorial', () {
    testWidgets('un error se explica sin castigo y se puede volver a intentar', (tester) async {
      await _pump(tester, SudokuTutorial(onDone: () {}));
      expect(find.text('Paso 1 de 3'), findsOneWidget);
      await _press(tester, 2);
      expect(find.text('El 2 ya está en esta fila. Prueba con otro.'), findsOneWidget);
      expect(find.text('Siguiente'), findsNothing);
      await _press(tester, 3);
      expect(find.text('¡Bien! El 3 es el único que falta.'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('recorre fila, columna y caja y termina', (tester) async {
      var done = 0;
      await _pump(tester, SudokuTutorial(onDone: () => done++));
      for (final (wrong, right, message) in [(1, 3, 'fila'), (4, 2, 'columna'), (1, 3, 'caja')]) {
        await _press(tester, wrong);
        expect(find.text('El $wrong ya está en esta $message. Prueba con otro.'), findsOneWidget);
        await _press(tester, right);
        await tester.tap(find.byType(LudixaButton));
        await tester.pump();
      }
      expect(done, 1);
    });

    testWidgets('"Saltar tutorial" está en cada paso', (tester) async {
      var done = 0;
      await _pump(tester, SudokuTutorial(onDone: () => done++));
      await _press(tester, 3);
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      await tester.tap(find.text('Saltar tutorial'));
      expect(done, 1);
    });

    testWidgets('el texto del tutorial es de al menos 16 sp', (tester) async {
      await _pump(tester, SudokuTutorial(onDone: () {}));
      final ask = tester.widget<Text>(find.text('¿Qué número va en la celda marcada?'));
      expect(ask.style!.fontSize, greaterThanOrEqualTo(16));
    });
  });

  group('ajustes', () {
    testWidgets('cada cambio se aplica y se guarda al instante', (tester) async {
      final store = InMemorySudokuSettingsStore();
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(child: SudokuSettingsView(store: store)),
        ),
      );
      await tester.tap(find.text('Número primero'));
      await tester.pump();
      expect(store.load().inputMode, SudokuInputMode.numberFirst);
      await tester.tap(find.text('Contra la solución'));
      await tester.pump();
      expect(store.load().errorMode, SudokuErrorMode.solution);
      await tester.tap(find.text('Borrar notas al colocar un número'));
      await tester.pump();
      expect(store.load().removeNotesOnPlace, isFalse);
    });

    test('JSON de ida y vuelta; valores desconocidos vuelven al predeterminado', () {
      const custom = SudokuSettings(
        inputMode: SudokuInputMode.numberFirst,
        errorMode: SudokuErrorMode.none,
        removeNotesOnPlace: false,
        highlightSameNumber: false,
      );
      expect(SudokuSettings.fromJson(custom.toJson()), custom);
      expect(SudokuSettings.fromJson({'inputMode': 'telepathy', 'errorMode': 7}), const SudokuSettings());
    });

    test('el módulo abre la partida con los ajustes guardados', () {
      final store = InMemorySudokuSettingsStore(const SudokuSettings(errorMode: SudokuErrorMode.none));
      expect(SudokuModule(store: store).store.load().errorMode, SudokuErrorMode.none);
    });
  });
}
