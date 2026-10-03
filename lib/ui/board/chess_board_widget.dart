import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'chess_square_widget.dart';
import 'chess_piece_widget.dart';

/// Renders the 8x8 chessboard and positions the pieces based on the core state.
class ChessBoardWidget extends StatelessWidget {
  final ChessBoard board;
  final bool isReversed;
  final ValueChanged<Position>? onSquareTapped;
  final Position? selectedPosition;
  final List<Position> legalDestinations;
  final Position? checkPosition;

  const ChessBoardWidget({
    super.key,
    required this.board,
    this.isReversed = false,
    this.onSquareTapped,
    this.selectedPosition,
    this.legalDestinations = const [],
    this.checkPosition,
  });

  @override
  Widget build(BuildContext context) {
    // AspectRatio guarantees the board stays perfectly square.
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final squareSize = constraints.maxWidth / 8;
          return Column(
            children: _buildRanks(squareSize),
          );
        },
      ),
    );
  }

  List<Widget> _buildRanks(double squareSize) {
    final ranks = <Widget>[];

    // Standard view: Rank 8 (index 7) at the top, Rank 1 (index 0) at the bottom.
    // Reversed view: Rank 1 (index 0) at the top, Rank 8 (index 7) at the bottom.
    for (int r = 0; r < 8; r++) {
      final rankIndex = isReversed ? r : 7 - r;
      ranks.add(
        Expanded(
          child: Row(
            children: _buildFiles(rankIndex, squareSize),
          ),
        ),
      );
    }
    return ranks;
  }

  List<Widget> _buildFiles(int rankIndex, double squareSize) {
    final files = <Widget>[];

    // Standard view: File 'a' (index 0) on the left to 'h' (index 7) on the right.
    // Reversed view: File 'h' (index 7) on the left to 'a' (index 0) on the right.
    for (int f = 0; f < 8; f++) {
      final fileIndex = isReversed ? 7 - f : f;
      final position = Position(fileIndex, rankIndex);
      final piece = board.getPieceAt(position);

      files.add(
        Expanded(
          child: ChessSquareWidget(
            position: position,
            pieceWidget: piece != null
                ? ChessPieceWidget(piece: piece, size: squareSize * 0.7)
                : null,
            isSelected: position == selectedPosition,
            isLegalDestination: legalDestinations.contains(position),
            isCheck: position == checkPosition,
            onTap: onSquareTapped != null ? () => onSquareTapped!(position) : null,
          ),
        ),
      );
    }
    return files;
  }
}
