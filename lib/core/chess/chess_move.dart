import 'position.dart';
import 'piece.dart';
import 'piece_type.dart';

class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final PieceType? promotion;
  final bool isCastling;
  final bool isEnPassant;

  const ChessMove({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.promotion,
    this.isCastling = false,
    this.isEnPassant = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessMove &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          capturedPiece == other.capturedPiece &&
          promotion == other.promotion &&
          isCastling == other.isCastling &&
          isEnPassant == other.isEnPassant;

  @override
  int get hashCode =>
      from.hashCode ^
      to.hashCode ^
      capturedPiece.hashCode ^
      promotion.hashCode ^
      isCastling.hashCode ^
      isEnPassant.hashCode;

  @override
  String toString() {
    if (isCastling) {
      return to.file == 6 ? 'O-O' : 'O-O-O';
    }
    final captureStr = capturedPiece != null ? ' x $capturedPiece' : '';
    final promoStr = promotion != null ? ' = ${promotion!.name}' : '';
    return 'Move($from -> $to$captureStr$promoStr)';
  }
}
