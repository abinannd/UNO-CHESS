import 'chess_color.dart';
import 'piece_type.dart';
import 'position.dart';
import 'piece.dart';

class ChessBoard {
  final List<List<ChessPiece?>> _grid;

  ChessBoard.empty()
      : _grid = List.generate(8, (_) => List.filled(8, null));

  ChessBoard clone() {
    final newBoard = ChessBoard.empty();
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
}
