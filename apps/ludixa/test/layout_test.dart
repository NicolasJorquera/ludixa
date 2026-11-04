import 'dart:io';

import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/screens.dart';

/// Anchos del criterio de aceptación (dp) con un alto de teléfono o tablet.
const _sizes = [Size(320, 568), Size(390, 844), Size(600, 960), Size(840, 1180)];
const _scales = [1.0, 2.0];

/// Desplaza todo lo desplazable hasta el final para que se construya y se
/// mida también lo que empieza fuera de la pantalla.
Future<void> _scrollThrough(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    final scrollables = find.byType(Scrollable).hitTestable();
    if (scrollables.evaluate().isEmpty) return;
    final before = tester.state<ScrollableState>(scrollables.first).position.pixels;
    await tester.drag(scrollables.first, const Offset(0, -500), warnIfMissed: false);
    await tester.pumpAndSettle();
    if (tester.state<ScrollableState>(scrollables.first).position.pixels == before) return;
  }
}

/// Con LAYOUT_SHOTS=carpeta y --update-goldens guarda capturas de cada
/// pantalla (arriba y al final) para revisarlas a ojo. No son goldens.
Future<void> _shot(WidgetTester tester, Size size, double scale, String name, String part) async {
  final dir = Platform.environment['LAYOUT_SHOTS'];
  if (dir == null) return;
  final index = screens.keys.toList().indexOf(name).toString().padLeft(2, '0');
  final file = Uri.file('$dir/${size.width.toInt()}_${(scale * 100).toInt()}/$index$part.png');
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
}

void main() {
  for (final size in _sizes) {
    for (final scale in _scales) {
      testWidgets('sin cortes a ${size.width.toInt()} dp con texto al ${(scale * 100).toInt()} %', (tester) async {
        final failures = <String>[];
        for (final name in screens.keys) {
          tester.view.physicalSize = size * 3;
          tester.view.devicePixelRatio = 3;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          final previous = FlutterError.onError;
          final errors = <String>[];
          FlutterError.onError = (details) {
            errors.add(details.exceptionAsString().split('\n').first);
            if (Platform.environment['LAYOUT_DEBUG'] != null) {
              debugPrint('DETAIL $name ${size.width} $scale\n${details.toString().split('\n').take(40).join('\n')}');
            }
          };
          try {
            await openScreen(tester, name);
            await _shot(tester, size, scale, name, 'a');
            await _scrollThrough(tester);
            await _shot(tester, size, scale, name, 'b');
          } on Object catch (e) {
            errors.add('no se pudo abrir: ${e.toString().split('\n').first}');
          } finally {
            FlutterError.onError = previous;
          }
          if (errors.isNotEmpty) failures.add('$name: ${errors.toSet().join(' | ')}');
          await tester.pumpWidget(const SizedBox.shrink());
        }
        tester.view.reset();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        expect(failures, isEmpty, reason: failures.join('\n'));
      });
    }
  }

  group('goldens', skip: goldensSkip, () {
    Future<void> golden(WidgetTester tester, String screen, Size size, double scale, String file) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openScreen(tester, screen);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/layout/$file.png'));
    }

    for (final size in _sizes) {
      final w = size.width.toInt();
      testWidgets('inicio a $w dp', (tester) => golden(tester, 'inicio', size, 1, 'home_$w'));
      testWidgets('sudoku a $w dp', (tester) => golden(tester, 'partida de sudoku', size, 1, 'sudoku_$w'));
    }
    testWidgets(
      'inicio a 390 dp con texto al 200 %',
      (tester) => golden(tester, 'inicio', _sizes[1], 2, 'home_390_200'),
    );
    testWidgets(
      'progreso a 390 dp con texto al 200 %',
      (tester) => golden(tester, 'progreso', _sizes[1], 2, 'progress_390_200'),
    );
  });
}
