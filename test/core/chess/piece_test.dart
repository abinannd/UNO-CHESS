import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/chess_color.dart';

void main() {
  group('ChessPiece', () {
    test('creates piece correctly', () {
      const piece = ChessPiece(PieceType.king, ChessColor.white);
      expect(piece.type, equals(PieceType.king));
      expect(piece.color, equals(ChessColor.white));
    });

    test('equality works correctly', () {
      const p1 = ChessPiece(PieceType.queen, ChessColor.black);
      const p2 = ChessPiece(PieceType.queen, ChessColor.black);
      const p3 = ChessPiece(PieceType.queen, ChessColor.white);
      const p4 = ChessPiece(PieceType.king, ChessColor.black);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1, isNot(equals(p4)));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('toString returns meaningful output', () {
      const piece = ChessPiece(PieceType.rook, ChessColor.white);
      expect(piece.toString(), contains('white'));
      expect(piece.toString(), contains('rook'));
    });
  });
}
