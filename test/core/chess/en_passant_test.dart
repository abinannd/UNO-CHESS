import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('En Passant', () {
    // ── BASIC ──────────────────────────────────────────────────────────

    test('White en passant: basic capture', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // Simulate black pawn just double-stepped d7→d5
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      final epMoves = moves.where((m) => m.isEnPassant && m.to.algebraic == 'd6');
      expect(epMoves.isNotEmpty, isTrue, reason: 'White should have en passant to d6');
    });

    test('Black en passant: basic capture', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e4'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d4'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // Simulate white pawn just double-stepped d2→d4
      board.enPassantTarget = Position.fromAlgebraic('d3');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.black);
      final epMoves = moves.where((m) => m.isEnPassant && m.to.algebraic == 'd3');
      expect(epMoves.isNotEmpty, isTrue, reason: 'Black should have en passant to d3');
    });

    // ── NO DOUBLE STEP → NO EP ─────────────────────────────────────────

    test('No en passant when enPassantTarget is null', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // enPassantTarget is null — no double step happened just now

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant), isFalse);
    });

    // ── EXPIRATION ─────────────────────────────────────────────────────

    test('En passant expires after opponent plays another move via executeMove', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      // White plays a different move (king move), which clears enPassantTarget
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e1'),
        to: Position.fromAlgebraic('f1'),
      ));

      expect(board.enPassantTarget, isNull);

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant), isFalse);
    });

    // ── WRONG RANK ─────────────────────────────────────────────────────

    test('No en passant when capturing pawn is on wrong rank (White pawn at e4)', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e4'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // epTarget points to d6, but white pawn is at e4, not e5
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant), isFalse);
    });

    // ── TOO FAR AWAY ───────────────────────────────────────────────────

    test('No en passant when capturing pawn is too far away (wrong file)', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('a5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant), isFalse);
    });

    // ── SAME COLOR ─────────────────────────────────────────────────────

    test('No en passant when adjacent pawn is same color', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      // Put a white pawn where black should be
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant), isFalse);
    });

    // ── EXECUTION ──────────────────────────────────────────────────────

    test('En passant: pawn reaches destination and captured pawn is removed', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final capturedPawn = board.getPieceAt(Position.fromAlgebraic('d5'));
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e5'),
        to: Position.fromAlgebraic('d6'),
        capturedPiece: capturedPawn,
        isEnPassant: true,
      ));

      // White pawn moved to d6
      final whitePawn = board.getPieceAt(Position.fromAlgebraic('d6'));
      expect(whitePawn?.type, equals(PieceType.pawn));
      expect(whitePawn?.color, equals(ChessColor.white));

      // e5 vacated
      expect(board.getPieceAt(Position.fromAlgebraic('e5')), isNull);

      // Black pawn removed from d5 (NOT d6)
      expect(board.getPieceAt(Position.fromAlgebraic('d5')), isNull);
    });

    test('Black en passant: captured white pawn removed from d4', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e4'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d4'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d3');

      final capturedPawn = board.getPieceAt(Position.fromAlgebraic('d4'));
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('e4'),
        to: Position.fromAlgebraic('d3'),
        capturedPiece: capturedPawn,
        isEnPassant: true,
      ));

      expect(board.getPieceAt(Position.fromAlgebraic('d3'))?.color, equals(ChessColor.black));
      expect(board.getPieceAt(Position.fromAlgebraic('e4')), isNull);
      expect(board.getPieceAt(Position.fromAlgebraic('d4')), isNull); // captured pawn removed
    });

    // ── EN PASSANT TARGET SET BY executeMove ───────────────────────────

    test('executeMove sets enPassantTarget on double-step pawn move', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('d2'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('d2'),
        to: Position.fromAlgebraic('d4'),
      ));

      expect(board.enPassantTarget, isNotNull);
      expect(board.enPassantTarget!.algebraic, equals('d3'));
    });

    test('executeMove clears enPassantTarget on non-double-step move', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('d3'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6'); // pre-existing

      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('d3'),
        to: Position.fromAlgebraic('d4'),
      ));

      expect(board.enPassantTarget, isNull);
    });

    // ── KING SAFETY / DISCOVERED CHECK ────────────────────────────────

    test('En passant that exposes own King to rook attack is illegal', () {
      // Position: White King on e5, White pawn on d5, Black pawn on c5
      //           Black rook on a5 — after EP d5xc6, d5 and c5 both vacate rank 5,
      //           opening the file from a5 through to e5 → King exposed.
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('c5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('a5'), const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      // Black pawn just double-stepped c7→c5
      board.enPassantTarget = Position.fromAlgebraic('c6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      // The EP move d5xc6 would expose the White King on e5 to Black rook on a5
      expect(moves.any((m) => m.isEnPassant && m.to.algebraic == 'c6'), isFalse,
          reason: 'En passant that exposes the King must be rejected');
    });

    test('Valid en passant remains legal when King safety preserved', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isEnPassant && m.to.algebraic == 'd6'), isTrue);
    });

    // ── CLONE PRESERVES EP STATE ───────────────────────────────────────

    test('Board clone preserves enPassantTarget', () {
      final board = ChessBoard.empty();
      board.enPassantTarget = Position.fromAlgebraic('e6');
      final cloned = board.clone();
      expect(cloned.enPassantTarget?.algebraic, equals('e6'));
    });

    test('Simulated clone does not alter real board enPassantTarget', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e5'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.enPassantTarget = Position.fromAlgebraic('d6');

      // Simulate ep move on clone
      final cloned = board.clone();
      final capturedPawn = cloned.getPieceAt(Position.fromAlgebraic('d5'));
      cloned.executeMove(ChessMove(
        from: Position.fromAlgebraic('e5'),
        to: Position.fromAlgebraic('d6'),
        capturedPiece: capturedPawn,
        isEnPassant: true,
      ));

      // Real board must be untouched
      expect(board.enPassantTarget?.algebraic, equals('d6'));
      expect(board.getPieceAt(Position.fromAlgebraic('d5')), isNotNull);
      expect(board.getPieceAt(Position.fromAlgebraic('e5')), isNotNull);
    });
  });
}
