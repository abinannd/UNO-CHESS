import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('ChessEngine', () {
    test('King cannot move into check', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      
      final toSquares = moves.map((m) => m.to.algebraic).toList();
      // rook is on e-file, king cannot move to e2
      expect(toSquares, isNot(contains('e2')));
      // king can move to d1, f1, d2, f2
      expect(toSquares, containsAll(['d1', 'f1', 'd2', 'f2']));
    });

    test('Pinned piece cannot move', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.rook, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.white);
      
      final rookMoves = moves.where((m) => m.from.algebraic == 'e2').toList();
      
      // Rook can only move along the pin (e3...e7) or capture on e8
      final toSquares = rookMoves.map((m) => m.to.algebraic).toList();
      expect(toSquares, containsAll(['e3', 'e4', 'e5', 'e6', 'e7', 'e8']));
      expect(toSquares, isNot(contains('d2'))); // Cannot move horizontally
      expect(toSquares, isNot(contains('f2')));
    });

    test('Check detection works', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'), const ChessPiece(PieceType.rook, ChessColor.black)); // checking
      
      final engine = ChessEngine(board);
      expect(engine.isInCheck(ChessColor.white), isTrue);
      expect(engine.isInCheck(ChessColor.black), isFalse);
    });

    test('Cannot capture King directly', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e1'), const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.rook, ChessColor.black));
      
      final engine = ChessEngine(board);
      final moves = engine.generateLegalMoves(ChessColor.black);
      
      // Rook on e2 should not have e1 as a capture move
      final rookMoves = moves.where((m) => m.from.algebraic == 'e2');
      expect(rookMoves.map((m) => m.to.algebraic), isNot(contains('e1')));
    });
  });
}
