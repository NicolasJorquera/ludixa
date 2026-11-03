import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _dims = GridDimensions(columns: 9, rows: 9);

Widget _host(Widget child, {double width = 360, double textScale = 1}) => MaterialApp(
  theme: buildLudixaTheme(brightness: Brightness.light),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

Widget _cell(BuildContext context, int index, double extent) => ColoredBox(
  color: const Color(0xFFFFFFFF),
  child: Center(child: Text('$index')),
);

Offset _centerOf(WidgetTester tester, int index) => tester.getCenter(find.text('$index'));

void main() {
  group('GridDimensions', () {
    test('convierte entre índice y fila/columna', () {
      const d = GridDimensions(columns: 16, rows: 30);
      expect(d.cellCount, 480);
      expect(d.indexOf(2, 5), 37);
      expect(d.rowOf(37), 2);
      expect(d.columnOf(37), 5);
    });
  });

  group('PuzzleGrid', () {
    testWidgets('ajusta el tamaño de celda al ancho, sin depender de la escala de texto', (tester) async {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          _host(
            PuzzleGrid(dimensions: _dims, cellBuilder: _cell, semanticLabelFor: (i) => 'celda $i'),
            textScale: scale,
          ),
        );
        expect(tester.getSize(find.byType(PuzzleGrid)), const Size(360, 360));
      }
    });

    testWidgets('el tamaño de celda nunca supera el máximo', (tester) async {
      await tester.pumpWidget(
        _host(
          PuzzleGrid(dimensions: _dims, cellBuilder: _cell, semanticLabelFor: (i) => '', maxCellExtent: 30),
          width: 600,
        ),
      );
      // Celdas de 30 y tablero de 270, centrado en los 600 disponibles.
      final cell = tester.getRect(find.ancestor(of: find.text('0'), matching: find.byType(ColoredBox)).first);
      expect(cell.size, const Size(30, 30));
      expect(cell.left, 165);
    });

    testWidgets('el toque y la pulsación larga llegan con el índice correcto', (tester) async {
      final taps = <int>[];
      final longPresses = <int>[];
      await tester.pumpWidget(
        _host(
          PuzzleGrid(
            dimensions: _dims,
            cellBuilder: _cell,
            semanticLabelFor: (i) => '',
            onCellTap: taps.add,
            onCellLongPress: longPresses.add,
          ),
        ),
      );
      await tester.tapAt(_centerOf(tester, 40));
      await tester.tapAt(_centerOf(tester, 80));
      await tester.longPressAt(_centerOf(tester, 3));
      expect(taps, [40, 80]);
      expect(longPresses, [3]);
    });

    testWidgets('un toque en la separación entre celdas no cuenta', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        _host(
          PuzzleGrid(dimensions: _dims, gap: 6, cellBuilder: _cell, semanticLabelFor: (i) => '', onCellTap: taps.add),
        ),
      );
      final first = tester.getRect(find.text('0').first);
      final cellRect = tester.getRect(find.ancestor(of: find.text('0'), matching: find.byType(ColoredBox)).first);
      await tester.tapAt(Offset(cellRect.right + 3, first.center.dy));
      expect(taps, isEmpty);
    });

    testWidgets('el arrastre informa inicio, cada celda nueva y fin', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        _host(
          PuzzleGrid(
            dimensions: _dims,
            cellBuilder: _cell,
            semanticLabelFor: (i) => '',
            onDragStart: (i) => events.add('start $i'),
            onDragUpdate: (i) => events.add('over $i'),
            onDragEnd: () => events.add('end'),
          ),
        ),
      );
      // Diagonal de la celda 0 a la 30 (fila 3, columna 3).
      final gesture = await tester.startGesture(_centerOf(tester, 0));
      for (final index in [10, 20, 30]) {
        await gesture.moveTo(_centerOf(tester, index));
      }
      await gesture.up();
      expect(events, ['start 0', 'over 10', 'over 20', 'over 30', 'end']);
    });

    testWidgets('cada celda se anuncia y se puede tocar con TalkBack', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = <int>[];
      await tester.pumpWidget(
        _host(
          PuzzleGrid(
            dimensions: _dims,
            semanticLabel: 'Tablero',
            cellBuilder: (context, i, extent) => const SizedBox.expand(),
            semanticLabelFor: (i) => 'Fila ${_dims.rowOf(i) + 1}, columna ${_dims.columnOf(i) + 1}',
            onCellTap: taps.add,
            onCellLongPress: (_) {},
          ),
        ),
      );
      final cell = find.bySemanticsLabel('Fila 5, columna 5');
      expect(cell, findsOneWidget);
      expect(
        tester.getSemantics(cell),
        matchesSemantics(label: 'Fila 5, columna 5', isButton: true, hasTapAction: true, hasLongPressAction: true),
      );
      tester.semantics.tap(find.semantics.byLabel('Fila 5, columna 5'));
      expect(taps, [40]);
      expect(find.bySemanticsLabel('Tablero'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('construye un tablero Experto de 16×30 sin errores', (tester) async {
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            child: PuzzleGrid(
              dimensions: const GridDimensions(columns: 16, rows: 30),
              gap: 2,
              cellBuilder: (context, i, extent) => const ColoredBox(color: Color(0xFFCFD7E3)),
              semanticLabelFor: (i) => '',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(ColoredBox), findsAtLeastNWidgets(480));
    });
  });

  group('ZoomableBoard', () {
    testWidgets('toggleZoom alterna entre ajustar al ancho y celdas cómodas', (tester) async {
      final key = GlobalKey<ZoomableBoardState>();
      await tester.pumpWidget(
        _host(
          SizedBox(
            height: 400,
            child: ZoomableBoard(
              key: key,
              boardSize: const Size(352, 660),
              cellExtent: 20,
              child: const ColoredBox(color: Color(0xFFCFD7E3)),
            ),
          ),
        ),
      );
      expect(key.currentState!.scale, 1);
      key.currentState!.toggleZoom();
      await tester.pumpAndSettle();
      // 36 / 20 = 1,8: las celdas quedan en 36 px.
      expect(key.currentState!.scale, closeTo(1.8, 0.001));
      key.currentState!.toggleZoom();
      await tester.pumpAndSettle();
      expect(key.currentState!.scale, 1);
    });

    test('el zoom es al menos 1,6× y como máximo maxScale', () {
      const child = SizedBox();
      expect(const ZoomableBoard(boardSize: Size.zero, cellExtent: 40, child: child).zoomedScale, 1.6);
      expect(const ZoomableBoard(boardSize: Size.zero, cellExtent: 22, child: child).zoomedScale, closeTo(1.636, 0.01));
      expect(const ZoomableBoard(boardSize: Size.zero, cellExtent: 5, child: child).zoomedScale, 3);
    });
  });

  group('LudixaAdSlot', () {
    testWidgets('sin anuncio no ocupa espacio ni muestra el rótulo', (tester) async {
      await tester.pumpWidget(_host(const LudixaAdSlot(label: 'Anuncio', ad: null)));
      expect(find.text('ANUNCIO'), findsNothing);
      expect(tester.getSize(find.byType(LudixaAdSlot)).height, 0);
    });

    testWidgets('con anuncio lleva el rótulo y 24 de separación arriba y abajo', (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(key: Key('arriba'), height: 10),
              LudixaAdSlot(
                label: 'Anuncio',
                ad: SizedBox(key: Key('ad'), width: 320, height: 50),
              ),
              SizedBox(key: Key('abajo'), height: 10),
            ],
          ),
        ),
      );
      expect(find.text('ANUNCIO'), findsOneWidget);
      final above = tester.getRect(find.byKey(const Key('arriba')));
      final label = tester.getRect(find.text('ANUNCIO'));
      final ad = tester.getRect(find.byKey(const Key('ad')));
      final below = tester.getRect(find.byKey(const Key('abajo')));
      expect(label.top - above.bottom, greaterThanOrEqualTo(LudixaAdSlot.minSeparation));
      expect(below.top - ad.bottom, greaterThanOrEqualTo(LudixaAdSlot.minSeparation));
    });
  });

  group('LudixaHaptics', () {
    testWidgets('solo vibra si está activado', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await LudixaHaptics.flag(enabled: false);
      expect(calls, isEmpty);
      await LudixaHaptics.flag(enabled: true);
      await LudixaHaptics.select(enabled: true);
      expect(calls, ['HapticFeedbackType.lightImpact', 'HapticFeedbackType.selectionClick']);
    });
  });
}
