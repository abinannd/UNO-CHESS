import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/move_generator.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('MoveGenerator', () {
    test('Pawn white forward move', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.pawn, ChessColor.white));
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.white);
      
      expect(moves.map((m) => m.to.algebraic), containsAll(['e3', 'e4'])); // 2 moves
    });

    test('Pawn black forward move', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('d7'), const ChessPiece(PieceType.pawn, ChessColor.black));
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.black);
      
      expect(moves.map((m) => m.to.algebraic), containsAll(['d6', 'd5']));
    });

    test('Pawn blocked forward', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e2'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e3'), const ChessPiece(PieceType.pawn, ChessColor.black));
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.white);
      
      expect(moves.isEmpty, isTrue); // blocked
    });

    test('Pawn diagonal capture', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e4'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d5'), const ChessPiece(PieceType.pawn, ChessColor.black));
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.white);
      
      expect(moves.map((m) => m.to.algebraic), contains('d5')); // capture
      expect(moves.map((m) => m.to.algebraic), contains('e5')); // normal forward
    });

    test('Knight jumping and blocking', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('e4'), const ChessPiece(PieceType.knight, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('d6'), const ChessPiece(PieceType.pawn, ChessColor.white)); // friendly
      board.placePiece(Position.fromAlgebraic('f6'), const ChessPiece(PieceType.pawn, ChessColor.black)); // enemy
      
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.white);
      
      final toSquares = moves.map((m) => m.to.algebraic).toList();
      expect(toSquares, isNot(contains('d6'))); // friendly blocked
      expect(toSquares, contains('f6')); // enemy capture
      expect(toSquares, containsAll(['c5', 'g5', 'c3', 'g3', 'd2', 'f2'])); // others
    });

    test('Bishop sliding and blocking', () {
      final board = ChessBoard.empty();
      board.placePiece(Position.fromAlgebraic('c1'), const ChessPiece(PieceType.bishop, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('b2'), const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e3'), const ChessPiece(PieceType.pawn, ChessColor.black));
      
      final generator = MoveGenerator(board);
      final moves = generator.generatePseudoLegalMoves(ChessColor.white);
      
      final toSquares = moves.map((m) => m.to.algebraic).toList();
      expect(toSquares, isNot(contains('a3'))); // blocked by b2 friendly
      expect(toSquares, containsAll(['d2', 'e3']));
      expect(toSquares, isNot(contains('f4'))); // blocked by e3 enemy (captured it though)
    });
  });
}
