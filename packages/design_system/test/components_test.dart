import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light, double textScale = 1}) {
  return MaterialApp(
    theme: buildLudixaTheme(brightness: brightness),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child,
      ),
    ),
  );
}

Widget _inScaffold(Widget child) => Scaffold(
  body: Center(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('catálogo', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('se dibuja sin desbordes · ${brightness.name} · texto ${(scale * 100).round()}%', (tester) async {
          await tester.binding.setSurfaceSize(const Size(360, 780));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(_host(const ComponentCatalog(), brightness: brightness, textScale: scale));
          await tester.pumpAndSettle();
          // Recorre toda la lista: un desborde en cualquier componente lanza una excepción.
          await tester.drag(find.byType(ListView), const Offset(0, -4000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('cumple las guías de accesibilidad de Android y de etiquetas', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ComponentCatalog()));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('LudixaButton', () {
    testWidgets('sin acción queda desactivado', (tester) async {
      await tester.pumpWidget(_host(_inScaffold(const LudixaButton(label: 'Pista', onPressed: null))));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('la variante con video siempre muestra el icono de video', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          _inScaffold(
            LudixaButton(
              label: 'Ver video',
              variant: LudixaButtonVariant.rewarded,
              icon: const LudixaIcon(LudixaIcons.trophy),
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      expect(find.byWidgetPredicate((w) => w is LudixaIcon && w.icon == LudixaIcons.video), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is LudixaIcon && w.icon == LudixaIcons.trophy), findsNothing);
      await tester.tap(find.text('Ver video'));
      expect(taps, 1);
    });

    testWidgets('mide al menos 52 de alto', (tester) async {
      await tester.pumpWidget(_host(_inScaffold(LudixaButton(label: 'Empezar', onPressed: () {}))));
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(52));
    });
  });

  group('LudixaSegmentedControl', () {
    testWidgets('informa la opción elegida y la anuncia como seleccionada', (tester) async {
      final handle = tester.ensureSemantics();
      var selected = 'a';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => _inScaffold(
              LudixaSegmentedControl<String>(
                segments: const [
                  LudixaSegment(value: 'a', label: 'Revelar'),
                  LudixaSegment(value: 'b', label: 'Bandera'),
                ],
                selected: selected,
                onChanged: (v) => setState(() => selected = v),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Bandera'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(
        tester.getSemantics(find.text('Bandera')),
        matchesSemantics(
          label: 'Bandera',
          isButton: true,
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('filas', () {
    testWidgets('tocar cualquier parte de la fila cambia el interruptor', (tester) async {
      var value = false;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: LudixaSwitchRow(title: 'Sonidos', value: value, onChanged: (v) => setState(() => value = v)),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sonidos'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('otros', () {
    testWidgets('la barra de progreso anuncia su porcentaje', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(_inScaffold(const LudixaProgressBar(value: 0.8, semanticLabel: 'Hacia Bronce'))));
      expect(find.bySemanticsLabel('Hacia Bronce'), findsWidgets);
      final node = tester.getSemantics(find.byType(LudixaProgressBar));
      expect(node.value, '80%');
      handle.dispose();
    });

    testWidgets('la hoja inferior se abre con su título y acciones', (tester) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => _inScaffold(
              TextButton(
                onPressed: () => showLudixaSheet<void>(
                  context,
                  builder: (context) => LudixaSheet(
                    title: '¿Una pista más?',
                    actions: [LudixaButton(label: 'Ahora no', onPressed: () => Navigator.pop(context))],
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('¿Una pista más?'), findsOneWidget);
      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();
      expect(find.text('¿Una pista más?'), findsNothing);
    });

    testWidgets('el aviso muestra el mensaje', (tester) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => _inScaffold(
              TextButton(onPressed: () => showLudixaToast(context, 'Sin conexión'), child: const Text('avisar')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('avisar'));
      await tester.pump();
      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('el chip de cifra se anuncia con su frase completa', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          _inScaffold(
            LudixaStatChip(icon: LudixaIcons.streak, value: '12', semanticLabel: 'Racha de 12 días', onTap: () {}),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Racha de 12 días'), findsOneWidget);
      expect(tester.getSize(find.byType(LudixaStatChip)).height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('con etiqueta propia, la tarjeta y el chip se activan desde el lector de pantalla', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = <String>[];
      await tester.pumpWidget(
        _host(
          _inScaffold(
            Column(
              children: [
                LudixaCard(semanticLabel: 'Tarjeta', onTap: () => taps.add('tarjeta'), child: const Text('x')),
                LudixaStatChip(
                  icon: LudixaIcons.streak,
                  value: '12',
                  semanticLabel: 'Chip',
                  onTap: () => taps.add('chip'),
                ),
              ],
            ),
          ),
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Tarjeta'));
      tester.semantics.tap(find.semantics.byLabel('Chip'));
      expect(taps, ['tarjeta', 'chip']);
      handle.dispose();
    });
  });
}
