import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludixa/app/app.dart';
import 'package:ludixa/app/environment.dart';

void main() {
  testWidgets('la app arranca en desarrollo con la marca DEV', (tester) async {
    await tester.pumpWidget(const LudixaApp(environment: AppEnvironment.dev));
    expect(find.text('Ludixa'), findsOneWidget);
    expect(find.byType(Banner), findsOneWidget);
  });

  testWidgets('en producción no hay marca DEV', (tester) async {
    await tester.pumpWidget(const LudixaApp(environment: AppEnvironment.prod));
    expect(find.text('Ludixa'), findsOneWidget);
    expect(find.byType(Banner), findsNothing);
  });
}
