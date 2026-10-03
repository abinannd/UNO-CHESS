import '../chess/board.dart';
import '../chess/chess_color.dart';
import '../chess/piece.dart';
import '../chess/piece_type.dart';
import '../chess/position.dart';
import 'captured_piece.dart';
import 'revival_cost.dart';

/// Exception thrown when a revival attempt is illegal.
class RevivalException implements Exception {
  final String message;
  const RevivalException(this.message);
  @override
  String toString() => 'RevivalException: $message';
}

/// Manages the revival pool and RP for a single player.
///
/// The Turn System (Phase 2) will own one [RevivalSystem] per player and call:
///   - [addRevivalPoints] when a +2/+4 card is drawn.
///   - [recordCapture] whenever one of this player's pieces is taken.
///   - [canRevive] / [availableSpawnSquares] to check eligibility.
///   - [revive] to execute the revival and mutate the [ChessBoard].
class RevivalSystem {
  /// Revival Points currently held by this player.
  int revivalPoints;

  /// Pieces owned by this player that have been captured and not yet revived.
  final List<CapturedPiece> capturedPieces;

  RevivalSystem({this.revivalPoints = 0, List<CapturedPiece>? capturedPieces})
      : capturedPieces = capturedPieces ?? [];

  // ── Static spawn-square definitions ─────────────────────────────────────────

  static const Map<PieceType, List<Position>> _whiteSpawns = {
    PieceType.rook:   [Position(0, 0), Position(7, 0)],
    PieceType.knight: [Position(1, 0), Position(6, 0)],
    PieceType.bishop: [Position(2, 0), Position(5, 0)],
    PieceType.queen:  [Position(3, 0)],
    PieceType.pawn: [
      Position(0, 1), Position(1, 1), Position(2, 1), Position(3, 1),
      Position(4, 1), Position(5, 1), Position(6, 1), Position(7, 1),
    ],
  };

  static const Map<PieceType, List<Position>> _blackSpawns = {
    PieceType.rook:   [Position(0, 7), Position(7, 7)],
    PieceType.knight: [Position(1, 7), Position(6, 7)],
    PieceType.bishop: [Position(2, 7), Position(5, 7)],
    PieceType.queen:  [Position(3, 7)],
    PieceType.pawn: [
      Position(0, 6), Position(1, 6), Position(2, 6), Position(3, 6),
      Position(4, 6), Position(5, 6), Position(6, 6), Position(7, 6),
    ],
  };

  /// Returns all valid spawn squares for [type]/[color] that are currently
  /// unoccupied on [board]. Returns an empty list if none available.
  List<Position> availableSpawnSquares(
      PieceType type, ChessColor color, ChessBoard board) {
    if (!RevivalCost.isRevivable(type)) return [];
    final spawns = color == ChessColor.white
        ? _whiteSpawns[type]!
        : _blackSpawns[type]!;
    return spawns.where((pos) => !board.isOccupied(pos)).toList();
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Adds [points] to this player's RP pool (called by Turn System on +2/+4).
  void addRevivalPoints(int points) {
    assert(points > 0, 'Revival points added must be positive');
    revivalPoints += points;
  }

  /// Records a capture of one of this player's pieces.
  void recordCapture(PieceType type, ChessColor color) {
    if (type == PieceType.king) return; // King is never tracked
    capturedPieces.add(CapturedPiece(type, color));
  }

  /// Returns true if this player can currently revive a [type] piece given
  /// [board] state and available RP.
  bool canRevive(PieceType type, ChessColor color, ChessBoard board) {
    if (!RevivalCost.isRevivable(type)) return false;
    if (revivalPoints < RevivalCost.of(type)) return false;
    if (!capturedPieces.any((p) => p.type == type && p.color == color)) {
      return false;
    }
    return availableSpawnSquares(type, color, board).isNotEmpty;
  }

  /// Executes a revival of a [type] piece onto [spawnSquare].
  ///
  /// Validates:
  ///  1. [type] is revivable.
  ///  2. Enough RP.
  ///  3. The piece was actually captured.
  ///  4. [spawnSquare] is a valid spawn for [type]/[color].
  ///  5. [spawnSquare] is currently unoccupied.
  ///
  /// On success: deducts RP, removes one matching [CapturedPiece], places the
  /// piece on [board].
  ///
  /// Throws [RevivalException] on any invalid condition.
  void revive(
      PieceType type, ChessColor color, Position spawnSquare, ChessBoard board) {
    // 1. Revivability
    if (!RevivalCost.isRevivable(type)) {
      throw const RevivalException('The King cannot be revived.');
    }

    // 2. RP check
    final cost = RevivalCost.of(type);
    if (revivalPoints < cost) {
      throw RevivalException(
          'Insufficient RP: need $cost, have $revivalPoints.');
    }

    // 3. Must have been captured
    final capturedIndex =
        capturedPieces.indexWhere((p) => p.type == type && p.color == color);
    if (capturedIndex == -1) {
      throw RevivalException(
          'No captured ${color.name} ${type.name} available for revival.');
    }

    // 4. Valid spawn square
    final validSpawns = color == ChessColor.white
        ? _whiteSpawns[type]!
        : _blackSpawns[type]!;
    if (!validSpawns.contains(spawnSquare)) {
      throw RevivalException(
          '$spawnSquare is not a valid spawn square for ${color.name} ${type.name}.');
    }

    // 5. Spawn square must be unoccupied
    if (board.isOccupied(spawnSquare)) {
      throw RevivalException('Spawn square $spawnSquare is occupied.');
    }

    // ── Execute ──────────────────────────────────────────────────────────────
    revivalPoints -= cost;
    capturedPieces.removeAt(capturedIndex);
    board.placePiece(spawnSquare, ChessPiece(type, color));
  }
}
