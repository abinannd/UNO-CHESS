import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('Promotion', () {

    ChessBoard basicPromoBoard() {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      return board;
    }

    // ── MOVE GENERATION ───────────────────────────────────────────────

    test('White pawn on e7 generates exactly 4 promotion moves', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      // Need to move black king out of the way first
      board.removePiece(Position.fromAlgebraic('e8'));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      final promoMoves = moves.where((m) => m.from.algebraic == 'e7' && m.promotion != null).toList();

      expect(promoMoves.length, equals(4));
      expect(promoMoves.map((m) => m.promotion).toSet(),
          equals({PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight}));
    });

    test('Black pawn on e2 generates exactly 4 promotion moves', () {
      final board = basicPromoBoard();
      board.removePiece(Position.fromAlgebraic('e1'));
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.pawn, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.black);
      final promoMoves = moves.where((m) => m.from.algebraic == 'e2' && m.promotion != null).toList();

      expect(promoMoves.length, equals(4));
    });

    test('No unpromoted pawn move is generated for final rank', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.removePiece(Position.fromAlgebraic('e8'));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      // No move to e8 without a promotion type
      expect(moves.any((m) => m.to.algebraic == 'e8' && m.promotion == null), isFalse);
    });

    // ── ALL 4 PIECE TYPES ─────────────────────────────────────────────

    for (final pt in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
      test('White promotion to ${pt.name} replaces pawn correctly', () {
        final board = basicPromoBoard();
        board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
        board.removePiece(Position.fromAlgebraic('e8'));
        board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

        board.executeMove(ChessMove(
          from: Position.fromAlgebraic('e7'),
          to: Position.fromAlgebraic('e8'),
          promotion: pt,
        ));

        final promoted = board.getPieceAt(Position.fromAlgebraic('e8'));
        expect(promoted?.type, equals(pt));
        expect(promoted?.color, equals(ChessColor.white));
        expect(board.getPieceAt(Position.fromAlgebraic('e7')), isNull);
      });

      test('Black promotion to ${pt.name} replaces pawn correctly', () {
        final board = basicPromoBoard();
        board.removePiece(Position.fromAlgebraic('e1'));
        board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.king, ChessColor.white));
        board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.pawn, ChessColor.black));

        board.executeMove(ChessMove(
          from: Position.fromAlgebraic('e2'),
          to: Position.fromAlgebraic('e1'),
          promotion: pt,
        ));

        final promoted = board.getPieceAt(Position.fromAlgebraic('e1'));
        expect(promoted?.type, equals(pt));
        expect(promoted?.color, equals(ChessColor.black));
      });
    }

    // ── PROMOTION CAPTURE ─────────────────────────────────────────────

    test('White promotion capture: pawn captures to d8 promoting to Queen', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.removePiece(Position.fromAlgebraic('e8'));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d8'), const ChessPiece(PieceType.rook, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      final captureMoves = moves.where((m) =>
          m.from.algebraic == 'e7' && m.to.algebraic == 'd8' && m.promotion != null).toList();

      expect(captureMoves.length, equals(4));

      // Execute Queen promotion capture
      final capturedPiece = board.getPieceAt(Position.fromAlgebraic('d8'));
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('d8'),
        capturedPiece: capturedPiece,
        promotion: PieceType.queen,
      ));

      expect(board.getPieceAt(Position.fromAlgebraic('d8'))?.type, equals(PieceType.queen));
      expect(board.getPieceAt(Position.fromAlgebraic('d8'))?.color, equals(ChessColor.white));
      expect(board.getPieceAt(Position.fromAlgebraic('e7')), isNull);
    });

    test('Black promotion capture: pawn captures to d1 promoting to Knight', () {
      final board = basicPromoBoard();
      board.removePiece(Position.fromAlgebraic('e1'));
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d1'), const ChessPiece(PieceType.rook, ChessColor.white));

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('d1'),
        capturedPiece: const ChessPiece(PieceType.rook, ChessColor.white),
        promotion: PieceType.knight,
      ));

      expect(board.getPieceAt(Position.fromAlgebraic('d1'))?.type, equals(PieceType.knight));
      expect(board.getPieceAt(Position.fromAlgebraic('d1'))?.color, equals(ChessColor.black));
      expect(board.getPieceAt(Position.fromAlgebraic('e2')), isNull);
    });

    // ── INVALID PROMOTION NOT GENERATED ──────────────────────────────

    test('Pawn not on final rank does not produce promotion moves', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.promotion != null), isFalse);
    });

    test('King and Pawn do not appear as promotion choices', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.removePiece(Position.fromAlgebraic('e8'));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      final promoTypes = moves.where((m) => m.promotion != null).map((m) => m.promotion!).toSet();

      expect(promoTypes.contains(PieceType.king), isFalse);
      expect(promoTypes.contains(PieceType.pawn), isFalse);
    });

    // ── KING SAFETY ───────────────────────────────────────────────────

    test('Promotion that leaves own King in check is illegal', () {
      // White King on e1, White pawn on e7, Black rook on e2 pinning pawn vertically
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      // Pawn is pinned — no pawn moves should be legal
      expect(moves.any((m) => m.from.algebraic == 'e7'), isFalse);
    });

    // ── CHECKMATE VIA PROMOTION ───────────────────────────────────────

    test('Promotion can produce checkmate', () {
      // Black King on a8. White pawn on b7 promotes to Queen on b8.
      // White Rook on b1 defends b8 (so King cannot capture).
      // White King on c6 covers a7 and c7.
      // Result: Black King on a8 is in check from Qb8, cannot escape → checkmate.
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('b7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('b1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('c6'), const ChessPiece(PieceType.king, ChessColor.white));

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('b7'),
        to: Position.fromAlgebraic('b8'),
        promotion: PieceType.queen,
      ));

      final engine = ChessEngine(board);
      expect(engine.isCheckmate(ChessColor.black), isTrue);
    });

    // ── CLONE SIMULATION ──────────────────────────────────────────────

    test('Promotion in clone does not affect real board', () {
      final board = basicPromoBoard();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.removePiece(Position.fromAlgebraic('e8'));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));

      final cloned = board.clone();
      cloned.executeMove(ChessMove(
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('e8'),
        promotion: PieceType.queen,
      ));

      // Cloned board has queen
      expect(cloned.getPieceAt(Position.fromAlgebraic('e8'))?.type, equals(PieceType.queen));
      // Real board still has pawn at e7
      expect(board.getPieceAt(Position.fromAlgebraic('e7'))?.type, equals(PieceType.pawn));
      expect(board.getPieceAt(Position.fromAlgebraic('e8')), isNull);
    });
  });
}
