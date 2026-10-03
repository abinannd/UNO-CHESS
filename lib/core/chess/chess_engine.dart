import 'board.dart';
import 'chess_color.dart';
import 'chess_move.dart';
import 'move_generator.dart';
import 'piece_type.dart';
import 'position.dart';

class ChessEngine {
  final ChessBoard board;

  ChessEngine(this.board);

  List<ChessMove> generateLegalMoves(ChessColor color) {
    final generator = MoveGenerator(board);
    final pseudoMoves = generator.generatePseudoLegalMoves(color);
    
    return pseudoMoves.where((move) {
      // Simulate move
      final simulatedBoard = board.clone();
      simulatedBoard.executeMove(move);
      
      // Find our king
      Position? kingPos;
      for (int r = 0; r < 8; r++) {
        for (int f = 0; f < 8; f++) {
          final p = simulatedBoard.getPieceAt(Position(f, r));
          if (p != null && p.color == color && p.type == PieceType.king) {
            kingPos = Position(f, r);
            break;
          }
        }
        if (kingPos != null) break;
      }
      
      if (kingPos == null) return false; // Should not happen in normal chess
      
      // Check if king is safe
      final simGenerator = MoveGenerator(simulatedBoard);
      return !simGenerator.isSquareAttacked(kingPos, color.opponent);
    }).toList();
  }
  
  bool isInCheck(ChessColor color) {
    Position? kingPos;
    for (int r = 0; r < 8; r++) {
      for (int f = 0; f < 8; f++) {
        final p = board.getPieceAt(Position(f, r));
        if (p != null && p.color == color && p.type == PieceType.king) {
          kingPos = Position(f, r);
          break;
        }
      }
      if (kingPos != null) break;
    }
    if (kingPos == null) return false;
    
    final generator = MoveGenerator(board);
    return generator.isSquareAttacked(kingPos, color.opponent);
  }
  
  bool hasLegalMoves(ChessColor color) {
    return generateLegalMoves(color).isNotEmpty;
  }
  
  bool isSquareAttacked(Position pos, ChessColor attackingColor) {
    return MoveGenerator(board).isSquareAttacked(pos, attackingColor);
  }

  bool isCheckmate(ChessColor color) {
    return isInCheck(color) && !hasLegalMoves(color);
  }

  bool isStalemate(ChessColor color) {
    return !isInCheck(color) && !hasLegalMoves(color);
  }
}
