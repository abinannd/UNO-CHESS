import 'chess_color.dart';
import 'chess_move.dart';
import 'piece_type.dart';
import 'position.dart';
import 'piece.dart';

class CastlingRights {
  bool whiteKingSide;
  bool whiteQueenSide;
  bool blackKingSide;
  bool blackQueenSide;

  CastlingRights({
    this.whiteKingSide = true,
    this.whiteQueenSide = true,
    this.blackKingSide = true,
    this.blackQueenSide = true,
  });

  CastlingRights clone() {
    return CastlingRights(
      whiteKingSide: whiteKingSide,
      whiteQueenSide: whiteQueenSide,
      blackKingSide: blackKingSide,
      blackQueenSide: blackQueenSide,
    );
  }
}

class ChessBoard {
  final List<List<ChessPiece?>> _grid;
  CastlingRights castlingRights;
  Position? enPassantTarget;

  ChessBoard.empty()
      : _grid = List.generate(8, (_) => List.filled(8, null)),
        castlingRights = CastlingRights(
          whiteKingSide: false,
          whiteQueenSide: false,
          blackKingSide: false,
          blackQueenSide: false,
        );

  ChessBoard clone() {
    final newBoard = ChessBoard.empty();
    newBoard.castlingRights = castlingRights.clone();
    newBoard.enPassantTarget = enPassantTarget;
    for (int r = 0; r < 8; r++) {
      for (int f = 0; f < 8; f++) {
        final piece = _grid[r][f];
        if (piece != null) {
          newBoard._grid[r][f] = ChessPiece(piece.type, piece.color);
        }
      }
    }
    return newBoard;
  }

  factory ChessBoard.initial() {
    final board = ChessBoard.empty();
    board.castlingRights = CastlingRights(); // all true
    board._setupInitialPosition();
    return board;
  }

  void _setupInitialPosition() {
    // White pieces
    _setSquare(const Position(0, 0), const ChessPiece(PieceType.rook, ChessColor.white));
    _setSquare(const Position(1, 0), const ChessPiece(PieceType.knight, ChessColor.white));
    _setSquare(const Position(2, 0), const ChessPiece(PieceType.bishop, ChessColor.white));
    _setSquare(const Position(3, 0), const ChessPiece(PieceType.queen, ChessColor.white));
    _setSquare(const Position(4, 0), const ChessPiece(PieceType.king, ChessColor.white));
    _setSquare(const Position(5, 0), const ChessPiece(PieceType.bishop, ChessColor.white));
    _setSquare(const Position(6, 0), const ChessPiece(PieceType.knight, ChessColor.white));
    _setSquare(const Position(7, 0), const ChessPiece(PieceType.rook, ChessColor.white));

    for (int file = 0; file < 8; file++) {
      _setSquare(Position(file, 1), const ChessPiece(PieceType.pawn, ChessColor.white));
    }

    // Black pieces
    _setSquare(const Position(0, 7), const ChessPiece(PieceType.rook, ChessColor.black));
    _setSquare(const Position(1, 7), const ChessPiece(PieceType.knight, ChessColor.black));
    _setSquare(const Position(2, 7), const ChessPiece(PieceType.bishop, ChessColor.black));
    _setSquare(const Position(3, 7), const ChessPiece(PieceType.queen, ChessColor.black));
    _setSquare(const Position(4, 7), const ChessPiece(PieceType.king, ChessColor.black));
    _setSquare(const Position(5, 7), const ChessPiece(PieceType.bishop, ChessColor.black));
    _setSquare(const Position(6, 7), const ChessPiece(PieceType.knight, ChessColor.black));
    _setSquare(const Position(7, 7), const ChessPiece(PieceType.rook, ChessColor.black));

    for (int file = 0; file < 8; file++) {
      _setSquare(Position(file, 6), const ChessPiece(PieceType.pawn, ChessColor.black));
    }
  }

  ChessPiece? getPieceAt(Position pos) {
    return _grid[pos.rank][pos.file];
  }

  void _setSquare(Position pos, ChessPiece? piece) {
    _grid[pos.rank][pos.file] = piece;
  }

  bool isOccupied(Position pos) {
    return getPieceAt(pos) != null;
  }

  void placePiece(Position pos, ChessPiece piece) {
    _setSquare(pos, piece);
  }

  ChessPiece? removePiece(Position pos) {
    final piece = getPieceAt(pos);
    _setSquare(pos, null);
    return piece;
  }

  void movePiece(Position from, Position to) {
    final piece = removePiece(from);
    if (piece != null) {
      placePiece(to, piece);
    }
  }

  void executeMove(ChessMove move) {
    final piece = removePiece(move.from);
    if (piece != null) {
      placePiece(move.to, piece);

      // Promotion: replace pawn with the chosen piece
      if (move.promotion != null) {
        placePiece(move.to, ChessPiece(move.promotion!, piece.color));
      }

      if (move.isCastling) {
        if (move.to.file == 6) { // King-side
          final rook = removePiece(Position(7, move.to.rank));
          if (rook != null) placePiece(Position(5, move.to.rank), rook);
        } else if (move.to.file == 2) { // Queen-side
          final rook = removePiece(Position(0, move.to.rank));
          if (rook != null) placePiece(Position(3, move.to.rank), rook);
        }
      }

      if (move.isEnPassant) {
        final capturedRank = piece.color == ChessColor.white ? move.to.rank - 1 : move.to.rank + 1;
        removePiece(Position(move.to.file, capturedRank));
      }

      if (piece.type == PieceType.king) {
        if (piece.color == ChessColor.white) {
          castlingRights.whiteKingSide = false;
          castlingRights.whiteQueenSide = false;
        } else {
          castlingRights.blackKingSide = false;
          castlingRights.blackQueenSide = false;
        }
      } else if (piece.type == PieceType.rook) {
        if (move.from.file == 0 && move.from.rank == 0) castlingRights.whiteQueenSide = false;
        if (move.from.file == 7 && move.from.rank == 0) castlingRights.whiteKingSide = false;
        if (move.from.file == 0 && move.from.rank == 7) castlingRights.blackQueenSide = false;
        if (move.from.file == 7 && move.from.rank == 7) castlingRights.blackKingSide = false;
      }
      
      // Update enPassantTarget
      if (piece.type == PieceType.pawn && (move.from.rank - move.to.rank).abs() == 2) {
        final targetRank = piece.color == ChessColor.white ? move.from.rank + 1 : move.from.rank - 1;
        enPassantTarget = Position(move.from.file, targetRank);
      } else {
        enPassantTarget = null;
      }
    }
    
    // Check if a rook was captured at its original square
    if (move.to.file == 0 && move.to.rank == 0) castlingRights.whiteQueenSide = false;
    if (move.to.file == 7 && move.to.rank == 0) castlingRights.whiteKingSide = false;
    if (move.to.file == 0 && move.to.rank == 7) castlingRights.blackQueenSide = false;
    if (move.to.file == 7 && move.to.rank == 7) castlingRights.blackKingSide = false;
  }
}
