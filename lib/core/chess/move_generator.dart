import 'board.dart';
import 'chess_color.dart';
import 'chess_move.dart';
import 'piece.dart';
import 'piece_type.dart';
import 'position.dart';

class MoveGenerator {
  final ChessBoard board;

  MoveGenerator(this.board);

  static const _knightDirs = [
    [-2, -1], [-2, 1], [-1, -2], [-1, 2],
    [1, -2], [1, 2], [2, -1], [2, 1]
  ];
  static const _kingDirs = [
    [-1, -1], [0, -1], [1, -1],
    [-1, 0],           [1, 0],
    [-1, 1],  [0, 1],  [1, 1]
  ];
  static const _bishopDirs = [[-1, -1], [1, -1], [-1, 1], [1, 1]];
  static const _rookDirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
  static const _queenDirs = [..._bishopDirs, ..._rookDirs];

  bool _isValid(int f, int r) => f >= 0 && f <= 7 && r >= 0 && r <= 7;

  List<ChessMove> generatePseudoLegalMoves(ChessColor color) {
    final moves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int f = 0; f < 8; f++) {
        final pos = Position(f, r);
        final piece = board.getPieceAt(pos);
        if (piece != null && piece.color == color) {
          moves.addAll(_generateMovesForPiece(pos, piece));
        }
      }
    }
    return moves;
  }

  List<ChessMove> _generateMovesForPiece(Position pos, ChessPiece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return _generatePawnMoves(pos, piece.color);
      case PieceType.knight:
        return _generateStepMoves(pos, piece.color, _knightDirs);
      case PieceType.bishop:
        return _generateSlidingMoves(pos, piece.color, _bishopDirs);
      case PieceType.rook:
        return _generateSlidingMoves(pos, piece.color, _rookDirs);
      case PieceType.queen:
        return _generateSlidingMoves(pos, piece.color, _queenDirs);
      case PieceType.king:
        return _generateStepMoves(pos, piece.color, _kingDirs);
    }
  }

  List<ChessMove> _generatePawnMoves(Position pos, ChessColor color) {
    final moves = <ChessMove>[];
    final direction = color == ChessColor.white ? 1 : -1;
    final startRank = color == ChessColor.white ? 1 : 6;
    
    // forward 1
    if (_isValid(pos.file, pos.rank + direction)) {
      final forwardPos = Position(pos.file, pos.rank + direction);
      if (!board.isOccupied(forwardPos)) {
        moves.add(ChessMove(from: pos, to: forwardPos));
        
        // forward 2
        if (pos.rank == startRank) {
          final forward2Pos = Position(pos.file, pos.rank + 2 * direction);
          if (!board.isOccupied(forward2Pos)) {
            moves.add(ChessMove(from: pos, to: forward2Pos));
          }
        }
      }
    }

    // captures
    final captureFiles = [pos.file - 1, pos.file + 1];
    for (final f in captureFiles) {
      if (_isValid(f, pos.rank + direction)) {
        final capturePos = Position(f, pos.rank + direction);
        final piece = board.getPieceAt(capturePos);
        // Requirement 7: Do NOT generate a normal move that captures the opponent King
        if (piece != null && piece.color != color && piece.type != PieceType.king) {
          moves.add(ChessMove(from: pos, to: capturePos, capturedPiece: piece));
        }
      }
    }
    return moves;
  }

  List<ChessMove> _generateStepMoves(Position pos, ChessColor color, List<List<int>> dirs) {
    final moves = <ChessMove>[];
    for (final dir in dirs) {
      final f = pos.file + dir[0];
      final r = pos.rank + dir[1];
      if (_isValid(f, r)) {
        final targetPos = Position(f, r);
        final targetPiece = board.getPieceAt(targetPos);
        if (targetPiece == null) {
          moves.add(ChessMove(from: pos, to: targetPos));
        } else if (targetPiece.color != color && targetPiece.type != PieceType.king) {
          moves.add(ChessMove(from: pos, to: targetPos, capturedPiece: targetPiece));
        }
      }
    }
    return moves;
  }

  List<ChessMove> _generateSlidingMoves(Position pos, ChessColor color, List<List<int>> dirs) {
    final moves = <ChessMove>[];
    for (final dir in dirs) {
      int f = pos.file + dir[0];
      int r = pos.rank + dir[1];
      while (_isValid(f, r)) {
        final targetPos = Position(f, r);
        final targetPiece = board.getPieceAt(targetPos);
        if (targetPiece == null) {
          moves.add(ChessMove(from: pos, to: targetPos));
        } else {
          if (targetPiece.color != color && targetPiece.type != PieceType.king) {
            moves.add(ChessMove(from: pos, to: targetPos, capturedPiece: targetPiece));
          }
          break; // Stop sliding when blocked by any piece
        }
        f += dir[0];
        r += dir[1];
      }
    }
    return moves;
  }

  bool isSquareAttacked(Position pos, ChessColor attackingColor) {
    // Check pawns
    final pawnDir = attackingColor == ChessColor.white ? -1 : 1; 
    final pawnCaptureFiles = [pos.file - 1, pos.file + 1];
    for (final f in pawnCaptureFiles) {
      if (_isValid(f, pos.rank + pawnDir)) {
        final p = board.getPieceAt(Position(f, pos.rank + pawnDir));
        if (p != null && p.color == attackingColor && p.type == PieceType.pawn) {
          return true;
        }
      }
    }

    // Check knights
    for (final dir in _knightDirs) {
      final f = pos.file + dir[0];
      final r = pos.rank + dir[1];
      if (_isValid(f, r)) {
        final p = board.getPieceAt(Position(f, r));
        if (p != null && p.color == attackingColor && p.type == PieceType.knight) {
          return true;
        }
      }
    }

    // Check kings
    for (final dir in _kingDirs) {
      final f = pos.file + dir[0];
      final r = pos.rank + dir[1];
      if (_isValid(f, r)) {
        final p = board.getPieceAt(Position(f, r));
        if (p != null && p.color == attackingColor && p.type == PieceType.king) {
          return true;
        }
      }
    }

    // Check sliders
    if (_isAttackedBySlider(pos, attackingColor, _bishopDirs, [PieceType.bishop, PieceType.queen])) {
      return true;
    }
    if (_isAttackedBySlider(pos, attackingColor, _rookDirs, [PieceType.rook, PieceType.queen])) {
      return true;
    }

    return false;
  }

  bool _isAttackedBySlider(Position pos, ChessColor attackingColor, List<List<int>> dirs, List<PieceType> types) {
    for (final dir in dirs) {
      int f = pos.file + dir[0];
      int r = pos.rank + dir[1];
      while (_isValid(f, r)) {
        final p = board.getPieceAt(Position(f, r));
        if (p != null) {
          if (p.color == attackingColor && types.contains(p.type)) {
            return true;
          }
          break; // blocked
        }
        f += dir[0];
        r += dir[1];
      }
    }
    return false;
  }
}
