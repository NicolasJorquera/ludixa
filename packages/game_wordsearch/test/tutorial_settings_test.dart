import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support.dart';

Finder _cell(int i) => find.bySemanticsLabel(RegExp('^Fila ${i ~/ 6 + 1}, columna ${i % 6 + 1},'));

Future<void> _drag(WidgetTester tester, int from, int to) async {
  final start = tester.getCenter(_cell(from));
  final end = tester.getCenter(_cell(to));
  final gesture = await tester.startGesture(start);
  for (var k = 1; k <= 6; k++) {
    await gesture.moveTo(Offset.lerp(start, end, k / 6)!);
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

void main() {
  group('tutorial', () {
    testWidgets('arrastrar, direcciones y lista; el error se explica sin castigo', (tester) async {
      // Un teléfono de 390 × 844: el pie "Saltar tutorial" ocupa su lugar.
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      var done = 0;
      await tester.pumpWidget(wrap(WordSearchTutorial(language: 'es', onDone: () => done++)));
      await _drag(tester, 0, 2);
      expect(find.text('Esa no es la palabra. Prueba de nuevo: no pasa nada.'), findsOneWidget);
      await _drag(tester, 13, 15);
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      await _drag(tester, 21, 7); // MAR al revés también vale
      expect(find.text('¡Bien hecho!'), findsOneWidget);
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      expect(find.text('PAN'), findsOneWidget);
      await _drag(tester, 16, 28);
      await tester.ensureVisible(find.text('Empezar a jugar'));
      await tester.tap(find.text('Empezar a jugar'));
      expect(done, 1);
    });

    testWidgets('en inglés usa palabras en inglés y "Saltar" siempre está', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        wrap(
          WordSearchTutorial(language: 'en', onDone: () => done++),
          locale: const Locale('en'),
        ),
      );
      expect(find.text('Find SUN, left to right.'), findsOneWidget);
      await tester.tap(find.text('Skip tutorial'));
      expect(done, 1);
    });
  });

  group('ajustes', () {
    testWidgets('selección e idioma se aplican y se guardan al instante', (tester) async {
      final store = InMemoryWordSearchSettingsStore();
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: SingleChildScrollView(child: WordSearchSettingsView(store: store)),
          ),
        ),
      );
      await tester.tap(find.text('Tocar inicio y final'));
      await tester.pump();
      expect(store.load().selection, SelectionMode.tap);
      await tester.tap(find.text('Inglés'));
      await tester.pump();
      expect(store.load().wordsLanguage, 'en');
      await tester.tap(find.text('El de la app'));
      await tester.pump();
      expect(store.load().wordsLanguage, isNull);
    });

    test('JSON de ida y vuelta; valores desconocidos vuelven al predeterminado', () {
      const custom = WordSearchSettings(selection: SelectionMode.tap, wordsLanguage: 'en');
      expect(WordSearchSettings.fromJson(custom.toJson()), custom);
      expect(
        WordSearchSettings.fromJson({'selection': 'telekinesis', 'wordsLanguage': 'fr'}),
        const WordSearchSettings(),
      );
    });

    testWidgets('idioma de las palabras: pedido > ajuste > idioma de la app', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(wrap(Builder(builder: (c) => (ctx = c, const SizedBox()).$2)));
      final free = PuzzleRequest(
        mode: PuzzleMode.free,
        difficulty: const Difficulty('easy'),
        seed: PuzzleSeed.fromKey('x'),
      );
      expect(WordSearchModule().wordsLanguageFor(ctx, free), 'es');
      expect(
        WordSearchModule(
          store: InMemoryWordSearchSettingsStore(const WordSearchSettings(wordsLanguage: 'en')),
        ).wordsLanguageFor(ctx, free),
        'en',
      );
      final withLanguage = PuzzleRequest(
        mode: PuzzleMode.free,
        difficulty: const Difficulty('easy'),
        seed: PuzzleSeed.fromKey('x'),
        wordsLanguage: 'es',
      );
      expect(
        WordSearchModule(
          store: InMemoryWordSearchSettingsStore(const WordSearchSettings(wordsLanguage: 'en')),
        ).wordsLanguageFor(ctx, withLanguage),
        'es',
      );
    });
  });
}
