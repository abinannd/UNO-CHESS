import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/chess_color.dart';

void main() {
  group('ChessBoard', () {
    test('empty board contains no pieces', () {
      final board = ChessBoard.empty();
      for (int r = 0; r < 8; r++) {
        for (int f = 0; f < 8; f++) {
          final pos = Position(f, r);
          expect(board.isOccupied(pos), isFalse);
          expect(board.getPieceAt(pos), isNull);
        }
      }
    });

    test('initial board sets up correctly', () {
      final board = ChessBoard.initial();
      
      // Check total pieces
      int whiteCount = 0;
      int blackCount = 0;
      for (int r = 0; r < 8; r++) {
        for (int f = 0; f < 8; f++) {
          final piece = board.getPieceAt(Position(f, r));
          if (piece != null) {
            if (piece.color == ChessColor.white) whiteCount++;
            if (piece.color == ChessColor.black) blackCount++;
          }
        }
      }

      expect(whiteCount, equals(16));
      expect(blackCount, equals(16));
      expect(whiteCount + blackCount, equals(32));

      // Check specific squares
      // White pieces
      expect(board.getPieceAt(Position.fromAlgebraic('e1'))?.type, equals(PieceType.king));
      expect(board.getPieceAt(Position.fromAlgebraic('e1'))?.color, equals(ChessColor.white));
      expect(board.getPieceAt(Position.fromAlgebraic('d1'))?.type, equals(PieceType.queen));
      
      // Black pieces
      expect(board.getPieceAt(Position.fromAlgebraic('e8'))?.type, equals(PieceType.king));
      expect(board.getPieceAt(Position.fromAlgebraic('e8'))?.color, equals(ChessColor.black));
      expect(board.getPieceAt(Position.fromAlgebraic('d8'))?.type, equals(PieceType.queen));
      
      // Pawns
      expect(board.getPieceAt(Position.fromAlgebraic('a2'))?.type, equals(PieceType.pawn));
      expect(board.getPieceAt(Position.fromAlgebraic('h7'))?.type, equals(PieceType.pawn));

      // Empty middle squares
      expect(board.isOccupied(Position.fromAlgebraic('e4')), isFalse);
      expect(board.isOccupied(Position.fromAlgebraic('d5')), isFalse);
    });

    test('placePiece places a piece correctly', () {
      final board = ChessBoard.empty();
      final pos = Position.fromAlgebraic('e4');
      const piece = ChessPiece(PieceType.king, ChessColor.white);
      
      board.placePiece(pos, piece);
      
      expect(board.isOccupied(pos), isTrue);
      expect(board.getPieceAt(pos), equals(piece));
    });

    test('removePiece removes a piece and returns it', () {
      final board = ChessBoard.initial();
      final pos = Position.fromAlgebraic('e2'); // White pawn
      
      final piece = board.removePiece(pos);
      
      expect(piece?.type, equals(PieceType.pawn));
      expect(piece?.color, equals(ChessColor.white));
      expect(board.isOccupied(pos), isFalse);
    });

    test('movePiece moves a piece correctly', () {
      final board = ChessBoard.initial();
      final from = Position.fromAlgebraic('e2');
      final to = Position.fromAlgebraic('e4');
      
      final piece = board.getPieceAt(from);
      board.movePiece(from, to);
      
      expect(board.isOccupied(from), isFalse);
      expect(board.isOccupied(to), isTrue);
      expect(board.getPieceAt(to), equals(piece));
    });
  });
}
