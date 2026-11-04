/// Progreso del jugador: racha, calendario del reto, logros, maestría y
/// estadísticas. El almacenamiento es una interfaz: hay una versión en
/// memoria (pruebas y H4) y la base Drift de H5 (esquema en H5-01, el
/// repositorio que la usa en H5-02).
///
/// Dart puro: no depende de Flutter.
library;

export 'src/data/drift/database.dart' show ProgressDatabase;
export 'src/data/drift/drift_progress_repository.dart';
export 'src/data/in_memory_progress_repository.dart';
export 'src/domain/achievements.dart';
export 'src/domain/clock.dart';
export 'src/domain/daily_day.dart';
export 'src/domain/progress_repository.dart';
export 'src/domain/progress_service.dart';
export 'src/domain/session_record.dart';
export 'src/domain/stats.dart';
export 'src/domain/streak.dart';
