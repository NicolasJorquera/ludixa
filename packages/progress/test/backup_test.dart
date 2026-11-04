import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

import 'support.dart';

/// Progreso variado: retos con racha y comodín, archivo, partidas libres,
/// una derrota, una partida en curso con su estado y reinicios.
Future<ProgressService> _seed(ProgressRepository repo) async {
  final clock = FakeClock(at('2026-10-01'));
  final service = ProgressService(repo, clock: clock);
  Future<void> record(SessionRecord s) async {
    clock.current = LocalNow(utc: s.completedAt!, offsetMinutes: s.startedAt.offsetMinutes);
    await service.recordResult(s);
  }

  for (final day in ['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-05']) {
    await record(session(startedAt: at(day, hour: 9)));
    await record(
      session(startedAt: at(day, hour: 10), game: GameId.wordSearch, difficulty: 'easy', themeIds: ['cocina']),
    );
  }
  await record(
    session(
      startedAt: at('2026-10-06', hour: 9),
      mode: PuzzleMode.archive,
      challengeDay: LocalDay(2026, 10, 4),
      game: GameId.minesweeper,
      difficulty: 'beginner',
      flagsPlaced: 0,
    ),
  );
  await record(
    session(
      startedAt: at('2026-10-06', hour: 11),
      mode: PuzzleMode.free,
      game: GameId.minesweeper,
      difficulty: 'expert',
      status: SessionStatus.lost,
    ),
  );
  await service.saveInProgress(
    SessionRecord(
      id: 'en-curso',
      game: GameId.sudoku,
      difficulty: const Difficulty('hard'),
      mode: PuzzleMode.free,
      startedAt: at('2026-10-06', hour: 12),
      puzzle: const {
        'givens': [5, 3, 0],
      },
      state: const {
        'values': [5, 3, 4],
        'notes': {
          '2': [1, 7],
        },
      },
      elapsed: const Duration(minutes: 3),
      freeHints: 1,
    ),
  );
  clock.current = at('2026-10-06', hour: 13);
  await service.resetStats(GameId.minesweeper, difficulty: const Difficulty('expert'));
  await service.resetStats(GameId.wordSearch);
  return service;
}

Map<String, Object?> _withoutDate(String json) => (jsonDecode(json) as Map<String, Object?>)..remove('exportedAt');

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  final repos = {
    'en memoria': InMemoryProgressRepository.new,
    'Drift': () => DriftProgressRepository(ProgressDatabase(NativeDatabase.memory())),
  };
  for (final MapEntry(key: name, value: create) in repos.entries) {
    group(name, () {
      test('exportar, borrar e importar deja exactamente el mismo progreso', () async {
        final service = await _seed(create());
        final before = await service.exportBackup();
        final data = ProgressBackup.parse(before);
        expect(data.sessions, hasLength(11));
        expect(data.completed, 9);
        await service.resetAll();
        expect(await service.repository.sessions(), isEmpty);
        await service.importBackup(data);
        expect(_withoutDate(await service.exportBackup()), _withoutDate(before));
        final resumed = (await service.repository.session('en-curso'))!;
        expect(resumed.state['notes'], {
          '2': [1, 7],
        });
        expect(resumed.freeHints, 1);
        expect((await service.streakStatus()).best, 3);
        expect(await service.repository.statsResetAt(GameId.minesweeper, const Difficulty('expert')), isNotNull);
      });

      test('importar reemplaza: no mezcla con el progreso que había', () async {
        final source = await _seed(create());
        final backup = ProgressBackup.parse(await source.exportBackup());
        final target = ProgressService(create(), clock: FakeClock(at('2026-11-01')));
        await target.recordResult(session(startedAt: at('2026-11-01'), game: GameId.sudoku, difficulty: 'expert'));
        await target.importBackup(backup);
        expect(_withoutDate(await target.exportBackup()), _withoutDate(await source.exportBackup()));
      });

      test('si algo falla a mitad de importar, queda el progreso de antes', () async {
        final service = await _seed(create());
        final before = await service.exportBackup();
        await expectLater(
          service.repository.transaction((store) async {
            await store.clear();
            throw StateError('disco lleno');
          }),
          throwsStateError,
        );
        expect(_withoutDate(await service.exportBackup()), _withoutDate(before));
      });
    });
  }

  group('archivos que no se importan', () {
    late String valid;

    setUpAll(() async => valid = await (await _seed(InMemoryProgressRepository())).exportBackup());

    BackupProblem problemOf(String text) {
      try {
        ProgressBackup.parse(text);
      } on BackupException catch (e) {
        return e.problem;
      }
      fail('se aceptó un archivo inválido');
    }

    String edit(void Function(Map<String, Object?> json) change) {
      final json = jsonDecode(valid) as Map<String, Object?>;
      change(json);
      return jsonEncode(json);
    }

    test('no es JSON', () => expect(problemOf('esto no es un respaldo'), BackupProblem.notJson));
    test('es JSON de otra cosa', () {
      expect(problemOf('{"nombre": "lista de compras"}'), BackupProblem.notLudixa);
      expect(problemOf('[1, 2, 3]'), BackupProblem.notLudixa);
    });
    test('es de una versión más nueva de la app', () {
      expect(problemOf(edit((j) => j['version'] = ProgressBackup.version + 1)), BackupProblem.newerVersion);
    });
    test('le faltan datos o están mal', () {
      expect(problemOf(edit((j) => j.remove('sessions'))), BackupProblem.corrupt);
      expect(problemOf(edit((j) => j['version'] = 'uno')), BackupProblem.corrupt);
      expect(problemOf(edit((j) => (j['sessions']! as List).add({'id': 'x'}))), BackupProblem.corrupt);
      expect(
        problemOf(edit((j) => ((j['sessions']! as List).first as Map)['status'] = 'quizás')),
        BackupProblem.corrupt,
      );
      expect(problemOf(edit((j) => (j['streak']! as Map)['best'] = '7')), BackupProblem.corrupt);
      expect(problemOf(edit((j) => ((j['days']! as List).first as Map)['day'] = '31/10/2026')), BackupProblem.corrupt);
    });
    test('un logro desconocido (de una versión futura compatible) se ignora', () {
      final data = ProgressBackup.parse(
        edit((j) => (j['achievements']! as Map)['logro_nuevo'] = '2026-10-01T00:00:00.000Z'),
      );
      expect(data.unlocked.keys.map((id) => id.key), isNot(contains('logro_nuevo')));
    });
  });
}
