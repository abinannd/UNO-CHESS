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
        final moves = _generateStepMoves(pos, piece.color, _kingDirs);
        moves.addAll(_generateCastlingMoves(pos, piece.color));
        return moves;
    }
  }

  List<ChessMove> _generateCastlingMoves(Position pos, ChessColor color) {
    final moves = <ChessMove>[];
    
    // King must be on original square
    final expectedRank = color == ChessColor.white ? 0 : 7;
    if (pos.file != 4 || pos.rank != expectedRank) return moves;

    final rights = board.castlingRights;
    final canKingSide = color == ChessColor.white ? rights.whiteKingSide : rights.blackKingSide;
    final canQueenSide = color == ChessColor.white ? rights.whiteQueenSide : rights.blackQueenSide;

    if (!canKingSide && !canQueenSide) return moves;

    final opponent = color.opponent;
    if (isSquareAttacked(pos, opponent)) return moves; // Cannot castle out of check

    if (canKingSide) {
      final f = Position(5, expectedRank);
      final g = Position(6, expectedRank);
      final h = Position(7, expectedRank);
      
      final rook = board.getPieceAt(h);
      if (rook != null && rook.type == PieceType.rook && rook.color == color) {
        if (!board.isOccupied(f) && !board.isOccupied(g)) {
          if (!isSquareAttacked(f, opponent) && !isSquareAttacked(g, opponent)) {
            moves.add(ChessMove(from: pos, to: g, isCastling: true));
          }
        }
      }
    }

    if (canQueenSide) {
      final b = Position(1, expectedRank);
      final c = Position(2, expectedRank);
      final d = Position(3, expectedRank);
      final a = Position(0, expectedRank);

      final rook = board.getPieceAt(a);
      if (rook != null && rook.type == PieceType.rook && rook.color == color) {
        if (!board.isOccupied(b) && !board.isOccupied(c) && !board.isOccupied(d)) {
          if (!isSquareAttacked(c, opponent) && !isSquareAttacked(d, opponent)) {
            moves.add(ChessMove(from: pos, to: c, isCastling: true));
          }
        }
      }
    }

    return moves;
  }

  static const _promotionTypes = [
    PieceType.queen,
    PieceType.rook,
    PieceType.bishop,
    PieceType.knight,
  ];

  List<ChessMove> _generatePawnMoves(Position pos, ChessColor color) {
    final moves = <ChessMove>[];
    final direction = color == ChessColor.white ? 1 : -1;
    final startRank = color == ChessColor.white ? 1 : 6;
    final promotionRank = color == ChessColor.white ? 7 : 0;

    // Helper: emit 4 promotion variants or 1 normal move
    void addMove({required Position from, required Position to, ChessPiece? capturedPiece}) {
      if (to.rank == promotionRank) {
        for (final pt in _promotionTypes) {
          moves.add(ChessMove(from: from, to: to, capturedPiece: capturedPiece, promotion: pt));
        }
      } else {
        moves.add(ChessMove(from: from, to: to, capturedPiece: capturedPiece));
      }
    }

    // forward 1
    if (_isValid(pos.file, pos.rank + direction)) {
      final forwardPos = Position(pos.file, pos.rank + direction);
      if (!board.isOccupied(forwardPos)) {
        addMove(from: pos, to: forwardPos);

        // forward 2 (cannot reach promotion rank from start rank in one double-step)
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
        if (piece != null && piece.color != color && piece.type != PieceType.king) {
          addMove(from: pos, to: capturePos, capturedPiece: piece);
        }
      }
    }

    // En passant (never on final rank, no promotion needed)
    final epTarget = board.enPassantTarget;
    if (epTarget != null && epTarget.rank == pos.rank + direction) {
      final fileDiff = (epTarget.file - pos.file).abs();
      if (fileDiff == 1) {
        final capturedPawnPos = Position(epTarget.file, pos.rank);
        final capturedPawn = board.getPieceAt(capturedPawnPos);
        if (capturedPawn != null &&
            capturedPawn.type == PieceType.pawn &&
            capturedPawn.color != color) {
          moves.add(ChessMove(
            from: pos,
            to: epTarget,
            capturedPiece: capturedPawn,
            isEnPassant: true,
          ));
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
