import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_minesweeper/game_minesweeper.dart';

import 'support.dart';

Finder _cell(int i) => find.bySemanticsLabel(RegExp('^Fila ${i ~/ 5 + 1}, columna ${i % 5 + 1},'));

void main() {
  group('tutorial', () {
    testWidgets('recorre número, bandera y chord con errores explicados sin castigo', (tester) async {
      var done = 0;
      await tester.pumpWidget(wrap(MinesweeperTutorial(onDone: () => done++)));
      // Paso 1: tocar la bandera explica; una vecina cerrada es segura.
      await tester.tap(_cell(6));
      await tester.pump();
      expect(find.text('Esa celda tiene la bandera del 1: ahí está su mina.'), findsOneWidget);
      await tester.tap(_cell(18));
      await tester.pump();
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      // Paso 2: revelar la mina se explica; la pulsación larga la marca.
      await tester.tap(_cell(8));
      await tester.pump();
      expect(find.text('Cuidado: ahí está la mina. Márcala con bandera.'), findsOneWidget);
      await tester.longPress(_cell(8));
      await tester.pump();
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      // Paso 3: tocar el 1 abre sus vecinas.
      await tester.tap(_cell(12));
      await tester.pump();
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.ensureVisible(find.text('Empezar a jugar'));
      await tester.tap(find.text('Empezar a jugar'));
      expect(done, 1);
    });

    testWidgets('el modo Bandera también sirve en el paso 2 y "Saltar" siempre está', (tester) async {
      var done = 0;
      await tester.pumpWidget(wrap(MinesweeperTutorial(onDone: () => done++)));
      await tester.tap(_cell(7));
      await tester.pump();
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      await tester.tap(find.text('Bandera'));
      await tester.pump();
      await tester.tap(_cell(8));
      await tester.pump();
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.tap(find.text('Saltar tutorial'));
      expect(done, 1);
    });
  });

  group('ajustes', () {
    testWidgets('cada cambio se aplica y se guarda al instante', (tester) async {
      final store = InMemoryMinesweeperSettingsStore();
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: SingleChildScrollView(child: MinesweeperSettingsView(store: store)),
          ),
        ),
      );
      await tester.tap(find.text('Bandera'));
      await tester.pump();
      expect(store.load().tapAction, TapAction.flag);
      await tester.tap(find.text('Larga'));
      await tester.pump();
      expect(store.load().longPress, LongPressSpeed.long);
      await tester.tap(find.text('Abrir vecinas tocando un número'));
      await tester.pump();
      expect(store.load().chord, isFalse);
    });

    test('JSON de ida y vuelta; valores desconocidos vuelven al predeterminado', () {
      const custom = MinesweeperSettings(
        tapAction: TapAction.flag,
        longPress: LongPressSpeed.short,
        chord: false,
        longPressTipDone: true,
      );
      expect(MinesweeperSettings.fromJson(custom.toJson()), custom);
      expect(MinesweeperSettings.fromJson({'tapAction': 'dig', 'longPress': 3}), const MinesweeperSettings());
    });

    test('el toque por defecto sale de los ajustes', () {
      final c = freeController(
        store: InMemoryMinesweeperSettingsStore(const MinesweeperSettings(tapAction: TapAction.flag)),
      );
      expect(c.mode, TapAction.flag);
    });
  });
}
