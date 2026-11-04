import 'dart:convert';
import 'dart:typed_data';

import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';
import 'package:ludixa/features/settings/presentation/backup_actions.dart';
import 'package:ludixa/features/settings/presentation/settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

Future<(InMemorySettingsRepository, InMemoryProgressRepository)> _pumpSettings(
  WidgetTester tester, {
  AppSettings initial = const AppSettings(),
  Future<void> Function(ProgressService service)? seed,
  BackupFiles? files,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  PackageInfo.setMockInitialValues(
    appName: 'Ludixa',
    packageName: 'io.github.nicolasjorquera.ludixa',
    version: '1.0.0',
    buildNumber: '7',
    buildSignature: '',
  );
  final progress = InMemoryProgressRepository();
  await seed?.call(ProgressService(progress));
  final settings = await pumpLudixa(
    tester,
    initial: initial,
    progress: progress,
    overrides: [backupFilesProvider.overrideWithValue(files ?? _FakeFiles())],
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/settings');
  await tester.pumpAndSettle();
  return (settings, progress);
}

/// Selector de archivos en memoria: guarda lo exportado y abre lo que se le dé.
final class _FakeFiles implements BackupFiles {
  _FakeFiles({this.toOpen});

  Uint8List? toOpen;
  final saved = <String, Uint8List>{};

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> open() async => toOpen;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

SessionRecord _won() => SessionRecord(
  id: 's1',
  game: GameId.sudoku,
  difficulty: const Difficulty('easy'),
  mode: PuzzleMode.free,
  startedAt: LocalNow(utc: DateTime.utc(2026, 11, 3, 12), offsetMinutes: -180),
).finish(status: SessionStatus.won, elapsed: const Duration(minutes: 5), completedAt: DateTime.utc(2026, 11, 3, 12, 5));

void main() {
  testWidgets('las 4 secciones del PRD, con la versión instalada', (tester) async {
    await _pumpSettings(tester);
    for (final section in ['GENERAL', 'JUEGOS', 'DATOS Y PRIVACIDAD', 'INFORMACIÓN']) {
      await tester.scrollUntilVisible(find.text(section), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(section), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('1.0.0 (7)'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('1.0.0 (7)'), findsOneWidget);
  });

  testWidgets('el tamaño de texto se aplica al instante sobre el del sistema y se guarda', (tester) async {
    final (settings, _) = await _pumpSettings(tester);
    await _tap(tester, find.text('Más grande'));
    final scaler = MediaQuery.textScalerOf(tester.element(find.byType(SettingsPage)));
    expect(scaler.scale(10), closeTo(13, 0.001));
    expect(settings.stored.textSize, TextSizePreference.larger);
  });

  testWidgets('los interruptores son switch reales y se aplican al instante', (tester) async {
    final semantics = tester.ensureSemantics();
    final (settings, _) = await _pumpSettings(tester);
    final reduce = find.text('Reducir animaciones');
    await _tap(tester, reduce);
    expect(MediaQuery.disableAnimationsOf(tester.element(find.byType(SettingsPage))), isTrue);
    expect(settings.stored.reduceMotion, isTrue);
    expect(
      tester.getSemantics(find.ancestor(of: reduce, matching: find.byType(SwitchListTile))),
      isSemantics(
        label: 'Reducir animaciones\nQuita los efectos de movimiento aunque el sistema los tenga activos',
        hasToggledState: true,
        isToggled: true,
      ),
    );

    await _tap(tester, find.text('Vibración'));
    await _tap(tester, find.text('Mostrar el temporizador'));
    expect(settings.stored.showTimer, isFalse);
    expect(settings.stored.haptics, isFalse);
    // Los juegos lo reciben al cargar sus preferencias.
    final container = ProviderScope.containerOf(tester.element(find.byType(SettingsPage)));
    final sudoku = container.read(gameModulesProvider)[GameId.sudoku]! as SudokuModule;
    expect(sudoku.store.load().showTimer, isFalse);
    expect(sudoku.store.load().haptics, isFalse);
    semantics.dispose();
  });

  testWidgets('cada juego abre sus ajustes', (tester) async {
    await _pumpSettings(tester);
    await _tap(tester, find.widgetWithText(ListTile, 'Sudoku'));
    expect(find.byType(GameSettingsPage), findsOneWidget);
    expect(find.byType(SudokuSettingsView), findsOneWidget);
  });

  testWidgets('reiniciar las estadísticas de un juego', (tester) async {
    final (_, progress) = await _pumpSettings(tester, seed: (service) => service.recordResult(_won()));
    await _tap(tester, find.text('Reiniciar estadísticas'));
    await tester.tap(find.text('Reiniciar Sudoku'));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas de Sudoku reiniciadas'), findsOneWidget);
    expect(await progress.statsResetAt(GameId.sudoku), isNotNull);
    expect(await progress.sessions(), hasLength(1));
  });

  testWidgets('reiniciar todo exige escribir BORRAR', (tester) async {
    final (_, progress) = await _pumpSettings(tester, seed: (service) => service.recordResult(_won()));
    await _tap(tester, find.text('Reiniciar todo el progreso'));
    expect(find.text('¿Borrar todo tu progreso?'), findsOneWidget);
    LudixaButtonFinder.expectEnabled(tester, 'Borrar todo', isFalse);

    await tester.enterText(find.byType(TextField), 'borra');
    await tester.pump();
    LudixaButtonFinder.expectEnabled(tester, 'Borrar todo', isFalse);

    await tester.enterText(find.byType(TextField), 'borrar ');
    await tester.pump();
    LudixaButtonFinder.expectEnabled(tester, 'Borrar todo', isTrue);
    await tester.tap(find.text('Borrar todo'));
    await tester.pumpAndSettle();
    expect(find.text('Se borró tu progreso'), findsOneWidget);
    expect(await progress.sessions(), isEmpty);
  });

  testWidgets('cancelar no borra nada', (tester) async {
    final (_, progress) = await _pumpSettings(tester, seed: (service) => service.recordResult(_won()));
    await _tap(tester, find.text('Reiniciar todo el progreso'));
    await tester.enterText(find.byType(TextField), 'BORRAR');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await progress.sessions(), hasLength(1));
  });

  group('respaldo', () {
    testWidgets('exportar guarda un JSON de Ludixa con la fecha en el nombre', (tester) async {
      final files = _FakeFiles();
      await _pumpSettings(tester, seed: (service) => service.recordResult(_won()), files: files);
      await _tap(tester, find.text('Exportar progreso'));
      expect(find.text('Progreso exportado'), findsOneWidget);
      final (name, bytes) = (files.saved.keys.single, files.saved.values.single);
      expect(name, matches(RegExp(r'^ludixa-progreso-\d{4}-\d{2}-\d{2}\.json$')));
      expect(ProgressBackup.parse(utf8.decode(bytes)).sessions.single.id, 's1');
    });

    testWidgets('importar muestra qué trae, pide confirmar y reemplaza', (tester) async {
      final source = ProgressService(InMemoryProgressRepository());
      await source.recordResult(_won());
      final files = _FakeFiles(toOpen: utf8.encode(await source.exportBackup()));
      final (_, progress) = await _pumpSettings(tester, files: files);
      await _tap(tester, find.text('Importar progreso'));
      expect(find.text('¿Reemplazar tu progreso?'), findsOneWidget);
      expect(find.textContaining('1 partida (1 completada)'), findsOneWidget);
      await tester.tap(find.text('Reemplazar'));
      await tester.pumpAndSettle();
      expect(find.text('Progreso importado'), findsOneWidget);
      expect((await progress.sessions()).single.id, 's1');
    });

    testWidgets('cancelar la importación no cambia nada', (tester) async {
      final source = ProgressService(InMemoryProgressRepository());
      await source.recordResult(_won());
      final files = _FakeFiles(toOpen: utf8.encode(await source.exportBackup()));
      final (_, progress) = await _pumpSettings(tester, files: files);
      await _tap(tester, find.text('Importar progreso'));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(await progress.sessions(), isEmpty);
    });

    testWidgets('un archivo que no es un respaldo se rechaza con un mensaje claro', (tester) async {
      final files = _FakeFiles(toOpen: utf8.encode('lista de compras'));
      final (_, progress) = await _pumpSettings(tester, seed: (service) => service.recordResult(_won()), files: files);
      await _tap(tester, find.text('Importar progreso'));
      expect(find.text('No se puede importar'), findsOneWidget);
      expect(find.textContaining('no es un respaldo de Ludixa'), findsOneWidget);
      expect(await progress.sessions(), hasLength(1));
    });

    testWidgets('un respaldo de una versión más nueva pide actualizar', (tester) async {
      final files = _FakeFiles(toOpen: utf8.encode('{"format": "ludixa-progress", "version": 99}'));
      await _pumpSettings(tester, files: files);
      await _tap(tester, find.text('Importar progreso'));
      expect(find.textContaining('Actualiza la app'), findsOneWidget);
    });
  });

  testWidgets('contrato de anuncios: las 5 promesas', (tester) async {
    await _pumpSettings(tester);
    await _tap(tester, find.text('Contrato de anuncios'));
    expect(find.byType(AdsContractPage), findsOneWidget);
    expect(find.text('Nunca verás un anuncio en mitad de una partida.'), findsOneWidget);
    expect(find.text('Todos los juegos funcionan sin internet.'), findsOneWidget);
  });

  testWidgets('en inglés la palabra es DELETE', (tester) async {
    await _pumpSettings(tester, initial: const AppSettings(locale: Locale('en')));
    await _tap(tester, find.text('Reset all progress'));
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
  });

  group('goldens', skip: goldensSkip, () {
    testWidgets('ajustes', (tester) async {
      await _pumpSettings(tester);
      await expectLater(find.byType(SettingsPage), matchesGoldenFile('goldens/settings.png'));
    });

    testWidgets('contrato de anuncios', (tester) async {
      await _pumpSettings(tester);
      await _tap(tester, find.text('Contrato de anuncios'));
      await expectLater(find.byType(AdsContractPage), matchesGoldenFile('goldens/ads_contract.png'));
    });
  });
}

/// El botón deshabilitado de Ludixa no tiene `onPressed`.
abstract final class LudixaButtonFinder {
  static void expectEnabled(WidgetTester tester, String label, Matcher matcher) {
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>()).first,
    );
    expect(button.enabled, matcher);
  }
}
