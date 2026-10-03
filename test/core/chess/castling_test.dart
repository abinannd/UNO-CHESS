import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('Castling', () {
    ChessBoard createCastlingBoard() {
      final board = ChessBoard.empty();
      board.castlingRights = CastlingRights();
      // White pieces
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('a1'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('h1'), const ChessPiece(PieceType.rook, ChessColor.white));
      // Black pieces
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('a8'), const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('h8'), const ChessPiece(PieceType.rook, ChessColor.black));
      return board;
    }

    test('White king-side castling basic', () {
      final board = createCastlingBoard();
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      
      final castlingMove = moves.where((m) => m.isCastling && m.to.algebraic == 'g1');
      expect(castlingMove.isNotEmpty, isTrue);
    });

    test('White queen-side castling basic', () {
      final board = createCastlingBoard();
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      
      final castlingMove = moves.where((m) => m.isCastling && m.to.algebraic == 'c1');
      expect(castlingMove.isNotEmpty, isTrue);
    });

    test('Black king-side and queen-side basic', () {
      final board = createCastlingBoard();
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.black);
      
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'g8'), isTrue);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'c8'), isTrue);
    });

    test('Cannot castle if path is blocked', () {
      final board = createCastlingBoard();
      // Block white king-side
      board.placePiece(Position.fromAlgebraic('f1'), const ChessPiece(PieceType.bishop, ChessColor.white));
      // Block white queen-side (b1 is blocked)
      board.placePiece(Position.fromAlgebraic('b1'), const ChessPiece(PieceType.knight, ChessColor.white));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'g1'), isFalse);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'c1'), isFalse);
    });

    test('Cannot castle while in check', () {
      final board = createCastlingBoard();
      // Black rook attacking e1
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isCastling), isFalse);
    });

    test('Cannot castle through attacked square', () {
      final board = createCastlingBoard();
      // Black rook attacks f1
      board.placePiece(Position.fromAlgebraic('f8'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'g1'), isFalse);
    });

    test('Cannot castle into attacked square', () {
      final board = createCastlingBoard();
      // Black rook attacks g1
      board.placePiece(Position.fromAlgebraic('g8'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'g1'), isFalse);
    });

    test('King move removes castling rights permanently', () {
      final board = createCastlingBoard();
      board.executeMove(ChessMove(from: Position.fromAlgebraic('e1'), to: Position.fromAlgebraic('f1'))); // move king
      
      final engine = ChessEngine(board);
      expect(board.castlingRights.whiteKingSide, isFalse);
      expect(board.castlingRights.whiteQueenSide, isFalse);
      
      // even if moved back
      board.executeMove(ChessMove(from: Position.fromAlgebraic('f1'), to: Position.fromAlgebraic('e1')));
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isCastling), isFalse);
    });

    test('Rook move removes castling rights on that side', () {
      final board = createCastlingBoard();
      board.executeMove(ChessMove(from: Position.fromAlgebraic('h1'), to: Position.fromAlgebraic('h2'))); // move h1 rook
      
      final engine = ChessEngine(board);
      expect(board.castlingRights.whiteKingSide, isFalse);
      expect(board.castlingRights.whiteQueenSide, isTrue);
      
      final moves = engine.generateLegalMoves(ChessColor.white);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'g1'), isFalse);
      expect(moves.any((m) => m.isCastling && m.to.algebraic == 'c1'), isTrue);
    });

    test('Rook captured removes castling rights', () {
      final board = createCastlingBoard();
      // Black captures White's a1 rook
      board.executeMove(ChessMove(
        from: Position.fromAlgebraic('a8'), 
        to: Position.fromAlgebraic('a1'), 
        capturedPiece: const ChessPiece(PieceType.rook, ChessColor.white)
      ));
      
      expect(board.castlingRights.whiteQueenSide, isFalse);
      expect(board.castlingRights.whiteKingSide, isTrue);
    });

    test('Execution: Both pieces move atomically', () {
      final board = createCastlingBoard();
      board.executeMove(ChessMove(from: Position.fromAlgebraic('e1'), to: Position.fromAlgebraic('g1'), isCastling: true));
      
      expect(board.getPieceAt(Position.fromAlgebraic('e1')), isNull);
      expect(board.getPieceAt(Position.fromAlgebraic('h1')), isNull);
      
      final king = board.getPieceAt(Position.fromAlgebraic('g1'));
      final rook = board.getPieceAt(Position.fromAlgebraic('f1'));
      
      expect(king?.type, equals(PieceType.king));
      expect(rook?.type, equals(PieceType.rook));
    });
  });
}
