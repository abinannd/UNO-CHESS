import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/piece.dart';

/// A widget that renders a single chess piece using custom image assets.
class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const ChessPieceWidget({super.key, required this.piece, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        _getImageAssetPath(piece),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  String _getImageAssetPath(ChessPiece piece) {
    final colorStr = piece.color == ChessColor.white ? 'white' : 'black';
    final typeStr = piece.type.name; // e.g., 'king', 'queen'
    return 'assets/pieces/${colorStr}_${typeStr}.png';
  }
}
