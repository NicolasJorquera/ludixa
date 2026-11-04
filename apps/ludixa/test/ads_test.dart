import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/features/ads/ads_controller.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:monetization/monetization.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

/// AdMob falso: cuenta lo que se muestra.
final class _FakeAds implements AdService {
  bool interstitialReady = true;
  RewardedOutcome rewarded = RewardedOutcome.earned;
  int interstitials = 0;
  int rewardedShown = 0;
  int preloads = 0;

  @override
  void preload() => preloads++;

  @override
  Future<bool> showInterstitial() async {
    if (!interstitialReady) return false;
    interstitials++;
    return true;
  }

  @override
  Future<RewardedOutcome> showRewarded() async {
    if (rewarded != RewardedOutcome.unavailable) rewardedShown++;
    return rewarded;
  }

  @override
  Future<LoadedBanner?> loadBanner(double width) async => LoadedBanner(
    widget: const SizedBox(key: Key('banner'), height: 50),
    dispose: () {},
  );
}

final class _FixedClock implements Clock {
  @override
  LocalNow now() => LocalNow(utc: DateTime.utc(2026, 11, 3, 13), offsetMinutes: -180);
}

/// Alguien que ya cumple todo para un intersticial al salir del próximo
/// Resultado: segunda sesión en adelante, puzzles y tiempo de sobra.
AdPolicyStore _veteranStore() => InMemoryAdPolicyStore()
  ..save(
    const AdPolicyState(sessions: 3, puzzlesTotal: 10, puzzlesSinceLast: 2, activePlaySinceLast: Duration(minutes: 10)),
  );

Future<(_FakeAds, ProviderContainer)> _pump(WidgetTester tester, {bool consent = true, AdPolicyStore? store}) async {
  tester.view.physicalSize = const Size(390, 1400) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ads = _FakeAds();
  await pumpLudixa(
    tester,
    consent: FakeConsent(allowed: consent),
    overrides: [
      clockProvider.overrideWithValue(_FixedClock()),
      adMobFactoryProvider.overrideWithValue((_) => ads),
      adPolicyStoreProvider.overrideWithValue(store ?? _veteranStore()),
      adClockProvider.overrideWithValue(() => DateTime(2026, 11, 3, 10)),
    ],
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
  // Abrir la app reinicia los 4 minutos: se juega un rato en esta sesión.
  container.read(adsControllerProvider).played(const Duration(minutes: 5));
  return (ads, container);
}

/// Resuelve el reto de Sudoku de hoy hasta la pantalla de Resultado.
Future<void> _solveDailySudoku(WidgetTester tester, ProviderContainer container) async {
  final context = tester.element(find.byType(Scaffold).first);
  final module = container.read(gameModulesProvider)[GameId.sudoku]!;
  unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
  await tester.pumpAndSettle();
  final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
  for (var i = 0; i < 81; i++) {
    if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
      c.tapCell(i);
      c.tapDigit(c.game.puzzle.solution[i]);
    }
  }
  await tester.pumpAndSettle();
  expect(find.text('¡Resuelto!'), findsOneWidget);
}

void main() {
  testWidgets('al abrir la app no hay intersticial; el banner va al final de Inicio con su rótulo', (tester) async {
    final (ads, _) = await _pump(tester);
    expect(ads.interstitials, 0);
    expect(ads.preloads, 1);
    await tester.scrollUntilVisible(find.byKey(const Key('banner')), 300);
    expect(find.text('ANUNCIO'), findsOneWidget);
  });

  testWidgets('abrir la app cuenta como sesión aunque no se juegue', (tester) async {
    final store = InMemoryAdPolicyStore();
    await pumpLudixa(tester, overrides: [adPolicyStoreProvider.overrideWithValue(store)]);
    expect(store.load().sessions, 1);
  });

  testWidgets('sin consentimiento no hay banner ni anuncios', (tester) async {
    final (ads, container) = await _pump(tester, consent: false);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('banner')), findsNothing);
    await _solveDailySudoku(tester, container);
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect((ads.interstitials, ads.preloads), (0, 0));
  });

  testWidgets('durante la partida no hay anuncios; el intersticial solo al salir del Resultado', (tester) async {
    final (ads, container) = await _pump(tester);
    await _solveDailySudoku(tester, container);
    expect(ads.interstitials, 0);
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(ads.interstitials, 1);
    expect(find.text('Inicio'), findsWidgets);
    expect(container.read(adPolicyStoreProvider).load().puzzlesSinceLast, 0);
  });

  testWidgets('después de un video con recompensa en ese puzzle no hay intersticial', (tester) async {
    final (ads, container) = await _pump(tester);
    final context = tester.element(find.byType(Scaffold).first);
    final module = container.read(gameModulesProvider)[GameId.sudoku]!;
    unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
    await tester.pumpAndSettle();
    expect(await container.read(adsControllerProvider).showRewarded(), RewardedOutcome.earned);
    final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
        c.tapCell(i);
        c.tapDigit(c.game.puzzle.solution[i]);
      }
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect((ads.rewardedShown, ads.interstitials), (1, 0));
  });

  testWidgets('un video cerrado antes de terminar no entrega nada, pero igual evita el intersticial', (tester) async {
    final (ads, container) = await _pump(tester);
    ads.rewarded = RewardedOutcome.dismissed;
    expect(await container.read(adsControllerProvider).showRewarded(), RewardedOutcome.dismissed);
    expect(container.read(adPolicyProvider).decide(AdExit.result), AdDecision.afterRewarded);
  });

  testWidgets('si el intersticial no está cargado no se espera: se sigue de inmediato', (tester) async {
    final (ads, container) = await _pump(tester);
    ads.interstitialReady = false;
    await _solveDailySudoku(tester, container);
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(ads.interstitials, 0);
    expect(find.text('Inicio'), findsWidgets);
    expect(container.read(adPolicyStoreProvider).load().puzzlesSinceLast, greaterThan(0));
  });

  testWidgets('salir de una partida sin terminarla no muestra anuncios pero suma el tiempo jugado', (tester) async {
    final store = _veteranStore();
    final (ads, container) = await _pump(tester, store: store);
    final before = store.load().activePlaySinceLast;
    final context = tester.element(find.byType(Scaffold).first);
    final module = container.read(gameModulesProvider)[GameId.sudoku]!;
    unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
    await tester.pumpAndSettle();
    final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
    final empty = [for (var i = 0; i < 81; i++) i].where((i) => !c.game.isGiven(i)).toList();
    c.tapCell(empty[0]);
    c.tapDigit(1);
    await tester.pump(const Duration(seconds: 5));
    // El tiempo llega con las instantáneas: cuenta hasta la última jugada.
    c.tapCell(empty[1]);
    c.tapDigit(2);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(ads.interstitials, 0);
    expect(store.load().activePlaySinceLast, greaterThan(before));
  });

  group('identificadores', () {
    const real = AdUnits(banner: 'b', interstitial: 'i', rewarded: 'r');

    test('dev usa siempre los de prueba, aunque reciba los de producción', () {
      expect(adUnitsFor(AppEnvironment.dev, production: real), AdUnits.test);
    });

    test('prod usa los suyos; sin ellos queda sin anuncios, nunca con los de prueba', () {
      expect(adUnitsFor(AppEnvironment.prod, production: real), real);
      expect(
        adUnitsFor(
          AppEnvironment.prod,
          production: const AdUnits(banner: '', interstitial: '', rewarded: ''),
        ),
        isNull,
      );
    });
  });
}
