import 'package:integration_test/integration_test_driver.dart';

/// Guarda lo que informa `integration_test/perf_test.dart` en
/// `build/perf.json` (fotogramas y tiempos de generación).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data != null) await writeResponseData(data, testOutputFilename: 'perf', destinationDirectory: 'build');
  },
);
