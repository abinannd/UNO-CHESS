import '../chess/piece_type.dart';

/// Revival Point cost for each piece type.
/// King cannot be revived — attempting to look up its cost throws [ArgumentError].
class RevivalCost {
  RevivalCost._();

  static const Map<PieceType, int> _costs = {
    PieceType.pawn:   1,
    PieceType.knight: 3,
    PieceType.bishop: 3,
    PieceType.rook:   5,
    PieceType.queen:  10,
  };

  /// Returns the RP cost for [type].
  /// Throws [ArgumentError] if [type] is [PieceType.king].
  static int of(PieceType type) {
    if (type == PieceType.king) {
      throw ArgumentError('The King cannot be revived.');
    }
    return _costs[type]!;
  }

  /// Returns true if [type] can ever be revived (i.e., is not King).
  static bool isRevivable(PieceType type) => type != PieceType.king;
}
