import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/chess_color.dart';

void main() {
  group('ChessMove', () {
    test('creates move with basic positions', () {
      final move = ChessMove(
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e4'),
      );
      
      expect(move.from.algebraic, equals('e2'));
      expect(move.to.algebraic, equals('e4'));
      expect(move.capturedPiece, isNull);
      expect(move.promotion, isNull);
    });

    test('creates move with capture and promotion', () {
      const captured = ChessPiece(PieceType.queen, ChessColor.black);
      final move = ChessMove(
        from: Position.fromAlgebraic('d7'),
        to: Position.fromAlgebraic('c8'),
        capturedPiece: captured,
        promotion: PieceType.queen,
      );

      expect(move.capturedPiece, equals(captured));
      expect(move.promotion, equals(PieceType.queen));
    });
  });
}
