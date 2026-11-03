import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) => MaterialApp(
  theme: buildLudixaTheme(brightness: Brightness.light),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('todos los iconos se dibujan sin errores', (tester) async {
    await tester.pumpWidget(_host(Wrap(children: [for (final icon in LudixaIcons.values) LudixaIcon(icon)])));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsNWidgets(LudixaIcons.values.length));
  });

  test('cada icono es un SVG de 24 con trazo en currentColor', () {
    for (final icon in LudixaIcons.values) {
      expect(icon.svg, contains('viewBox="0 0 24 24"'), reason: icon.name);
      expect(icon.svg, contains('stroke="currentColor"'), reason: icon.name);
      expect(icon.svg, isNot(contains('#')), reason: '${icon.name} no debe fijar colores');
    }
  });

  testWidgets('toma tamaño y color del IconTheme', (tester) async {
    await tester.pumpWidget(
      _host(
        const IconTheme(
          data: IconThemeData(size: 32, color: Color(0xFFC4501B)),
          child: LudixaIcon(LudixaIcons.mine),
        ),
      ),
    );
    expect(tester.getSize(find.byType(LudixaIcon)), const Size(32, 32));
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect((svg.bytesLoader as SvgStringLoader).theme!.currentColor, const Color(0xFFC4501B));
  });

  testWidgets('sin etiqueta es decorativo; con etiqueta se anuncia como imagen', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LudixaIcon(LudixaIcons.hint),
            LudixaIcon(LudixaIcons.flagFilled, semanticLabel: 'Bandera'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Bandera'), findsOneWidget);
    expect(tester.getSemantics(find.byType(LudixaIcon).first).label, isEmpty);
    handle.dispose();
  });

  testWidgets('las flechas se reflejan en idiomas de derecha a izquierda', (tester) async {
    await tester.pumpWidget(_host(const LudixaIcon(LudixaIcons.back), direction: TextDirection.rtl));
    expect(find.byType(Transform), findsWidgets);
    await tester.pumpWidget(_host(const LudixaIcon(LudixaIcons.sudoku), direction: TextDirection.rtl));
    expect(find.descendant(of: find.byType(LudixaIcon), matching: find.byType(Transform)), findsNothing);
  });
}
