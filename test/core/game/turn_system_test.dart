import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/game/player_identity.dart';
import 'package:uno_chess/core/game/turn_system.dart';
import 'package:uno_chess/core/uno/special_effect.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_color.dart';
import 'package:uno_chess/core/uno/uno_effect.dart';

void main() {
  late TurnSystem turnSystem;
  late ChessBoard board;

  setUp(() {
    turnSystem = TurnSystem();
    board = ChessBoard.initial();
  });

  group('TurnSystem Initialization', () {
    test('Starts with Player 1, awaiting draw, empty state', () {
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player1));
      expect(turnSystem.currentPlayer.controlledColor, equals(ChessColor.white));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentCard, isNull);
      expect(turnSystem.movesAllowed, equals(0));
      expect(turnSystem.movesCompleted, equals(0));
      expect(turnSystem.isBoardReversed, isFalse);
    });
  });

  group('Number Cards', () {
    test('Number 2 grants 2 moves, player switches after both completed', () {
      turnSystem.drawCard(UnoCard.number(2, UnoColor.red));
      expect(turnSystem.phase, equals(TurnPhase.awaitingChessMove));
      expect(turnSystem.movesAllowed, equals(2));

      // Move 1
      final move1 = ChessMove(
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e4'),
      );
      final success1 = turnSystem.executeChessMove(move1, board);
      expect(success1, isTrue);
      expect(turnSystem.movesCompleted, equals(1));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player1)); // Still P1

      // Move 2
      final move2 = ChessMove(
        from: Position.fromAlgebraic('e4'),
        to: Position.fromAlgebraic('e5'),
      );
      final success2 = turnSystem.executeChessMove(move2, board);
      expect(success2, isTrue);
      
      // Turn ended, switched to P2
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player2));
      expect(turnSystem.movesCompleted, equals(0));
      expect(turnSystem.currentCard, isNull);
    });

    test('Illegal moves are rejected and do not increment moves completed', () {
      turnSystem.drawCard(UnoCard.number(1, UnoColor.blue));
      
      final illegalMove = ChessMove(
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e5'), // e2 to e5 is illegal for pawn
      );
      
      final success = turnSystem.executeChessMove(illegalMove, board);
      expect(success, isFalse);
      expect(turnSystem.movesCompleted, equals(0));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player1));
      expect(turnSystem.phase, equals(TurnPhase.awaitingChessMove));
    });

    test('Number 1-4 move counts correctly setup', () {
      for (int i = 1; i <= 4; i++) {
        final ts = TurnSystem();
        ts.drawCard(UnoCard.number(i, UnoColor.green));
        expect(ts.movesAllowed, equals(i));
      }
    });
  });

  group('Capture Integration', () {
    test('Captured piece is recorded in the waiting player\'s revival system', () {
      board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d4'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d7'), const ChessPiece(PieceType.queen, ChessColor.black));
      
      turnSystem.drawCard(UnoCard.number(1, UnoColor.red));
      
      final captureMove = ChessMove(
        from: Position.fromAlgebraic('d4'),
        to: Position.fromAlgebraic('d7'),
      );
      final success = turnSystem.executeChessMove(captureMove, board);
      expect(success, isTrue);
      
      // Since P1 played, P2's Queen was captured. Wait, waitingPlayer is now P1 because turn ended!
      // But P2 lost the Queen. P2 is player2.
      expect(turnSystem.player2.capturedPieces.length, equals(1));
      expect(turnSystem.player2.capturedPieces.first.type, equals(PieceType.queen));
      expect(turnSystem.player2.capturedPieces.first.color, equals(ChessColor.black));
    });
  });

  group('Special Cards (+2, +4, Skip)', () {
    test('+2 grants RP and ends turn without chess moves', () {
      turnSystem.drawCard(UnoCard.special(SpecialEffect.plusTwo, UnoColor.red));
      
      expect(turnSystem.player1.revivalPoints, equals(2));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player2));
    });

    test('+4 grants RP and ends turn without chess moves', () {
      turnSystem.drawCard(UnoCard.special(SpecialEffect.plusFour, UnoColor.blue));
      
      expect(turnSystem.player1.revivalPoints, equals(4));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player2));
    });

    test('Skip grants 0 moves and ends turn immediately', () {
      turnSystem.drawCard(UnoCard.special(SpecialEffect.skip, UnoColor.green));
      
      expect(turnSystem.player1.revivalPoints, equals(0));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player2));
    });
  });

  group('Reverse Card', () {
    test('Reverse swaps colors, flips orientation, and keeps player active', () {
      turnSystem.drawCard(UnoCard.special(SpecialEffect.reverse, UnoColor.yellow));
      
      expect(turnSystem.player1.controlledColor, equals(ChessColor.black));
      expect(turnSystem.player2.controlledColor, equals(ChessColor.white));
      expect(turnSystem.isBoardReversed, isTrue);
      
      // "The player who drew Reverse remains active"
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player1));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
    });
  });

  group('Rainbow Card', () {
    test('Rainbow enters awaitingRainbowResolution phase', () {
      turnSystem.drawCard(UnoCard.rainbow());
      
      expect(turnSystem.phase, equals(TurnPhase.awaitingRainbowResolution));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player1));
    });

    test('Rainbow resolves to number card correctly', () {
      turnSystem.drawCard(UnoCard.rainbow());
      turnSystem.resolveRainbow(UnoEffect.resolve(moves: 3));
      
      expect(turnSystem.phase, equals(TurnPhase.awaitingChessMove));
      expect(turnSystem.movesAllowed, equals(3));
    });

    test('Rainbow resolves to special card (+4) correctly', () {
      turnSystem.drawCard(UnoCard.rainbow());
      turnSystem.resolveRainbow(UnoEffect.resolve(specialEffect: SpecialEffect.plusFour));
      
      expect(turnSystem.player1.revivalPoints, equals(4));
      expect(turnSystem.phase, equals(TurnPhase.awaitingDraw));
      expect(turnSystem.currentPlayerIdentity, equals(PlayerIdentity.player2));
    });
  });

  group('Edge Cases and State Integrity', () {
    test('Cannot execute chess move when awaiting draw', () {
      expect(
        () => turnSystem.executeChessMove(
          ChessMove(from: Position(0,0), to: Position(0,1)), board
        ),
        throwsStateError,
      );
    });

    test('Cannot draw card when awaiting chess move', () {
      turnSystem.drawCard(UnoCard.number(1, UnoColor.red));
      expect(
        () => turnSystem.drawCard(UnoCard.number(2, UnoColor.blue)),
        throwsStateError,
      );
    });

    test('Cannot resolve rainbow when not awaiting rainbow resolution', () {
      expect(
        () => turnSystem.resolveRainbow(UnoEffect.resolve(moves: 1)),
        throwsStateError,
      );
    });

    test('Cannot resolve rainbow to rainbow', () {
      turnSystem.drawCard(UnoCard.rainbow());
      expect(
        () => turnSystem.resolveRainbow(UnoEffect.rainbow),
        throwsArgumentError,
      );
    });
  });
}
