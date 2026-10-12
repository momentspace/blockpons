import 'dart:math';

/// A position on an eight-by-eight board. Coordinates increase right/down.
class Cell {
  final int x;
  final int y;

  const Cell(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// A fixed-orientation shape. No Flutter types enter the game model.
class Piece {
  final String id;
  final int colorIndex;
  final List<Cell> cells;

  const Piece(this.id, this.colorIndex, this.cells);

  int get width => cells.map((cell) => cell.x).reduce(max) + 1;
  int get height => cells.map((cell) => cell.y).reduce(max) + 1;
}

/// Original, intentionally small shape set. Every template is normalized.
class PieceCatalog {
  static const List<Piece> all = [
    Piece('single', 0, [Cell(0, 0)]),
    Piece('double_h', 1, [Cell(0, 0), Cell(1, 0)]),
    Piece('double_v', 1, [Cell(0, 0), Cell(0, 1)]),
    Piece('triple_h', 2, [Cell(0, 0), Cell(1, 0), Cell(2, 0)]),
    Piece('triple_v', 2, [Cell(0, 0), Cell(0, 1), Cell(0, 2)]),
    Piece('square_2', 3, [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)]),
    Piece('l_right', 4, [Cell(0, 0), Cell(0, 1), Cell(1, 1)]),
    Piece('l_left', 4, [Cell(1, 0), Cell(0, 1), Cell(1, 1)]),
    Piece('t', 5, [Cell(0, 0), Cell(1, 0), Cell(2, 0), Cell(1, 1)]),
    Piece('bar_4', 6, [Cell(0, 0), Cell(1, 0), Cell(2, 0), Cell(3, 0)]),
    Piece('bar_4_v', 6, [Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(0, 3)]),
    Piece('square_3', 3, [
      Cell(0, 0), Cell(1, 0), Cell(2, 0),
      Cell(0, 1), Cell(1, 1), Cell(2, 1),
      Cell(0, 2), Cell(1, 2), Cell(2, 2),
    ]),
  ];
}

/// Inject a seeded generator in tests to make offers deterministic.
class PieceGenerator {
  final Random _random;

  PieceGenerator({int? seed}) : _random = seed == null ? Random() : Random(seed);

  Piece next() => PieceCatalog.all[_random.nextInt(PieceCatalog.all.length)];
}

class MoveResult {
  final BlockGame game;
  final bool accepted;
  final int gainedPoints;
  final int clearedLines;
  final List<Cell> clearedCells;

  const MoveResult({
    required this.game,
    required this.accepted,
    this.gainedPoints = 0,
    this.clearedLines = 0,
    this.clearedCells = const [],
  });
}

/// Immutable rule snapshot: index = y * size + x.
class BlockGame {
  static const int size = 8;

  final List<int?> board;
  final List<Piece?> offers;
  final int score;
  final int combo;

  BlockGame._(List<int?> board, List<Piece?> offers, this.score, this.combo)
      : board = List<int?>.unmodifiable(board),
        offers = List<Piece?>.unmodifiable(offers) {
    if (board.length != size * size || offers.length != 3) {
      throw ArgumentError('Board must contain 64 cells and three offers.');
    }
  }

  factory BlockGame.start(PieceGenerator generator) => BlockGame._(
        List<int?>.filled(size * size, null),
        List<Piece?>.generate(3, (_) => generator.next()),
        0,
        0,
      );

  /// Supports deterministic board setups in unit tests and diagnostics.
  factory BlockGame.fromState({
    required List<int?> board,
    required List<Piece?> offers,
    int score = 0,
    int combo = 0,
  }) =>
      BlockGame._(board, offers, score, combo);

  int? at(int x, int y) {
    if (x < 0 || x >= size || y < 0 || y >= size) {
      throw RangeError('Outside board: ($x, $y)');
    }
    return board[y * size + x];
  }

  bool canPlace(Piece piece, Cell anchor) {
    for (final offset in piece.cells) {
      final x = anchor.x + offset.x;
      final y = anchor.y + offset.y;
      if (x < 0 || x >= size || y < 0 || y >= size) return false;
      if (board[y * size + x] != null) return false;
    }
    return true;
  }

  bool canPlaceAnywhere(Piece piece) {
    for (var y = 0; y <= size - piece.height; y++) {
      for (var x = 0; x <= size - piece.width; x++) {
        if (canPlace(piece, Cell(x, y))) return true;
      }
    }
    return false;
  }

  bool get isOver => offers.whereType<Piece>().every(
        (piece) => !canPlaceAnywhere(piece),
      );

  MoveResult place(int offerIndex, Cell anchor, PieceGenerator generator) {
    if (offerIndex < 0 || offerIndex >= offers.length || isOver) {
      return MoveResult(game: this, accepted: false);
    }
    final piece = offers[offerIndex];
    if (piece == null || !canPlace(piece, anchor)) {
      return MoveResult(game: this, accepted: false);
    }

    final updated = List<int?>.of(board);
    for (final offset in piece.cells) {
      final x = anchor.x + offset.x;
      final y = anchor.y + offset.y;
      updated[y * size + x] = piece.colorIndex;
    }

    final rows = <int>[];
    final columns = <int>[];
    for (var y = 0; y < size; y++) {
      if (List.generate(size, (x) => updated[y * size + x])
          .every((cell) => cell != null)) {
        rows.add(y);
      }
    }
    for (var x = 0; x < size; x++) {
      if (List.generate(size, (y) => updated[y * size + x])
          .every((cell) => cell != null)) {
        columns.add(x);
      }
    }

    final cleared = <Cell>{};
    for (final y in rows) {
      for (var x = 0; x < size; x++) {
        cleared.add(Cell(x, y));
      }
    }
    for (final x in columns) {
      for (var y = 0; y < size; y++) {
        cleared.add(Cell(x, y));
      }
    }
    for (final cell in cleared) {
      updated[cell.y * size + cell.x] = null;
    }

    final lines = rows.length + columns.length;
    final nextCombo = lines == 0 ? 0 : combo + 1;
    // Blockpons' own provisional scoring formula, not copied from another game.
    final gained = piece.cells.length +
        cleared.length * 10 +
        (lines > 1 ? (lines - 1) * 20 : 0) +
        (nextCombo > 1 ? (nextCombo - 1) * lines * 5 : 0);

    final nextOffers = List<Piece?>.of(offers);
    nextOffers[offerIndex] = null;
    if (nextOffers.every((piece) => piece == null)) {
      for (var index = 0; index < nextOffers.length; index++) {
        nextOffers[index] = generator.next();
      }
    }
    return MoveResult(
      game: BlockGame._(updated, nextOffers, score + gained, nextCombo),
      accepted: true,
      gainedPoints: gained,
      clearedLines: lines,
      clearedCells: List<Cell>.unmodifiable(cleared),
    );
  }
}
