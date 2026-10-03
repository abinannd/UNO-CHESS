import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/game/game_state.dart';
import 'package:uno_chess/core/game/game_status.dart';
import 'package:uno_chess/core/game/player_identity.dart';
import 'package:uno_chess/core/game/turn_system.dart';
import 'package:uno_chess/core/uno/special_effect.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_color.dart';

void main() {
  group('GameState Initialization', () {
    test('Default initialization represents new active game accurately', () {
      final state = GameState();
      
      expect(state.status, equals(GameStatus.active));
      expect(state.turnPhase, equals(TurnPhase.awaitingDraw));
      expect(state.currentPlayer.identity, equals(PlayerIdentity.player1));
      
      expect(state.player1.controlledColor, equals(ChessColor.white));
      expect(state.player2.controlledColor, equals(ChessColor.black));
      
      expect(state.player1.revivalPoints, equals(0));
      expect(state.player2.revivalPoints, equals(0));
      
      expect(state.player1.capturedPieces, isEmpty);
      expect(state.player2.capturedPieces, isEmpty);
      
      expect(state.isBoardReversed, isFalse);
      expect(state.movesAllowed, equals(0));
      expect(state.movesCompleted, equals(0));
      
      // Board should be initial chess setup
      expect(state.board.getPieceAt(Position.fromAlgebraic('e1'))?.type, equals(PieceType.king));
    });
  });

  group('GameState Chess Progression', () {
    test('executeChessMove updates state correctly and checks bounds', () {
      final state = GameState();
      
      // Need to draw a number card first
      state.drawCard(UnoCard.number(1, UnoColor.red));
      expect(state.turnPhase, equals(TurnPhase.awaitingChessMove));
      
      final move = ChessMove(
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e4'),
      );
      
      final success = state.executeChessMove(move);
      
      expect(success, isTrue);
      // Turn finishes because we played our 1 move
      expect(state.turnPhase, equals(TurnPhase.awaitingDraw));
      expect(state.currentPlayer.identity, equals(PlayerIdentity.player2));
      
      // Board has changed
      expect(state.board.getPieceAt(Position.fromAlgebraic('e4'))?.type, equals(PieceType.pawn));
    });

    test('Captured pieces correctly update through GameState API', () {
      // Create board with white rook attacking black queen
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d4'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d7'), const ChessPiece(PieceType.queen, ChessColor.black));
      
      final state = GameState(board: board);
      state.drawCard(UnoCard.number(1, UnoColor.red));
      
      final success = state.executeChessMove(
        ChessMove(from: Position.fromAlgebraic('d4'), to: Position.fromAlgebraic('d7'))
      );
      
      expect(success, isTrue);
      expect(state.player2.capturedPieces.length, equals(1));
      expect(state.player2.capturedPieces.first.type, equals(PieceType.queen));
    });
  });

  group('GameState Special Cards and RP', () {
    test('+2 card assigns RP and ends turn securely', () {
      final state = GameState();
      state.drawCard(UnoCard.special(SpecialEffect.plusTwo, UnoColor.green));
      
      expect(state.player1.revivalPoints, equals(2));
      expect(state.currentPlayer.identity, equals(PlayerIdentity.player2));
      expect(state.turnPhase, equals(TurnPhase.awaitingDraw));
    });

    test('Reverse swap persists accurately at GameState level', () {
      final state = GameState();
      state.drawCard(UnoCard.special(SpecialEffect.reverse, UnoColor.yellow));
      
      expect(state.player1.controlledColor, equals(ChessColor.black));
      expect(state.player2.controlledColor, equals(ChessColor.white));
      expect(state.isBoardReversed, isTrue);
      expect(state.currentPlayer.identity, equals(PlayerIdentity.player1));
    });

    test('Skip bypasses chess move accurately', () {
      final state = GameState();
      state.drawCard(UnoCard.special(SpecialEffect.skip, UnoColor.blue));
      
      expect(state.currentPlayer.identity, equals(PlayerIdentity.player2));
      expect(state.turnPhase, equals(TurnPhase.awaitingDraw));
    });
  });

  group('GameState Terminal States', () {
    test('Checkmate evaluates accurately and prevents further action', () {
      // Set up Fools Mate
      final state = GameState();
      
      state.drawCard(UnoCard.number(4, UnoColor.red)); // Lots of moves for white
      state.executeChessMove(ChessMove(from: Position.fromAlgebraic('f2'), to: Position.fromAlgebraic('f3')));
      state.executeChessMove(ChessMove(from: Position.fromAlgebraic('g2'), to: Position.fromAlgebraic('g4')));
      // White ends turn early by failing next? No, wait. 
      // To simulate properly, let's just create a checkmate board
      
      final board = ChessBoard.empty();
      // Black king trapped by White Queen, defended by White King
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.queen, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e6'), const ChessPiece(PieceType.king, ChessColor.white));
      
      final checkmateState = GameState(board: board);
      
      expect(checkmateState.status, equals(GameStatus.checkmate));
      
      // Should reject actions when inactive
      checkmateState.drawCard(UnoCard.number(1, UnoColor.red));
      expect(checkmateState.turnPhase, equals(TurnPhase.awaitingDraw)); // Unchanged
    });

    test('Stalemate evaluates accurately and locks state', () {
      // Setup Stalemate board
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('h8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('f7'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('g6'), const ChessPiece(PieceType.queen, ChessColor.white));
      // Black King is not in check, but has no legal moves.
      
      final stalemateState = GameState(board: board);
      
      expect(stalemateState.status, equals(GameStatus.stalemate));
    });
  });
}
