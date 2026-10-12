import 'package:flutter_test/flutter_test.dart';
import 'package:blockpons/game/domain/block_game.dart';

void main() {
  final single = PieceCatalog.all.first;
  final horizontal = PieceCatalog.all[1];
  final square = PieceCatalog.all[5];

  List<int?> emptyBoard() => List<int?>.filled(64, null);

  test('new game has 64 empty cells and exactly three offers', () {
    final game = BlockGame.start(PieceGenerator(seed: 7));
    expect(game.board, hasLength(64));
    expect(game.board.where((cell) => cell != null), isEmpty);
    expect(game.offers.whereType<Piece>(), hasLength(3));
    expect(game.isOver, isFalse);
  });

  test('fixed seed yields reproducible offers', () {
    final first = BlockGame.start(PieceGenerator(seed: 321));
    final second = BlockGame.start(PieceGenerator(seed: 321));
    expect(
      first.offers.map((piece) => piece?.id),
      second.offers.map((piece) => piece?.id),
    );
  });

  test('placement rejects out of bounds and overlap without mutation', () {
    final originalBoard = emptyBoard();
    originalBoard[0] = 1;
    final game = BlockGame.fromState(
      board: originalBoard,
      offers: [horizontal, square, single],
    );
    final random = PieceGenerator(seed: 0);
    expect(game.canPlace(horizontal, const Cell(7, 0)), isFalse);
    expect(game.canPlace(horizontal, const Cell(0, 0)), isFalse);
    final outside = game.place(0, const Cell(7, 0), random);
    final overlap = game.place(0, const Cell(0, 0), random);
    expect(outside.accepted, isFalse);
    expect(overlap.accepted, isFalse);
    expect(identical(outside.game, game), isTrue);
    expect(game.at(0, 0), 1);
    expect(game.score, 0);
  });

  test('a full row and intersecting column clear once each', () {
    final board = emptyBoard();
    for (var i = 1; i < 8; i++) {
      board[i] = 1; // first row, except (0,0)
      board[i * 8] = 1; // first column, except (0,0)
    }
    final game = BlockGame.fromState(
      board: board,
      offers: [single, horizontal, square],
    );
    final result = game.place(0, const Cell(0, 0), PieceGenerator(seed: 2));
    expect(result.accepted, isTrue);
    expect(result.clearedLines, 2);
    expect(result.clearedCells.toSet(), hasLength(15));
    expect(result.gainedPoints, 171); // 1 placement + 150 + 20 double-line
    expect(result.game.board.where((cell) => cell != null), isEmpty);
    expect(game.at(0, 0), null); // original snapshot is unchanged
  });

  test('three consumed offers are replaced together', () {
    final game = BlockGame.fromState(
      board: emptyBoard(),
      offers: [single, single, single],
    );
    final rng = PieceGenerator(seed: 7);
    final a = game.place(2, const Cell(0, 0), rng).game;
    expect(a.offers[2], null);
    final b = a.place(0, const Cell(1, 0), rng).game;
    expect(b.offers[0], null);
    final c = b.place(1, const Cell(2, 0), rng).game;
    expect(c.offers.whereType<Piece>(), hasLength(3));
    expect(c.score, 3);
  });

  test('game ends if no remaining shape fits', () {
    final almostFull = List<int?>.filled(64, 1);
    almostFull[0] = null;
    final cannotFit = BlockGame.fromState(
      board: almostFull,
      offers: [horizontal, square, null],
    );
    expect(cannotFit.isOver, isTrue);
    final canFit = BlockGame.fromState(
      board: almostFull,
      offers: [horizontal, square, single],
    );
    expect(canFit.isOver, isFalse);
    expect(canFit.canPlace(single, const Cell(0, 0)), isTrue);
  });

  test('combo resets after a non-clearing placement', () {
    final board = emptyBoard();
    for (var x = 1; x < 8; x++) {
      board[x] = 1;
      board[8 + x] = 1;
    }
    final game = BlockGame.fromState(
      board: board,
      offers: [single, single, single],
    );
    final rng = PieceGenerator(seed: 12);
    final cleared = game.place(0, const Cell(0, 0), rng).game;
    expect(cleared.combo, 1);
    final ignored = cleared.place(1, const Cell(7, 7), rng).game;
    expect(ignored.combo, 0);
  });

  test('invalid offer index cannot change the board', () {
    final game = BlockGame.start(PieceGenerator(seed: 0));
    final result = game.place(-1, const Cell(0, 0), PieceGenerator(seed: 0));
    expect(result.accepted, false);
    expect(identical(result.game, game), true);
  });
}
