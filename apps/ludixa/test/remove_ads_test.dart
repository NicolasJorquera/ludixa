import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/ads/ads_controller.dart';
import 'package:ludixa/features/ads/remove_ads.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:monetization/monetization.dart';
import 'package:monetization/testing.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

/// AdMob falso: cuenta lo que se muestra.
final class _FakeAds implements AdService {
  int interstitials = 0;
  int rewardedShown = 0;

  @override
  void preload() {}

  @override
  bool get rewardedReady => true;

  @override
  Future<bool> showInterstitial() async {
    interstitials++;
    return true;
  }

  @override
  Future<RewardedOutcome> showRewarded() async {
    rewardedShown++;
    return RewardedOutcome.earned;
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
/// Resultado.
AdPolicyStore _veteranStore() => InMemoryAdPolicyStore()
  ..save(
    const AdPolicyState(sessions: 3, puzzlesTotal: 10, puzzlesSinceLast: 2, activePlaySinceLast: Duration(minutes: 10)),
  );

final class _App {
  _App(this.ads, this.container, this.consent, this.sdk);

  final _FakeAds ads;
  final ProviderContainer container;
  final FakeConsent consent;
  final FakeAdsSdk sdk;

  bool get adsRemoved => container.read(adsRemovedProvider);
  bool get adMobActive => container.read(adServiceProvider) is _FakeAds;
}

/// Compra única «Sin anuncios» en la app, con un Play Billing falso.
void main() {
  late FakeInAppPurchase play;

  setUp(() => play = FakeInAppPurchase());
  tearDown(() => play.close());

  Future<_App> pump(WidgetTester tester, {bool savedOwned = false, bool privacyRequired = false}) async {
    tester.view.physicalSize = const Size(390, 1400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final ads = _FakeAds();
    final consent = FakeConsent(allowed: true, privacyRequired: privacyRequired);
    final sdk = FakeAdsSdk();
    await pumpLudixa(
      tester,
      consent: consent,
      adsSdk: sdk,
      iap: play,
      removeAdsStore: InMemoryRemoveAdsStore(savedOwned),
      overrides: [
        clockProvider.overrideWithValue(_FixedClock()),
        adMobFactoryProvider.overrideWithValue((_) => ads),
        adPolicyStoreProvider.overrideWithValue(_veteranStore()),
        adClockProvider.overrideWithValue(() => DateTime(2026, 11, 3, 10)),
      ],
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    container.read(adsControllerProvider).played(const Duration(minutes: 5));
    return _App(ads, container, consent, sdk);
  }

  Future<void> go(WidgetTester tester, String location) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> showCard(WidgetTester tester) async {
    await go(tester, '/settings');
    final card = find.byKey(const Key('remove-ads-card'));
    await tester.scrollUntilVisible(card, 300);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
  }

  Future<void> bannerAtHome(WidgetTester tester, Matcher matcher) async {
    await go(tester, '/');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('banner')), matcher);
  }

  Future<SudokuController> openSudoku(WidgetTester tester, ProviderContainer container) async {
    final context = tester.element(find.byType(Scaffold).first);
    final module = container.read(gameModulesProvider)[GameId.sudoku]!;
    unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
    await tester.pumpAndSettle();
    return tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
  }

  Future<void> solve(WidgetTester tester, SudokuController c) async {
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
        c.tapCell(i);
        c.tapDigit(c.game.puzzle.solution[i]);
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('¡Resuelto!'), findsOneWidget);
  }

  testWidgets('comprar en Ajustes: precio de Play, se reconoce, y sin banners ni intersticial', (tester) async {
    final app = await pump(tester);
    await bannerAtHome(tester, findsOneWidget);

    await showCard(tester);
    expect(find.text('Quita los anuncios con un pago único'), findsOneWidget);
    expect(find.text(r'Quitar anuncios · US$2.99'), findsOneWidget);
    await tester.tap(find.byKey(const Key('remove-ads-buy')));
    await tester.pumpAndSettle();
    expect(find.text('Sin anuncios. ¡Gracias por apoyar Ludixa!'), findsOneWidget);
    expect(find.byKey(const Key('remove-ads-buy')), findsNothing);
    expect(find.byKey(const Key('remove-ads-restore')), findsNothing);
    expect(play.completed, [removeAdsProductId]);
    expect(app.adsRemoved, isTrue);
    expect(app.adMobActive, isFalse);

    await bannerAtHome(tester, findsNothing);
    final c = await openSudoku(tester, app.container);
    await solve(tester, c);
    expect(find.byKey(const Key('banner')), findsNothing, reason: 'tampoco en el Resultado');
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(app.ads.interstitials, 0);
  });

  testWidgets('con la compra: las pistas extra no piden video, con el mismo límite', (tester) async {
    play.owned = true;
    final app = await pump(tester, savedOwned: true);
    final c = await openSudoku(tester, app.container);
    for (var i = 0; i < 5; i++) {
      unawaited(c.hint());
      await tester.pumpAndSettle();
      expect(find.text('Pista extra'), findsNothing);
      c.hintClose();
      await tester.pumpAndSettle();
    }
    expect((c.freeHints, c.rewardedHints, c.hintsExhausted), (2, 3, false));
    unawaited(c.hint());
    await tester.pumpAndSettle();
    expect(c.hintsExhausted, isTrue, reason: 'mismo límite por puzzle que con videos');
    expect(app.ads.rewardedShown, 0);
  });

  testWidgets('instalación nueva con la compra en Play: se restaura sola al abrir', (tester) async {
    play
      ..owned = true
      ..acknowledged = true;
    final app = await pump(tester);
    expect(app.adsRemoved, isTrue);
    expect(app.adMobActive, isFalse);
    await bannerAtHome(tester, findsNothing);
    await showCard(tester);
    expect(find.text('Sin anuncios. ¡Gracias por apoyar Ludixa!'), findsOneWidget);
  });

  testWidgets('quien ya compró: ni consentimiento ni SDK de anuncios ni opciones de privacidad', (tester) async {
    play
      ..owned = true
      ..acknowledged = true;
    final app = await pump(tester, savedOwned: true, privacyRequired: true);
    expect((app.consent.gathered, app.sdk.initialized), (0, 0));
    await go(tester, '/settings');
    expect(find.text('Opciones de privacidad'), findsNothing);
  });

  testWidgets('«Restaurar compra»: sin compra lo dice; con compra en la cuenta, la restaura', (tester) async {
    final app = await pump(tester);
    await showCard(tester);
    await tester.tap(find.byKey(const Key('remove-ads-restore')));
    await tester.pumpAndSettle();
    expect(find.text('Esta cuenta de Google Play no tiene la compra.'), findsOneWidget);
    expect(app.adsRemoved, isFalse);

    play
      ..owned = true
      ..acknowledged = true;
    await tester.tap(find.byKey(const Key('remove-ads-restore')));
    await tester.pumpAndSettle();
    expect(find.text('Compra restaurada: ya no verás anuncios.'), findsOneWidget);
    expect(app.adsRemoved, isTrue);
  });

  testWidgets('compra pendiente: siguen los anuncios hasta que Play la confirma', (tester) async {
    play.buyResult = FakeBuyResult.pending;
    final app = await pump(tester);
    await showCard(tester);
    await tester.tap(find.byKey(const Key('remove-ads-buy')));
    await tester.pumpAndSettle();
    expect(find.text('Compra pendiente. Los anuncios siguen hasta que Google Play la confirme.'), findsOneWidget);
    expect(tester.widget<LudixaButton>(find.byKey(const Key('remove-ads-buy'))).onPressed, isNull);
    expect(app.adsRemoved, isFalse);
    expect(app.adMobActive, isTrue);

    play.confirmPending();
    await tester.pumpAndSettle();
    expect(find.text('Sin anuncios. ¡Gracias por apoyar Ludixa!'), findsOneWidget);
    expect(app.adMobActive, isFalse);
  });

  testWidgets('cancelada o con error: nada cambia y se dice', (tester) async {
    play.buyResult = FakeBuyResult.canceled;
    final app = await pump(tester);
    await showCard(tester);
    await tester.tap(find.byKey(const Key('remove-ads-buy')));
    await tester.pumpAndSettle();
    expect(find.text('Compra cancelada.'), findsOneWidget);

    play.buyResult = FakeBuyResult.error;
    await tester.tap(find.byKey(const Key('remove-ads-buy')));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo completar la compra. Inténtalo de nuevo.'), findsOneWidget);
    expect(app.adsRemoved, isFalse);
    expect(app.adMobActive, isTrue);
  });

  testWidgets('producto inexistente o sin Play: sin precio y «no disponible», sin romper nada', (tester) async {
    play.productExists = false;
    final app = await pump(tester);
    await showCard(tester);
    expect(find.text('Quitar anuncios'), findsOneWidget);
    expect(find.textContaining('US\$'), findsNothing);
    await tester.tap(find.byKey(const Key('remove-ads-buy')));
    await tester.pumpAndSettle();
    expect(
      find.text('Google Play no está disponible ahora. Revisa tu conexión e inténtalo más tarde.'),
      findsOneWidget,
    );
    expect(app.adMobActive, isTrue);
  });

  testWidgets('revocación: si Play dice que la cuenta no la tiene, vuelven los anuncios', (tester) async {
    final app = await pump(tester, savedOwned: true);
    expect(app.adsRemoved, isFalse);
    expect(app.adMobActive, isTrue);
    expect(app.sdk.initialized, 1);
    await bannerAtHome(tester, findsOneWidget);
  });

  testWidgets('sin red: quien compró sigue sin anuncios', (tester) async {
    play
      ..available = false
      ..failRestore = true;
    final app = await pump(tester, savedOwned: true);
    expect(app.adsRemoved, isTrue);
    expect(app.adMobActive, isFalse);
    expect(app.sdk.initialized, 0);
    await bannerAtHome(tester, findsNothing);
  });

  testWidgets('sin compra todo sigue igual: consentimiento, SDK y banner', (tester) async {
    final app = await pump(tester);
    expect((app.consent.gathered, app.sdk.initialized), (1, 1));
    expect(app.adMobActive, isTrue);
    await bannerAtHome(tester, findsOneWidget);
  });
}
