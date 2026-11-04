import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

class FakeHost implements GameHost {
  @override
  bool get rewardedAvailable => false;

  FakeHost({this.free = 3, this.deny});

  int free;
  HintDenial? deny;
  final snapshots = <SessionSnapshot>[];
  final results = <GameResult>[];

  @override
  int get freeHintsLeft => free;

  @override
  Future<HintGrant> requestHint() async {
    if (deny != null) return HintDenied(deny!);
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
  Future<RescueOutcome> requestRescue() async => RescueOutcome.unavailable;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async => snapshots.add(snapshot);

  @override
  Future<void> reportResult(GameResult result) async => results.add(result);
}

/// Fácil del banco: siempre el mismo puzzle.
SudokuGame bankGame([SudokuDifficulty level = SudokuDifficulty.easy, int index = 0]) =>
    SudokuGame(SudokuBank.at(level, index));

Future<SudokuController> pumpGame(
  WidgetTester tester, {
  SudokuController? controller,
  FakeHost? host,
  SudokuSettings settings = const SudokuSettings(),
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
  bool disableAnimations = false,
  Locale locale = const Locale('es'),
  VoidCallback? onSolved,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = controller ?? SudokuController(game: bankGame(), host: host ?? FakeHost(), settings: settings);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, disableAnimations: disableAnimations),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLudixaTheme(brightness: brightness),
        locale: locale,
        supportedLocales: SudokuLocalizations.supportedLocales,
        localizationsDelegates: const [
          SudokuLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SudokuGamePage(controller: c, levelLabel: 'Fácil', onSolved: onSolved),
      ),
    ),
  );
  await tester.pump();
  return c;
}

/// Primera celda vacía (o la n-ésima).
int emptyCell(SudokuGame g, [int skip = 0]) {
  var seen = 0;
  for (var i = 0; i < 81; i++) {
    if (!g.isGiven(i) && seen++ == skip) return i;
  }
  throw StateError('sin celdas vacías');
}

Finder cell(int index) => find.bySemanticsLabel(RegExp('^Fila ${index ~/ 9 + 1}, columna ${index % 9 + 1},'));

Finder key(int digit) => find.bySemanticsLabel(RegExp('^$digit, (completo|queda|quedan)'));
