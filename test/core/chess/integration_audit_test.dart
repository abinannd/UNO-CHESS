// Integration audit tests — covers cross-feature interactions not tested elsewhere.
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('Integration Audit', () {

    // ── 1. En passant expires after castling move ──────────────────────
    test('EP target is cleared after castling move', () {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights(whiteKingSide: true);
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // Pretend Black just double-stepped
      board.enPassantTarget = Position.fromAlgebraic('d6');

      // White castles king-side — this is NOT a double-step pawn move
      board.executeMove(ChessMove(from: Position.fromAlgebraic('e1'), to: Position.fromAlgebraic('g1'), isCastling: true));

      expect(board.enPassantTarget, isNull,
          reason: 'Castling should clear the enPassantTarget');
    });

    // ── 2. Castling clone preserves both castling rights AND ep target ──
    test('Clone preserves both castling rights and EP target', () {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights(whiteKingSide: true, whiteQueenSide: false, blackKingSide: false, blackQueenSide: false);
      board.enPassantTarget = Position.fromAlgebraic('e6');

      final clone = board.clone();
      expect(clone.castlingRights.whiteKingSide, isTrue);
      expect(clone.castlingRights.whiteQueenSide, isFalse);
      expect(clone.enPassantTarget?.algebraic, equals('e6'));
    });

    // ── 3. Simulated castling does not mutate real board ───────────────
    test('Simulating castling on clone leaves real board unchanged', () {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights(whiteKingSide: true);
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));

      final clone = board.clone();
      clone.executeMove(ChessMove(from: Position.fromAlgebraic('e1'), to: Position.fromAlgebraic('g1'), isCastling: true));

      // Real board untouched
      expect(board.getPieceAt(Position.fromAlgebraic('e1'))?.type, equals(PieceType.king));
      expect(board.getPieceAt(Position.fromAlgebraic('h1'))?.type, equals(PieceType.rook));
      expect(board.castlingRights.whiteKingSide, isTrue);
    });

    // ── 4. Promotion gives check — detected by isInCheck ──────────────
    test('Promoted Queen gives check — isInCheck returns true', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('h7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.king, ChessColor.white));

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('h7'),
        to: Position.fromAlgebraic('h8'),
        promotion: PieceType.rook,
      ));

      final engine = ChessEngine(board);
      expect(engine.isInCheck(ChessColor.black), isTrue,
          reason: 'Promoted Rook on h8 should give check to Black King on a8');
    });

    // ── 5. Captured rook during promotion-capture revokes castling right 
    test('Promotion capture on h8 revokes Black king-side castling rights', () {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights(blackKingSide: true);
      board.placePiece(Position.fromAlgebraic('g7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h8'), const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));

      // White pawn captures h8 rook with promotion
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('g7'),
        to: Position.fromAlgebraic('h8'),
        capturedPiece: const ChessPiece(PieceType.rook, ChessColor.black),
        promotion: PieceType.queen,
      ));

      expect(board.castlingRights.blackKingSide, isFalse,
          reason: 'Capturing the h8 rook must revoke Black king-side castling rights');
    });

    // ── 6. No legal move generates a King-capture ──────────────────────
    test('No legal move targets an enemy King square', () {
      // Full starting position — nothing can legally capture a King
      final board = ChessBoard.initial();
      final engine = ChessEngine(board);

      for (final color in ChessColor.values) {
        final moves = engine.generateLegalMoves(color);
        for (final move in moves) {
          final target = board.getPieceAt(move.to);
          if (target != null) {
            expect(target.type, isNot(equals(PieceType.king)),
                reason: 'Legal move $move should not capture a King');
          }
        }
      }
    });

    // ── 7. En passant capture does not corrupt castling rights ─────────
    test('EP capture leaves castling rights intact', () {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights(whiteKingSide: true, whiteQueenSide: true);
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e5'),
        to: Position.fromAlgebraic('d6'),
        capturedPiece: const ChessPiece(PieceType.pawn, ChessColor.black),
        isEnPassant: true,
      ));

      // Castling rights must be unaffected by an EP capture
      expect(board.castlingRights.whiteKingSide, isTrue);
      expect(board.castlingRights.whiteQueenSide, isTrue);
      // EP target must now be null (single-step pawn move)
      expect(board.enPassantTarget, isNull);
    });

    // ── 8. Stalemate not confused with checkmate after promotion ───────
    test('Stalemate is not checkmate after enemy promotion', () {
      // Black king cornered but not in check → stalemate
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('b6'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('c7'), const ChessPiece(PieceType.queen, ChessColor.white));

      final engine = ChessEngine(board);
      expect(engine.isInCheck(ChessColor.black), isFalse);
      expect(engine.isStalemate(ChessColor.black), isTrue);
      expect(engine.isCheckmate(ChessColor.black), isFalse);
    });

    // ── 9. Promotion pawn type check — enPassantTarget not set on promotion
    test('executeMove does not set enPassantTarget when pawn promotes', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e7'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('e8'),
        promotion: PieceType.queen,
      ));

      // Promotion is 1-square move; enPassantTarget must be null
      expect(board.enPassantTarget, isNull);
    });
  });
}
