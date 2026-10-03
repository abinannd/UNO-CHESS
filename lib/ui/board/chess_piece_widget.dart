import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';

/// A widget that renders a single chess piece.
/// Currently uses Unicode chess symbols as a reliable temporary visual.
class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const ChessPieceWidget({super.key, required this.piece, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _getUnicodeChar(piece),
        style: TextStyle(
          fontSize: size,
          color: piece.color == ChessColor.white ? Colors.white : Colors.black,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: piece.color == ChessColor.white ? Colors.black54 : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  String _getUnicodeChar(ChessPiece piece) {
    // We use the filled unicode characters for both colors,
    // and apply Flutter text coloring to differentiate White/Black.
    switch (piece.type) {
      case PieceType.king:
        return '♚';
      case PieceType.queen:
        return '♛';
      case PieceType.rook:
        return '♜';
      case PieceType.bishop:
        return '♝';
      case PieceType.knight:
        return '♞';
      case PieceType.pawn:
        return '♟';
    }
  }
}
