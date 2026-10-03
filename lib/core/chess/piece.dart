import 'chess_color.dart';
import 'piece_type.dart';

class ChessPiece {
  final ChessColor color;
  final PieceType type;

  const ChessPiece(this.type, this.color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          type == other.type;

  @override
  int get hashCode => color.hashCode ^ type.hashCode;
  
  @override
  String toString() => '${color.name} ${type.name}';
}
