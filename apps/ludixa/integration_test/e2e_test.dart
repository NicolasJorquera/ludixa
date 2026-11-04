import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/bootstrap.dart';

import 'support.dart';

/// Prueba de punta a punta (H7-04) en un dispositivo, con anuncios de prueba:
///
/// ```bash
/// flutter test integration_test/e2e_test.dart --flavor dev \
///   --dart-define=ADS_QA=true -d <dispositivo>
/// ```
///
/// Primer arranque, tutorial, reto de Sudoku completo, Resultado y el
/// intersticial de prueba al salir. Borra los datos de la versión dev.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('primer arranque, tutorial, reto, Resultado e intersticial', (tester) async {
    final semantics = tester.ensureSemantics();
    // Una sesión anterior ya registrada: los intersticiales nunca aparecen en
    // la primera. ADS_QA quita el mínimo de puzzles y de tiempo de juego.
    await resetApp(adPolicy: {'sessions': 1});
    await bootstrap(AppEnvironment.dev);
    await tester.pumpAndSettle();

    // Primer arranque: Inicio invita a empezar el reto de hoy.
    await pumpUntil(tester, find.text('Empieza con el reto de hoy'));

    // Tutorial: la primera partida libre de Sudoku pasa antes por él.
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Sudoku, ')));
    await tester.pumpAndSettle();
    await pumpUntil(tester, find.textContaining('Empezar ·'));
    await tester.tap(find.textContaining('Empezar ·'));
    await pumpUntil(tester, find.widgetWithText(OutlinedButton, '3'));
    for (final digit in [3, 2, 3]) {
      await tester.tap(find.widgetWithText(OutlinedButton, '$digit'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(RegExp('^(Siguiente|Empezar a jugar)')));
      await tester.pumpAndSettle();
    }
    // Termina el tutorial y empieza la partida libre; se sale sin jugarla.
    await pumpUntil(tester, find.bySemanticsLabel(RegExp(r'^Fila 1, columna 1, ')));
    await tester.tap(find.byTooltip('Volver'));
    await pumpUntil(tester, find.bySemanticsLabel(RegExp(r'^Reto\n')));

    // Reto de hoy: Sudoku completo.
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Reto\n')));
    await tester.pumpAndSettle();
    await pumpUntil(tester, find.bySemanticsLabel('Jugar Sudoku'));
    await tester.tap(find.bySemanticsLabel('Jugar Sudoku'));
    await pumpUntil(tester, find.bySemanticsLabel(RegExp(r'^Fila 1, columna 1, ')));
    await solveSudoku(tester);

    // Resultado del reto.
    await pumpUntil(tester, find.bySemanticsLabel(RegExp('Reto: 1 de 3')));

    // Intersticial de prueba al salir del Resultado: tapa la app, que deja de
    // estar en primer plano. Se cierra fuera de la prueba (es nativo).
    final lifecycle = <AppLifecycleState>[];
    final listener = AppLifecycleListener(onStateChange: lifecycle.add);
    await tester.tap(find.text('Volver al inicio'));
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (!lifecycle.contains(AppLifecycleState.inactive) && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    listener.dispose();
    expect(lifecycle, contains(AppLifecycleState.inactive), reason: 'el intersticial de prueba no apareció');
    semantics.dispose();
  });
}
