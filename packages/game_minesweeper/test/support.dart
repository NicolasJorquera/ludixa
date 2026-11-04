import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';

class FakeHost implements GameHost {
  /// Hay un video para ofrecer (sin conexión, false).
  bool videoReady = true;

  @override
  bool get rewardedAvailable => videoReady;

  FakeHost({this.free = 3, this.rescueAnswer = RescueOutcome.granted});

  int free;
  RescueOutcome rescueAnswer;
  final snapshots = <SessionSnapshot>[];
  final results = <GameResult>[];

  @override
  int get freeHintsLeft => free;

  @override
  Future<HintGrant> requestHint() async {
    if (free == 0) return const HintDenied(HintDenial.limitReached);
    free--;
    return const HintGranted(HintSource.free);
  }

  int pauses = 0;
  PauseChoice pauseAnswer = PauseChoice.resume;
  int playAgainRequests = 0;

  /// Si no es null, la pausa queda abierta hasta completarla.
  Completer<PauseChoice>? pauseGate;

  @override
  Future<PauseChoice> showPause() {
    pauses++;
    return pauseGate?.future ?? Future.value(pauseAnswer);
  }

  @override
  void playAgain() => playAgainRequests++;

  @override
  Future<RescueOutcome> requestRescue() async => rescueAnswer;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async => snapshots.add(snapshot);

  @override
  Future<void> reportResult(GameResult result) async => results.add(result);
}

/// Generación síncrona para las pruebas (en la app va en un isolate).
Future<MineLayout> syncGenerate(BoardSpec spec, String key, int start) async =>
    MinesweeperGame.generateBoard(spec, key, start);

MinesweeperController freeController({
  BoardSpec spec = BoardSpec.beginner,
  FakeHost? host,
  MinesweeperSettingsStore? store,
}) => MinesweeperController(
  game: MinesweeperGame.free(spec: spec, seed: PuzzleSeed.fromKey('prueba')),
  host: host ?? FakeHost(),
  store: store ?? InMemoryMinesweeperSettingsStore(),
  generate: syncGenerate,
);

Widget wrap(Widget child, {Brightness brightness = Brightness.light, Locale locale = const Locale('es')}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLudixaTheme(brightness: brightness),
      locale: locale,
      supportedLocales: MinesLocalizations.supportedLocales,
      localizationsDelegates: const [
        MinesLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

Future<MinesweeperController> pumpGame(
  WidgetTester tester, {
  MinesweeperController? controller,
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
  VoidCallback? onWon,
  VoidCallback? onNewBoard,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = controller ?? freeController();
  await tester.pumpWidget(
    wrap(
      MinesweeperPage(controller: c, levelLabel: 'Principiante', onWon: onWon, onNewBoard: onNewBoard),
      brightness: brightness,
    ),
  );
  await tester.pump();
  return c;
}

Finder cellAt(MinesweeperController c, int index) =>
    find.bySemanticsLabel(RegExp('^Fila ${index ~/ c.game.spec.width + 1}, columna ${index % c.game.spec.width + 1},'));

Set<int> minesOf(MinesweeperController c) => {...(c.game.toJson()['mines']! as List).cast<int>()};
