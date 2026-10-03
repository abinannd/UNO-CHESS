import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/game/player_identity.dart';
import 'package:uno_chess/core/game/player_state.dart';
import 'package:uno_chess/core/revival/captured_piece.dart';
import 'package:uno_chess/core/revival/revival_system.dart';

void main() {
  group('PlayerState Initial State', () {
    test('initialPlayer1 creates correct state for Player 1', () {
      final state = PlayerState.initialPlayer1();
      expect(state.identity, equals(PlayerIdentity.player1));
      expect(state.controlledColor, equals(ChessColor.white));
      expect(state.revivalPoints, equals(0));
      expect(state.capturedPieces, isEmpty);
      expect(state.revivalSystem, isNotNull);
    });

    test('initialPlayer2 creates correct state for Player 2', () {
      final state = PlayerState.initialPlayer2();
      expect(state.identity, equals(PlayerIdentity.player2));
      expect(state.controlledColor, equals(ChessColor.black));
      expect(state.revivalPoints, equals(0));
      expect(state.capturedPieces, isEmpty);
      expect(state.revivalSystem, isNotNull);
    });

    test('Custom initial state creates correct state', () {
      final sys = RevivalSystem();
      final state = PlayerState(
        identity: PlayerIdentity.player1,
        controlledColor: ChessColor.black,
        revivalSystem: sys,
      );
      expect(state.identity, equals(PlayerIdentity.player1));
      expect(state.controlledColor, equals(ChessColor.black));
      expect(identical(state.revivalSystem, sys), isTrue);
    });
  });

  group('PlayerState Independence', () {
    test('Player 1 and Player 2 are completely independent', () {
      final p1 = PlayerState.initialPlayer1();
      final p2 = PlayerState.initialPlayer2();

      p1.revivalSystem.addRevivalPoints(4);
      p2.revivalSystem.recordCapture(PieceType.rook, ChessColor.black);

      expect(p1.revivalPoints, equals(4));
      expect(p1.capturedPieces, isEmpty);

      expect(p2.revivalPoints, equals(0));
      expect(p2.capturedPieces, hasLength(1));
    });
  });

  group('PlayerState Copy and Reverse Compatibility', () {
    test('copyWith can swap controlled color', () {
      final p1 = PlayerState.initialPlayer1();
      p1.revivalSystem.addRevivalPoints(2);

      // Simulate a Reverse card: identity is same, color swaps.
      final p1Reversed = p1.copyWith(controlledColor: ChessColor.black);

      expect(p1Reversed.identity, equals(PlayerIdentity.player1));
      expect(p1Reversed.controlledColor, equals(ChessColor.black));
      // Ensures the RevivalSystem is carried over by reference.
      expect(identical(p1Reversed.revivalSystem, p1.revivalSystem), isTrue);
      expect(p1Reversed.revivalPoints, equals(2));
    });

    test('copyWith updates specified fields only', () {
      final original = PlayerState.initialPlayer1();
      final sys = RevivalSystem()..addRevivalPoints(10);
      
      final copy = original.copyWith(
        identity: PlayerIdentity.player2,
        revivalSystem: sys,
      );

      expect(copy.identity, equals(PlayerIdentity.player2));
      expect(copy.controlledColor, equals(ChessColor.white));
      expect(copy.revivalPoints, equals(10));
    });
  });

  group('PlayerState Integration with RevivalSystem', () {
    test('RP accumulation reflects correctly', () {
      final p1 = PlayerState.initialPlayer1();
      p1.revivalSystem.addRevivalPoints(4);
      expect(p1.revivalPoints, equals(4));
    });

    test('Captured pieces record properly', () {
      final p2 = PlayerState.initialPlayer2();
      p2.revivalSystem.recordCapture(PieceType.queen, ChessColor.black);
      
      expect(p2.capturedPieces, contains(const CapturedPiece(PieceType.queen, ChessColor.black)));
      expect(p2.capturedPieces, hasLength(1));
    });
  });

  group('PlayerState Equality and toString', () {
    test('Equality relies on identity, color, and revivalSystem reference', () {
      final sys = RevivalSystem();
      final pA = PlayerState(
        identity: PlayerIdentity.player1,
        controlledColor: ChessColor.white,
        revivalSystem: sys,
      );
      final pB = PlayerState(
        identity: PlayerIdentity.player1,
        controlledColor: ChessColor.white,
        revivalSystem: sys,
      );

      expect(pA, equals(pB));

      final pC = PlayerState.initialPlayer1(); // Different revivalSystem instance
      expect(pA, isNot(equals(pC)));
    });

    test('toString provides meaningful output', () {
      final state = PlayerState.initialPlayer1();
      state.revivalSystem.addRevivalPoints(2);
      expect(state.toString(), contains('PlayerState'));
      expect(state.toString(), contains('player1'));
      expect(state.toString(), contains('white'));
      expect(state.toString(), contains('RP: 2'));
      expect(state.toString(), contains('Captured: 0'));
    });
  });
}
