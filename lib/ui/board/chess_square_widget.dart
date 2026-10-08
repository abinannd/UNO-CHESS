import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/position.dart';

/// Renders a single square on the chessboard.
class ChessSquareWidget extends StatelessWidget {
  final Position position;
  final Widget? pieceWidget;
  final VoidCallback? onTap;

  final bool isSelected;
  final bool isLegalDestination;
  final bool isCheck;

  const ChessSquareWidget({
    super.key,
    required this.position,
    this.pieceWidget,
    this.onTap,
    this.isSelected = false,
    this.isLegalDestination = false,
    this.isCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine square color based on algebraic position (e.g., a1 is dark).
    // Position files/ranks are 0-indexed.
    final bool isDark = (position.file + position.rank) % 2 == 0;
    
    Color backgroundColor = isDark ? const Color(0xFF769656) : const Color(0xFFEEEED2);
    
    if (isSelected) {
      backgroundColor = const Color(0xFFB9CA43); // Selected highlight
    } else if (isCheck) {
      backgroundColor = Colors.red.shade400;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (pieceWidget != null) pieceWidget!,
            if (isLegalDestination)
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0,
                 -1, 0, 0, 0, 255,
                ]),
                child: Image.asset(
                  'assets/ui/dot.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
