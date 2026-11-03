import 'dart:convert';
import 'dart:typed_data';

import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

/// Tablero fijo de 4×4 con 3 minas en 3, 6 y 12 (índices fila*4+columna):
///
///     0 1 2 M
///     0 1 M 2
///     1 2 1 1
///     M 1 0 0
///
/// Tiene dos zonas de ceros separadas: {0, 4} y {14, 15}.
MinesweeperGame _fixedGame() {
  const spec = BoardSpec(width: 4, height: 4, mines: 3);
  final mines = Uint8List(16)
    ..[3] = 1
    ..[6] = 1
    ..[12] = 1;
  return MinesweeperGame.free(spec: spec, seed: PuzzleSeed.fromKey('fijo'))..begin(MineLayout(spec, mines));
}

/// Partida libre generada de verdad, con su primer toque ya hecho.
MinesweeperGame _generated(BoardSpec spec, String key) {
  final game = MinesweeperGame.free(spec: spec, seed: PuzzleSeed.fromKey(key));
  final start = PuzzleSeed.fromKey('$key|start').createRandom().nextInt(spec.cellCount);
  game
    ..begin(MinesweeperGame.generateBoard(spec, key, start))
    ..reveal(start);
  return game;
}

/// Juega siguiendo solo las pistas hasta terminar.
GameStatus _playWithHints(MinesweeperGame game) {
  for (var step = 0; step < game.spec.cellCount * 2 && game.status == GameStatus.playing; step++) {
    final hint = game.hint()!;
    expect(hint.reason, isNot(HintReason.safeReveal), reason: 'la pista debe venir de una deducción');
    if (hint.reason == HintReason.wrongFlag || hint.isMine) {
      game.toggleFlag(hint.cell);
    } else {
      game.reveal(hint.cell);
    }
  }
  return game.status;
}

void main() {
  group('primer toque', () {
    test('la partida libre espera el tablero y no acepta jugadas antes', () {
      final game = MinesweeperGame.free(spec: BoardSpec.beginner, seed: PuzzleSeed.fromKey('x'));
      expect(game.status, GameStatus.ready);
      expect(game.needsBoard, isTrue);
      expect(() => game.reveal(0), throwsStateError);
    });

    test('el primer toque abre una zona en tableros generados', () {
      for (var i = 0; i < 50; i++) {
        final game = _generated(BoardSpec.intermediate, 'zona|$i');
        final revealed = List.generate(game.spec.cellCount, game.viewAt).where((v) => v == CellView.revealed).length;
        expect(revealed, greaterThan(1));
      }
    });

    test('rechaza un tablero de otro tamaño', () {
      final game = MinesweeperGame.free(spec: BoardSpec.beginner, seed: PuzzleSeed.fromKey('x'));
      expect(() => game.begin(MinesweeperGame.generateBoard(BoardSpec.intermediate, 'x', 0)), throwsArgumentError);
    });
  });

  group('revelar y banderas', () {
    test('la cascada abre los ceros y se detiene en los números', () {
      final game = _fixedGame();
      expect(game.reveal(0), MoveOutcome.changed);
      for (final i in [0, 1, 4, 5, 8, 9]) {
        expect(game.viewAt(i), CellView.revealed, reason: 'celda $i');
      }
      // La otra zona de ceros queda separada por números.
      for (final i in [2, 3, 10, 14, 15]) {
        expect(game.viewAt(i), CellView.hidden, reason: 'celda $i');
      }
    });

    test('la cascada no revela celdas con bandera', () {
      final game = _fixedGame()..toggleFlag(5);
      game.reveal(0);
      expect(game.viewAt(5), CellView.flagged);
    });

    test('una bandera se pone y se quita; no se puede en celdas reveladas', () {
      final game = _fixedGame();
      expect(game.toggleFlag(3), MoveOutcome.changed);
      expect(game.minesRemaining, 2);
      expect(game.toggleFlag(3), MoveOutcome.changed);
      expect(game.minesRemaining, 3);
      game.reveal(2);
      expect(game.toggleFlag(2), MoveOutcome.ignored);
    });

    test('revelar una celda ya revelada no hace nada', () {
      final game = _fixedGame()..reveal(2);
      expect(game.reveal(2), MoveOutcome.ignored);
    });
  });

  group('chord', () {
    test('con todas sus banderas revela el resto de vecinas', () {
      final game = _fixedGame()
        ..reveal(2)
        ..toggleFlag(3)
        ..toggleFlag(6);
      expect(game.chord(2), MoveOutcome.changed);
      for (final i in [1, 5, 7]) {
        expect(game.viewAt(i), CellView.revealed, reason: 'celda $i');
      }
    });

    test('no hace nada si faltan banderas', () {
      final game = _fixedGame()..reveal(2);
      expect(game.chord(2), MoveOutcome.ignored);
    });

    test('con una bandera equivocada revela una mina y pierde', () {
      final game = _fixedGame()
        ..reveal(2)
        ..toggleFlag(3)
        ..toggleFlag(7); // la mina real es la 6
      expect(game.chord(2), MoveOutcome.lost);
      expect(game.fatal, 6);
      expect(game.viewAt(7), CellView.wrongFlag);
      expect(game.viewAt(3), CellView.flagged);
    });
  });

  group('fin de partida', () {
    test('revelar una mina pierde y bloquea el tablero', () {
      final game = _fixedGame();
      expect(game.reveal(3), MoveOutcome.lost);
      expect(game.status, GameStatus.lost);
      expect(game.viewAt(3), CellView.fatal);
      expect(game.viewAt(12), CellView.mine);
      expect(game.reveal(0), MoveOutcome.ignored);
    });

    test('revelar todas las celdas seguras gana y marca las minas', () {
      final game = _fixedGame()
        ..reveal(0)
        ..reveal(2)
        ..reveal(7);
      expect(game.status, GameStatus.playing);
      expect(game.reveal(15), MoveOutcome.won);
      expect(game.status, GameStatus.won);
      for (final m in [3, 6, 12]) {
        expect(game.viewAt(m), CellView.flagged);
      }
      expect(game.minesRemaining, 0);
    });
  });

  group('deshacer y rescate', () {
    test('deshacer revierte la última jugada, incluida una cascada', () {
      final game = _fixedGame()
        ..reveal(0)
        ..toggleFlag(3);
      expect(game.undo(), isTrue);
      expect(game.viewAt(3), CellView.hidden);
      expect(game.undo(), isTrue);
      expect(List.generate(16, game.viewAt).every((v) => v == CellView.hidden), isTrue);
      expect(game.undo(), isFalse);
    });

    test('no se puede deshacer tras ganar ni tras perder', () {
      final won = _fixedGame()
        ..reveal(0)
        ..reveal(2)
        ..reveal(7)
        ..reveal(15);
      expect(won.status, GameStatus.won);
      expect(won.undo(), isFalse);
      final lost = _fixedGame()..reveal(3);
      expect(lost.undo(), isFalse);
    });

    test('el rescate vuelve al estado previo al error, una sola vez', () {
      final game = _fixedGame()
        ..reveal(0)
        ..reveal(3);
      expect(game.canRescue, isTrue);
      expect(game.rescue(), isTrue);
      expect(game.status, GameStatus.playing);
      expect(game.viewAt(3), CellView.hidden);
      expect(game.viewAt(0), CellView.revealed);
      expect(game.fatal, isNull);

      game.reveal(12);
      expect(game.status, GameStatus.lost);
      expect(game.canRescue, isFalse);
      expect(game.rescue(), isFalse);
    });

    test('el rescate de un chord revierte también lo que abrió antes de la mina', () {
      final game = _fixedGame()
        ..reveal(2)
        ..toggleFlag(3)
        ..toggleFlag(7);
      final before = List.generate(16, game.viewAt);
      expect(game.chord(2), MoveOutcome.lost);
      expect(game.viewAt(1), CellView.revealed, reason: 'el chord abrió la 1 antes de la mina');
      game.rescue();
      expect(List.generate(16, game.viewAt), before);
    });
  });

  group('pistas', () {
    test('primero señala una bandera equivocada', () {
      final game = _fixedGame()
        ..reveal(0)
        ..toggleFlag(15);
      final hint = game.hint()!;
      expect(hint.reason, HintReason.wrongFlag);
      expect(hint.cell, 15);
    });

    test('cada pista es correcta según el tablero real', () {
      for (var i = 0; i < 100; i++) {
        final game = _generated(BoardSpec.beginner, 'pista|$i');
        final hint = game.hint()!;
        final layout = MineLayout(
          game.spec,
          Uint8List.fromList(
            List.generate(game.spec.cellCount, (c) => (game.toJson()['mines']! as List).contains(c) ? 1 : 0),
          ),
        );
        expect(layout.isMine(hint.cell), hint.isMine, reason: 'semilla $i');
        expect(hint.sources, isNotEmpty);
      }
    });

    for (final (spec, count) in [(BoardSpec.beginner, 200), (BoardSpec.intermediate, 60), (BoardSpec.expert, 15)]) {
      test('$spec: seguir solo las pistas gana siempre ($count tableros)', () {
        for (var i = 0; i < count; i++) {
          final game = _generated(spec, 'solo-pistas|$spec|$i');
          expect(_playWithHints(game), GameStatus.won, reason: 'tablero $i');
        }
      });
    }

    test('no hay pista fuera de juego', () {
      final game = _fixedGame()..reveal(3);
      expect(game.hint(), isNull);
    });
  });

  group('guardado', () {
    test('ida y vuelta a mitad de partida conserva todo y se sigue jugando igual', () {
      final original = _generated(BoardSpec.intermediate, 'guardado');
      original
        ..toggleFlag(original.hint()!.cell)
        ..undo();
      final hint = original.hint()!;
      if (hint.isMine) {
        original.toggleFlag(hint.cell);
      } else {
        original.reveal(hint.cell);
      }

      final copy = MinesweeperGame.fromJson(jsonDecode(jsonEncode(original.toJson())) as Map<String, Object?>);
      expect(copy.toJson(), original.toJson());
      expect(_playWithHints(copy), GameStatus.won);
      expect(copy.undo(), isFalse);
    });

    test('guarda una partida libre que aún no tiene tablero', () {
      final game = MinesweeperGame.free(spec: BoardSpec.beginner, seed: PuzzleSeed.fromKey('vacía'));
      final copy = MinesweeperGame.fromJson(game.toJson());
      expect(copy.needsBoard, isTrue);
      expect(copy.status, GameStatus.ready);
    });

    test('rechaza versiones desconocidas', () {
      final json = _fixedGame().toJson()..['v'] = 99;
      expect(() => MinesweeperGame.fromJson(json), throwsFormatException);
    });
  });

  group('reto diario', () {
    test('trae tablero y celda de inicio iguales para todos, y esa celda abre una zona', () {
      final seed = PuzzleSeed.daily(
        day: LocalDay(2026, 11, 2),
        game: GameId.minesweeper,
        generatorVersion: NoGuessGenerator.version,
      );
      final a = MinesweeperGame.daily(spec: BoardSpec.beginner, seed: seed);
      final b = MinesweeperGame.daily(spec: BoardSpec.beginner, seed: PuzzleSeed.fromKey(seed.key));
      expect(a.suggestedStart, b.suggestedStart);
      expect(a.toJson()['mines'], b.toJson()['mines']);
      expect(a.status, GameStatus.playing);
      a.reveal(a.suggestedStart!);
      expect(_playWithHints(a), GameStatus.won);
    });
  });
}
