import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/block_game.dart';

const _background = Color(0xFF101827);
const _panel = Color(0xFF1B2A3E);
const _empty = Color(0xFF26384E);
const _mint = Color(0xFF6AE9CB);
const _colors = <Color>[
  Color(0xFFF7CB69),
  Color(0xFF6AE9CB),
  Color(0xFF72BEF7),
  Color(0xFFFB9A87),
  Color(0xFFC7A1FA),
  Color(0xFF7EDD93),
  Color(0xFFFF91BB),
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _scoreKey = 'blockpons.bestScore.v1';

  final _boardKey = GlobalKey();
  final PieceGenerator _generator = PieceGenerator();
  late BlockGame _game = BlockGame.start(_generator);

  int _best = 0;
  int? _selected;
  int? _hoverSlot;
  Cell? _hoverAnchor;
  String _eventMessage = 'ピースをドラッグして配置しよう';

  @override
  void initState() {
    super.initState();
    unawaited(_loadBest());
  }

  Future<void> _loadBest() async {
    try {
      final store = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          if ((store.getInt(_scoreKey) ?? 0) > _best) {
            _best = store.getInt(_scoreKey) ?? 0;
          }
        });
      }
    } catch (_) {
      // The game is still playable if storage is disabled in a private tab.
    }
  }

  Future<void> _saveBest(int score) async {
    try {
      final store = await SharedPreferences.getInstance();
      final persisted = store.getInt(_scoreKey) ?? 0;
      if (score > persisted) await store.setInt(_scoreKey, score);
    } catch (_) {
      // Do not block an offline game due to unavailable local storage.
    }
  }

  void _restart() {
    setState(() {
      _game = BlockGame.start(_generator);
      _selected = null;
      _hoverSlot = null;
      _hoverAnchor = null;
      _eventMessage = '新しいゲームが始まりました';
    });
  }

  Cell? _positionFromGlobal(Offset global, int slot, {bool centered = true}) {
    final box = _boardKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final piece = _game.offers[slot];
    if (piece == null) return null;
    final point = box.globalToLocal(global);
    final unit = box.size.width / BlockGame.size;
    if (unit <= 0) return null;
    if (centered) {
      return Cell(
        (point.dx / unit - piece.width / 2).round(),
        (point.dy / unit - piece.height / 2).round(),
      );
    }
    return Cell((point.dx / unit).floor(), (point.dy / unit).floor());
  }

  void _moveHover(int slot, Offset global) {
    final anchor = _positionFromGlobal(global, slot);
    if (!mounted) return;
    setState(() {
      _hoverSlot = slot;
      _hoverAnchor = anchor;
    });
  }

  void _clearHover() {
    if (!mounted) return;
    setState(() {
      _hoverSlot = null;
      _hoverAnchor = null;
    });
  }

  void _apply(int slot, Cell? anchor) {
    if (anchor == null) return;
    final result = _game.place(slot, anchor, _generator);
    setState(() {
      _hoverSlot = null;
      _hoverAnchor = null;
      if (!result.accepted) {
        _eventMessage = 'そこには置けません';
        return;
      }
      _game = result.game;
      _selected = null;
      _eventMessage = result.clearedLines > 0
          ? '${result.clearedLines}ライン消去！ +${result.gainedPoints}'
          : '+${result.gainedPoints} ポイント';
      if (_game.isOver) _eventMessage = 'ゲームオーバー';
      if (_game.score > _best) {
        _best = _game.score;
        unawaited(_saveBest(_best));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_background, Color(0xFF172C3E), _background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 530),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(),
                    const SizedBox(height: 22),
                    _scoreboard(),
                    const SizedBox(height: 18),
                    _board(),
                    const SizedBox(height: 14),
                    Text(
                      _eventMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _mint, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _tray(),
                    const SizedBox(height: 12),
                    const Text(
                      'ドラッグで配置 · タップで選択して盤面をタップしてもOK',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFA9BBC8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          const Icon(Icons.grid_view_rounded, color: _mint, size: 30),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'BLOCKPONS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.refresh, size: 19),
            label: const Text('リトライ'),
          ),
        ],
      );

  Widget _scoreboard() => Row(
        children: [
          Expanded(child: _numberCard('SCORE', _game.score)),
          const SizedBox(width: 12),
          Expanded(child: _numberCard('BEST', _best)),
        ],
      );

  Widget _numberCard(String caption, int value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              caption,
              style: const TextStyle(
                color: Color(0xFFAAC1D4),
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _board() {
    final candidate = _hoverSlot == null ? null : _game.offers[_hoverSlot!];
    final anchor = _hoverAnchor;
    final preview = <Cell>{};
    final previewValid = candidate != null &&
        anchor != null &&
        _game.canPlace(candidate, anchor);
    if (candidate != null && anchor != null) {
      for (final offset in candidate.cells) {
        preview.add(Cell(anchor.x + offset.x, anchor.y + offset.y));
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => !_game.isOver,
        onMove: (details) => _moveHover(details.data, details.offset),
        onLeave: (_) => _clearHover(),
        onAcceptWithDetails: (details) {
          _apply(
            details.data,
            _positionFromGlobal(details.offset, details.data),
          );
        },
        builder: (context, data, rejected) => GestureDetector(
          onTapDown: (details) {
            final slot = _selected;
            if (slot != null) {
              final box = _boardKey.currentContext?.findRenderObject();
              if (box is RenderBox) {
                _apply(slot, _positionFromGlobal(
                  box.localToGlobal(details.localPosition),
                  slot,
                  centered: false,
                ));
              }
            }
          },
          child: Container(
            key: _boardKey,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFF456078), width: 2),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: BlockGame.size * BlockGame.size,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: BlockGame.size,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final x = index % BlockGame.size;
                    final y = index ~/ BlockGame.size;
                    final color = _game.board[index];
                    final highlighted = preview.contains(Cell(x, y));
                    return AnimatedContainer(
                      key: ValueKey('cell-$x-$y'),
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: color != null
                            ? _colors[color % _colors.length]
                            : highlighted
                                ? (previewValid
                                    ? const Color(0xFF3D8F83)
                                    : const Color(0xFF925264))
                                : _empty,
                        borderRadius: BorderRadius.circular(5),
                        border: highlighted
                            ? Border.all(
                                color: previewValid ? _mint : Colors.redAccent,
                                width: 1.4,
                              )
                            : null,
                      ),
                    );
                  },
                ),
                if (_game.isOver)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xE5101827),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'GAME OVER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('スコア  ${_game.score}'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _restart,
                            child: const Text('もう一度遊ぶ'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tray() => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: SizedBox(
                  height: 97,
                  child: Center(child: _offerWidget(i)),
                ),
              ),
          ],
        ),
      );

  Widget _offerWidget(int index) {
    final piece = _game.offers[index];
    if (piece == null) {
      return const Icon(Icons.check_circle_outline,
          color: Color(0xFF456078), size: 25);
    }
    final selected = _selected == index;
    final content = Container(
      key: ValueKey('offer-$index'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF314B55) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: _mint) : null,
      ),
      child: _piecePreview(piece, 19),
    );
    if (_game.isOver) return content;
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: _piecePreview(piece, 27),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: content),
      child: GestureDetector(
        onTap: () => setState(() {
          _selected = selected ? null : index;
          _eventMessage = _selected == null
              ? 'ピースをドラッグして配置しよう'
              : '盤面の配置先をタップしてください';
        }),
        child: content,
      ),
    );
  }

  Widget _piecePreview(Piece piece, double unit) {
    final shape = piece.cells.toSet();
    return SizedBox(
      width: piece.width * unit,
      height: piece.height * unit,
      child: Column(
        children: [
          for (var y = 0; y < piece.height; y++)
            Row(
              children: [
                for (var x = 0; x < piece.width; x++)
                  SizedBox(
                    width: unit,
                    height: unit,
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: shape.contains(Cell(x, y))
                              ? _colors[piece.colorIndex % _colors.length]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
