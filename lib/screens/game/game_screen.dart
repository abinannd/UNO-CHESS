import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/game/game_state.dart';
import 'package:uno_chess/core/game/game_status.dart';
import 'package:uno_chess/core/game/turn_system.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_color.dart';
import 'package:uno_chess/core/uno/uno_card_generator.dart';
import 'package:uno_chess/core/uno/uno_effect.dart';
import 'package:uno_chess/core/uno/special_effect.dart';
import 'package:uno_chess/ui/board/chess_board_widget.dart';
import 'package:uno_chess/ui/hud/game_hud.dart';

/// The primary screen displaying the active game.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Instantiate the core GameState
  late final GameState _gameState;
  
  Position? _selectedPosition;
  List<ChessMove> _currentLegalMoves = [];

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
  }

  Position? get _checkPosition {
    if (_gameState.status != GameStatus.active) return null;
    final engine = ChessEngine(_gameState.board);
    
    Position? findKing(ChessColor color) {
      for (int r = 0; r < 8; r++) {
        for (int f = 0; f < 8; f++) {
          final p = _gameState.board.getPieceAt(Position(f, r));
          if (p != null && p.type == PieceType.king && p.color == color) {
            return Position(f, r);
          }
        }
      }
      return null;
    }
    
    if (engine.isInCheck(ChessColor.white)) return findKing(ChessColor.white);
    if (engine.isInCheck(ChessColor.black)) return findKing(ChessColor.black);
    
    return null;
  }

  void _onSquareTapped(Position position) {
    if (_gameState.status != GameStatus.active) return;
    if (_gameState.turnPhase != TurnPhase.awaitingChessMove) return;

    final controlledColor = _gameState.currentPlayer.controlledColor;

    if (_selectedPosition != null) {
      final matchingMoves = _currentLegalMoves
          .where((m) => m.from == _selectedPosition && m.to == position)
          .toList();

      if (matchingMoves.isNotEmpty) {
        if (matchingMoves.any((m) => m.promotion != null)) {
          _showPromotionDialog(matchingMoves.first);
          return;
        }

        _executeMove(matchingMoves.first);
        return;
      }
    }

    // Tapped a square — check if it is an own piece (select or re-select).
    final piece = _gameState.board.getPieceAt(position);
    if (piece != null && piece.color == controlledColor) {
      // Re-selecting another own piece is allowed — switch selection.
      setState(() {
        _selectedPosition = position;
        final engine = ChessEngine(_gameState.board);
        _currentLegalMoves = engine.generateLegalMoves(controlledColor)
            .where((m) => m.from == position)
            .toList();
      });
    } else {
      // Tapped empty square or opponent piece that is not a legal destination — deselect.
      setState(() {
        _selectedPosition = null;
        _currentLegalMoves = [];
      });
    }
  }

  void _executeMove(ChessMove move) {
    setState(() {
      _gameState.executeChessMove(move);
      _selectedPosition = null;
      _currentLegalMoves = [];
    });
  }

  void _showPromotionDialog(ChessMove baseMove) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Promote Pawn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]
              .map((type) => ListTile(
                    title: Text(type.name.toUpperCase()),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _executeMove(ChessMove(
                        from: baseMove.from,
                        to: baseMove.to,
                        promotion: type,
                      ));
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showRainbowDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Rainbow Card: Choose Effect'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...[1, 2, 3, 4].map((moves) => ListTile(
                    title: Text('Number $moves'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _resolveRainbow(UnoEffect.resolve(moves: moves));
                    },
                  )),
              const Divider(),
              ...[SpecialEffect.plusTwo, SpecialEffect.plusFour, SpecialEffect.skip, SpecialEffect.reverse]
                  .map((effect) => ListTile(
                        title: Text(effect.name.toUpperCase()),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _resolveRainbow(UnoEffect.resolve(specialEffect: effect));
                        },
                      )),
            ],
          ),
        ),
      ),
    );
  }

  void _resolveRainbow(UnoEffect effect) {
    setState(() {
      _gameState.resolveRainbow(effect);
    });

    if (_gameState.turnPhase == TurnPhase.resolvingReverse) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _gameState.completeReverse();
          });
        }
      });
    } else if (_gameState.turnPhase == TurnPhase.resolvingSkip) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _gameState.completeSkip();
          });
        }
      });
    } else if (_gameState.turnPhase == TurnPhase.resolvingDraw2Draw4) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _gameState.completeDraw2Draw4();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UNO Chess'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GameHudWidget(
                gameState: _gameState,
                isInCheck: _checkPosition != null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChessBoardWidget(
                    board: _gameState.board,
                    isReversed: _gameState.isBoardReversed,
                    selectedPosition: _selectedPosition,
                    legalDestinations: _currentLegalMoves.map((m) => m.to).toList(),
                    checkPosition: _checkPosition,
                    onSquareTapped: _onSquareTapped,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _gameState.turnPhase == TurnPhase.awaitingDraw
                      ? () {
                          final generator = UnoCardGenerator();
                          setState(() {
                            _gameState.drawCard(generator.generate());
                          });
                          
                          if (_gameState.turnPhase == TurnPhase.resolvingReverse) {
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() {
                                  _gameState.completeReverse();
                                });
                              }
                            });
                          } else if (_gameState.turnPhase == TurnPhase.resolvingSkip) {
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() {
                                  _gameState.completeSkip();
                                });
                              }
                            });
                          } else if (_gameState.turnPhase == TurnPhase.resolvingDraw2Draw4) {
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() {
                                  _gameState.completeDraw2Draw4();
                                });
                              }
                            });
                          } else if (_gameState.turnPhase == TurnPhase.awaitingRainbowResolution) {
                            _showRainbowDialog();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    disabledBackgroundColor: Colors.grey.shade800,
                  ),
                  child: const Text(
                    'DRAW',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
