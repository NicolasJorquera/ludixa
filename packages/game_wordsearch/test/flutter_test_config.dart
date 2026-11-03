import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes reales del sistema visual para que los goldens se
/// parezcan a la app (sin esto, Flutter usa una fuente de cajas).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (family, file) in const [
    ('packages/design_system/Lexend', 'Lexend-Variable.ttf'),
    ('packages/design_system/BricolageGrotesque', 'BricolageGrotesque-Variable.ttf'),
  ]) {
    final bytes = File('../design_system/assets/fonts/$file').readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
  await testMain();
}
