import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/revival/captured_piece.dart';
import 'package:uno_chess/core/revival/revival_cost.dart';
import 'package:uno_chess/core/revival/revival_system.dart';

void main() {

  // ── Helpers ──────────────────────────────────────────────────────────────────

  ChessBoard emptyBoard() => ChessBoard.empty();

  RevivalSystem systemWith({int rp = 0, List<CapturedPiece> captured = const []}) =>
      RevivalSystem(revivalPoints: rp, capturedPieces: List.of(captured));

  // ── Revival Costs ─────────────────────────────────────────────────────────
  group('RevivalCost', () {
    test('Pawn costs 1 RP', () => expect(RevivalCost.of(PieceType.pawn), equals(1)));
    test('Knight costs 3 RP', () => expect(RevivalCost.of(PieceType.knight), equals(3)));
    test('Bishop costs 3 RP', () => expect(RevivalCost.of(PieceType.bishop), equals(3)));
    test('Rook costs 5 RP', () => expect(RevivalCost.of(PieceType.rook), equals(5)));
    test('Queen costs 10 RP', () => expect(RevivalCost.of(PieceType.queen), equals(10)));

    test('King throws ArgumentError', () {
      expect(() => RevivalCost.of(PieceType.king), throwsArgumentError);
    });

    test('isRevivable false for King', () {
      expect(RevivalCost.isRevivable(PieceType.king), isFalse);
    });

    test('isRevivable true for all non-King types', () {
      for (final t in [PieceType.pawn, PieceType.knight, PieceType.bishop,
                       PieceType.rook, PieceType.queen]) {
        expect(RevivalCost.isRevivable(t), isTrue);
      }
    });
  });

  // ── addRevivalPoints ──────────────────────────────────────────────────────
  group('RevivalSystem — RP management', () {
    test('Starts at 0 RP by default', () {
      expect(RevivalSystem().revivalPoints, equals(0));
    });

    test('addRevivalPoints accumulates correctly', () {
      final sys = RevivalSystem();
      sys.addRevivalPoints(2);
      sys.addRevivalPoints(4);
      expect(sys.revivalPoints, equals(6));
    });
  });

  // ── recordCapture ─────────────────────────────────────────────────────────
  group('RevivalSystem — capture recording', () {
    test('Records a captured piece', () {
      final sys = RevivalSystem();
      sys.recordCapture(PieceType.pawn, ChessColor.white);
      expect(sys.capturedPieces, contains(const CapturedPiece(PieceType.pawn, ChessColor.white)));
    });

    test('King capture is silently ignored', () {
      final sys = RevivalSystem();
      sys.recordCapture(PieceType.king, ChessColor.white);
      expect(sys.capturedPieces, isEmpty);
    });

    test('Multiple captures are all tracked', () {
      final sys = RevivalSystem();
      sys.recordCapture(PieceType.pawn, ChessColor.white);
      sys.recordCapture(PieceType.rook, ChessColor.white);
      sys.recordCapture(PieceType.pawn, ChessColor.white);
      expect(sys.capturedPieces.length, equals(3));
    });
  });

  // ── availableSpawnSquares ─────────────────────────────────────────────────
  group('RevivalSystem — spawn squares', () {
    test('White pawn spawns on rank 2 (all 8 files when empty)', () {
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.pawn, ChessColor.white, emptyBoard());
      expect(squares.length, equals(8));
      expect(squares.every((p) => p.rank == 1), isTrue);
    });

    test('Black pawn spawns on rank 7 (all 8 files when empty)', () {
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.pawn, ChessColor.black, emptyBoard());
      expect(squares.length, equals(8));
      expect(squares.every((p) => p.rank == 6), isTrue);
    });

    test('White rook spawns: a1 and h1', () {
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.rook, ChessColor.white, emptyBoard());
      expect(squares, containsAll([Position.fromAlgebraic('a1'), Position.fromAlgebraic('h1')]));
    });

    test('Black rook spawns: a8 and h8', () {
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.rook, ChessColor.black, emptyBoard());
      expect(squares, containsAll([Position.fromAlgebraic('a8'), Position.fromAlgebraic('h8')]));
    });

    test('Occupied square not returned as available', () {
      final board = emptyBoard();
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.rook, ChessColor.white, board);
      expect(squares, isNot(contains(Position.fromAlgebraic('a1'))));
      expect(squares, contains(Position.fromAlgebraic('h1')));
    });

    test('All spawn squares occupied → empty list', () {
      final board = emptyBoard();
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      final sys = RevivalSystem();
      final squares = sys.availableSpawnSquares(PieceType.rook, ChessColor.white, board);
      expect(squares, isEmpty);
    });

    test('King returns empty spawn squares', () {
      final sys = RevivalSystem();
      expect(sys.availableSpawnSquares(PieceType.king, ChessColor.white, emptyBoard()), isEmpty);
    });
  });

  // ── canRevive ─────────────────────────────────────────────────────────────
  group('RevivalSystem — canRevive', () {
    test('Returns true when all conditions met', () {
      final sys = systemWith(
        rp: 5,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      expect(sys.canRevive(PieceType.rook, ChessColor.white, emptyBoard()), isTrue);
    });

    test('False when insufficient RP', () {
      final sys = systemWith(
        rp: 4,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      expect(sys.canRevive(PieceType.rook, ChessColor.white, emptyBoard()), isFalse);
    });

    test('False when piece not captured', () {
      final sys = systemWith(rp: 10);
      expect(sys.canRevive(PieceType.queen, ChessColor.white, emptyBoard()), isFalse);
    });

    test('False when all spawn squares occupied', () {
      final board = emptyBoard();
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      final sys = systemWith(
        rp: 5,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      expect(sys.canRevive(PieceType.rook, ChessColor.white, board), isFalse);
    });

    test('False for King regardless', () {
      final sys = systemWith(rp: 100);
      expect(sys.canRevive(PieceType.king, ChessColor.white, emptyBoard()), isFalse);
    });
  });

  // ── revive — success ──────────────────────────────────────────────────────
  group('RevivalSystem — revive success', () {
    void testRevival(PieceType type, ChessColor color, String square) {
      test('${color.name} ${type.name} revived onto $square', () {
        final board = emptyBoard();
        final cost = RevivalCost.of(type);
        final sys = systemWith(
          rp: cost,
          captured: [CapturedPiece(type, color)],
        );
        final pos = Position.fromAlgebraic(square);
        sys.revive(type, color, pos, board);

        // Piece placed on board
        expect(board.getPieceAt(pos)?.type, equals(type));
        expect(board.getPieceAt(pos)?.color, equals(color));
        // RP deducted
        expect(sys.revivalPoints, equals(0));
        // Removed from captured list
        expect(sys.capturedPieces, isEmpty);
      });
    }

    testRevival(PieceType.pawn,   ChessColor.white, 'e2');
    testRevival(PieceType.knight, ChessColor.white, 'b1');
    testRevival(PieceType.bishop, ChessColor.white, 'c1');
    testRevival(PieceType.rook,   ChessColor.white, 'a1');
    testRevival(PieceType.queen,  ChessColor.white, 'd1');
    testRevival(PieceType.pawn,   ChessColor.black, 'e7');
    testRevival(PieceType.knight, ChessColor.black, 'b8');
    testRevival(PieceType.bishop, ChessColor.black, 'c8');
    testRevival(PieceType.rook,   ChessColor.black, 'a8');
    testRevival(PieceType.queen,  ChessColor.black, 'd8');
  });

  // ── revive — rejection ────────────────────────────────────────────────────
  group('RevivalSystem — revive rejection', () {
    test('King cannot be revived', () {
      final sys = systemWith(rp: 100);
      expect(
        () => sys.revive(PieceType.king, ChessColor.white, Position.fromAlgebraic('e1'), emptyBoard()),
        throwsA(isA<RevivalException>()),
      );
    });

    test('Insufficient RP throws RevivalException', () {
      final sys = systemWith(
        rp: 4,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      expect(
        () => sys.revive(PieceType.rook, ChessColor.white, Position.fromAlgebraic('a1'), emptyBoard()),
        throwsA(isA<RevivalException>()),
      );
    });

    test('Never-captured piece throws RevivalException', () {
      final sys = systemWith(rp: 10);
      expect(
        () => sys.revive(PieceType.queen, ChessColor.white, Position.fromAlgebraic('d1'), emptyBoard()),
        throwsA(isA<RevivalException>()),
      );
    });

    test('Invalid spawn square throws RevivalException', () {
      final sys = systemWith(
        rp: 5,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      // e4 is not a valid spawn for a white rook
      expect(
        () => sys.revive(PieceType.rook, ChessColor.white, Position.fromAlgebraic('e4'), emptyBoard()),
        throwsA(isA<RevivalException>()),
      );
    });

    test('Occupied spawn square throws RevivalException', () {
      final board = emptyBoard();
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      final sys = systemWith(
        rp: 5,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      expect(
        () => sys.revive(PieceType.rook, ChessColor.white, Position.fromAlgebraic('a1'), board),
        throwsA(isA<RevivalException>()),
      );
    });

    test('Alternative spawn square used when first is occupied', () {
      final board = emptyBoard();
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      final sys = systemWith(
        rp: 5,
        captured: [const CapturedPiece(PieceType.rook, ChessColor.white)],
      );
      // h1 is still free
      sys.revive(PieceType.rook, ChessColor.white, Position.fromAlgebraic('h1'), board);
      expect(board.getPieceAt(Position.fromAlgebraic('h1'))?.type, equals(PieceType.rook));
    });
  });

  // ── Multiple revivals / ordering ──────────────────────────────────────────
  group('RevivalSystem — multiple revivals', () {
    test('Pieces can be revived in any order', () {
      final board = emptyBoard();
      final sys = systemWith(
        rp: 16, // queen(10) + rook(5) + pawn(1) = 16
        captured: [
          const CapturedPiece(PieceType.rook,  ChessColor.white),
          const CapturedPiece(PieceType.pawn,  ChessColor.white),
          const CapturedPiece(PieceType.queen, ChessColor.white),
        ],
      );

      // Revive queen first (most expensive), then pawn, then rook
      sys.revive(PieceType.queen, ChessColor.white, Position.fromAlgebraic('d1'), board);
      sys.revive(PieceType.pawn,  ChessColor.white, Position.fromAlgebraic('a2'), board);
      sys.revive(PieceType.rook,  ChessColor.white, Position.fromAlgebraic('a1'), board);

      expect(sys.capturedPieces, isEmpty);
      expect(sys.revivalPoints, equals(0)); // 16 - 10 - 1 - 5 = 0
      expect(board.getPieceAt(Position.fromAlgebraic('d1'))?.type, equals(PieceType.queen));
      expect(board.getPieceAt(Position.fromAlgebraic('a2'))?.type, equals(PieceType.pawn));
      expect(board.getPieceAt(Position.fromAlgebraic('a1'))?.type, equals(PieceType.rook));
    });

    test('No duplicate piece creation — only one captured piece consumed per revival', () {
      final board = emptyBoard();
      final sys = systemWith(
        rp: 10,
        captured: [const CapturedPiece(PieceType.pawn, ChessColor.white)],
      );
      sys.revive(PieceType.pawn, ChessColor.white, Position.fromAlgebraic('a2'), board);
      // Only 1 pawn was captured — cannot revive a second one
      expect(
        () => sys.revive(PieceType.pawn, ChessColor.white, Position.fromAlgebraic('b2'), board),
        throwsA(isA<RevivalException>()),
      );
    });
  });
}
