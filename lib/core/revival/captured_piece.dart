import '../chess/chess_color.dart';
import '../chess/piece_type.dart';

/// A lightweight record of a captured chess piece.
/// Stored in [RevivalSystem] until the owner spends RP to revive it.
class CapturedPiece {
  final PieceType type;
  final ChessColor color;

  const CapturedPiece(this.type, this.color);

  @override
  bool operator ==(Object other) =>
      other is CapturedPiece && type == other.type && color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
  String toString() => 'CapturedPiece(${color.name} ${type.name})';
}
