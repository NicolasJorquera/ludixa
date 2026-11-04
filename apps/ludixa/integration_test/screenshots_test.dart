import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/bootstrap.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:ludixa/features/settings/application/settings_controller.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support.dart';

/// Capturas para la ficha de Play (H7-04), en producción (sin la cinta DEV ni
/// anuncios), en español e inglés y en claro y oscuro:
///
/// ```bash
/// adb shell wm size 1080x1920   # Play pide que el lado largo no pase del doble del corto
/// flutter drive --flavor prod -t integration_test/screenshots_test.dart \
///   --driver test_driver/screenshots_driver.dart -d <dispositivo>
/// adb shell wm size reset
/// ```
///
/// Las imágenes quedan en `docs/ficha/capturas/`. Borra los datos de la
/// versión de producción en ese dispositivo.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capturas de la ficha', (tester) async {
    final semantics = tester.ensureSemantics();
    await resetApp();
    await bootstrap(AppEnvironment.prod);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    await _seedWeek(container);
    await binding.convertFlutterSurfaceToImage();

    BuildContext context() => tester.element(find.byType(Scaffold).first);
    Future<void> go(String location) async {
      GoRouter.of(context()).go(location);
      await tester.pumpAndSettle();
    }

    Future<void> openGame(GameId game, String level) async {
      final module = container.read(gameModulesProvider)[game]!;
      final request = PuzzleRequest(
        mode: PuzzleMode.free,
        difficulty: Difficulty(level),
        seed: PuzzleSeed.fromKey('ficha|${game.value}'),
      );
      unawaited(GameFlow.play(context(), module, request));
      await pumpUntil(tester, find.byType(PuzzleGrid));
    }

    Future<void> close() async {
      Navigator.of(tester.element(find.byType(Scaffold).last), rootNavigator: true).popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
    }

    for (final (language, labels) in [('es', BoardLabels.es), ('en', BoardLabels.en)]) {
      for (final (themeName, theme) in [('claro', ThemePreference.light), ('oscuro', ThemePreference.dark)]) {
        final settings = container.read(settingsProvider.notifier);
        await settings.setLocale(Locale(language));
        await settings.setTheme(theme);
        await tester.pumpAndSettle();
        var n = 0;
        Future<void> shot(String screen) async {
          await tester.pumpAndSettle();
          await binding.takeScreenshot('${(++n).toString().padLeft(2, '0')}_${screen}_${themeName}_$language');
        }

        await go('/');
        await shot('inicio');
        await go('/daily');
        await shot('reto');

        await openGame(GameId.sudoku, 'medium');
        await solveSudoku(tester, labels: labels, limit: 18);
        await shot('sudoku');
        await close();

        await openGame(GameId.minesweeper, 'intermediate');
        // Por su etiqueta: el centro geométrico de 16 columnas cae entre dos celdas.
        await tester.tap(find.bySemanticsLabel(RegExp('^${labels.cell(8, 8)}')).first);
        // El tablero se genera en otro isolate: se espera a ver un número.
        await pumpUntil(tester, find.bySemanticsLabel(RegExp('^${labels.row} \\d+, ${labels.column} \\d+, [1-8]')));
        await shot('buscaminas');
        await close();

        await openGame(GameId.wordSearch, 'medium');
        await _findWords(tester, labels, 3);
        await shot('sopa');
        await close();

        await go('/progress');
        await shot('progreso');
      }
    }
    semantics.dispose();
  });
}

/// Una semana de juego: los 3 retos de los últimos 6 días y algunas
/// partidas libres, para que Inicio, Reto y Progreso muestren racha y cifras.
Future<void> _seedWeek(ProviderContainer container) async {
  final service = container.read(progressServiceProvider);
  final modules = container.read(gameModulesProvider);
  final now = DateTime.now();
  var id = 0;
  for (var back = 6; back >= 1; back--) {
    final date = now.subtract(Duration(days: back));
    final day = LocalNow.fromDateTime(date).day;
    for (final (i, game) in dailyGames.indexed) {
      final start = LocalNow.fromDateTime(DateTime(date.year, date.month, date.day, 20, i * 10));
      final elapsed = Duration(minutes: 3 + (back + i) % 5, seconds: 7 * back + 11 * i);
      final session = SessionRecord(
        id: 'ficha-${id++}',
        game: game,
        difficulty: modules[game]!.dailySpec(day).difficulty,
        mode: PuzzleMode.daily,
        startedAt: start,
        challengeDay: day,
      ).finish(status: SessionStatus.won, elapsed: elapsed, completedAt: start.utc.add(elapsed));
      await service.recordResult(session);
    }
  }
  container.read(progressRevisionProvider.notifier).bump();
}

/// Encuentra [count] palabras de la Sopa arrastrando de la primera a la
/// última letra. Las letras y las palabras se leen de la semántica.
Future<void> _findWords(WidgetTester tester, BoardLabels labels, int count) async {
  final cell = RegExp('^${labels.row} (\\d+), ${labels.column} (\\d+), (\\S+)');
  final letters = <(int, int), String>{};
  for (final node in find.semantics.byLabel(cell).evaluate()) {
    final m = cell.firstMatch(node.label)!;
    letters[(int.parse(m[1]!), int.parse(m[2]!))] = m[3]!;
  }
  final size = letters.keys.map((k) => k.$1).reduce((a, b) => a > b ? a : b);
  final pending = RegExp('^(.+), ${labels.pending}\$');
  final words = [for (final node in find.semantics.byLabel(pending).evaluate()) pending.firstMatch(node.label)![1]!];
  final board = tester.getRect(find.byType(PuzzleGrid));
  Offset at((int, int) rc) =>
      Offset(board.left + (rc.$2 - .5) * board.width / size, board.top + (rc.$1 - .5) * board.height / size);
  var found = 0;
  for (final word in words) {
    if (found == count) break;
    final chars = _fold(word).split('');
    for (final (start, end) in _placements(chars, letters, size)) {
      await tester.timedDragFrom(at(start), at(end) - at(start), const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      if (find.semantics.byLabel(pending).evaluate().length < words.length - found) {
        found++;
        break;
      }
    }
  }
}

String _fold(String word) => word
    .toUpperCase()
    .replaceAll('Á', 'A')
    .replaceAll('É', 'E')
    .replaceAll('Í', 'I')
    .replaceAll('Ó', 'O')
    .replaceAll(RegExp('[ÚÜ]'), 'U');

Iterable<((int, int), (int, int))> _placements(List<String> chars, Map<(int, int), String> letters, int size) sync* {
  for (var row = 1; row <= size; row++) {
    for (var column = 1; column <= size; column++) {
      for (final (dr, dc) in const [(0, 1), (1, 0), (1, 1), (1, -1), (0, -1), (-1, 0), (-1, -1), (-1, 1)]) {
        var ok = true;
        for (var i = 0; i < chars.length && ok; i++) {
          ok = letters[(row + dr * i, column + dc * i)] == chars[i];
        }
        if (ok) yield ((row, column), (row + dr * (chars.length - 1), column + dc * (chars.length - 1)));
      }
    }
  }
}
