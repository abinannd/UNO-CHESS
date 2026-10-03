import 'position.dart';
import 'piece.dart';
import 'piece_type.dart';

class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final PieceType? promotion;

  const ChessMove({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.promotion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessMove &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          capturedPiece == other.capturedPiece &&
          promotion == other.promotion;

  @override
  int get hashCode =>
      from.hashCode ^ to.hashCode ^ capturedPiece.hashCode ^ promotion.hashCode;

  @override
  String toString() {
    final captureStr = capturedPiece != null ? ' x $capturedPiece' : '';
    final promoStr = promotion != null ? ' = ${promotion!.name}' : '';
    return 'Move($from -> $to$captureStr$promoStr)';
  }
}
