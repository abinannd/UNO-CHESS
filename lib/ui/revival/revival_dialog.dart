import 'package:flutter/material.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/game/game_state.dart';
import 'package:uno_chess/core/revival/revival_cost.dart';

/// Maps a [PieceType] and color name to an asset path.
String pieceAssetPath(PieceType type, String colorName) {
  final typeName = type.name; // 'pawn', 'knight', etc.
  return 'assets/pieces/${colorName}_$typeName.png';
}

/// The ordered list of revivable piece types (King excluded).
const _revivablePieces = [
  PieceType.queen,
  PieceType.rook,
  PieceType.bishop,
  PieceType.knight,
  PieceType.pawn,
];

/// A compact dialog widget for the revival flow.
class RevivalDialog extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onRevivalComplete;

  const RevivalDialog({
    super.key,
    required this.gameState,
    required this.onRevivalComplete,
  });

  @override
  Widget build(BuildContext context) {
    final player = gameState.currentPlayer;
    final rp = player.revivalPoints;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Revive a Piece',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$rp RP',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _revivablePieces.map((type) {
            // Use the actual chess color of the first captured piece of this type.
            // Captured pieces are stored with their original chess color, which is
            // independent of the player's current controlled color (may differ after Reverse).
            final capturedOfType = player.capturedPieces
                .where((p) => p.type == type)
                .toList();
            final pieceColor = capturedOfType.isNotEmpty
                ? capturedOfType.first.color
                : player.controlledColor; // fallback for image display only
            final colorName = pieceColor.name;

            final canRevive = capturedOfType.isNotEmpty &&
                player.revivalSystem.canRevive(
                    type, capturedOfType.first.color, gameState.board);
            final cost = RevivalCost.of(type);
            return _PieceTile(
              type: type,
              colorName: colorName,
              cost: cost,
              canRevive: canRevive,
              onTap: canRevive
                  ? () => _onPieceTapped(context, type, capturedOfType.first.color)
                  : () => _showUnavailableReason(context, type, player, cost),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }

  void _onPieceTapped(BuildContext context, PieceType type, ChessColor pieceColor) {
    final player = gameState.currentPlayer;
    final spawns = player.revivalSystem
        .availableSpawnSquares(type, pieceColor, gameState.board);

    if (spawns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available spawn squares.')),
      );
      return;
    }

    if (spawns.length == 1) {
      _executeRevival(context, type, pieceColor, spawns.first);
    } else {
      _showSpawnPicker(context, type, pieceColor, spawns);
    }
  }

  void _showSpawnPicker(
      BuildContext context, PieceType type, ChessColor pieceColor, List<Position> spawns) {
    showDialog<Position>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Choose Spawn Square',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: spawns
              .map((pos) => ListTile(
                    title: Text(
                      pos.algebraic,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.of(ctx).pop(pos),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    ).then((chosen) {
      if (chosen != null && context.mounted) {
        _executeRevival(context, type, pieceColor, chosen);
      }
    });
  }

  void _executeRevival(BuildContext context, PieceType type, ChessColor pieceColor, Position square) {
    try {
      gameState.revive(type, pieceColor, square);
      Navigator.of(context).pop(); // Close revival dialog
      onRevivalComplete();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Revival failed: $e')),
      );
    }
  }

  void _showUnavailableReason(
      BuildContext context, PieceType type, dynamic player, int cost) {
    final rp = player.revivalPoints;
    // Find captured pieces of this type using their stored chess color.
    final captured = (player.capturedPieces as List)
        .where((p) => p.type == type)
        .toList();
    final hasCaptured = captured.isNotEmpty;
    final pieceColor = hasCaptured ? captured.first.color : null;
    final spawns = hasCaptured
        ? player.revivalSystem
            .availableSpawnSquares(type, pieceColor, gameState.board)
        : [];

    String reason;
    if (!hasCaptured) {
      reason = 'No captured ${type.name} to revive.';
    } else if (rp < cost) {
      reason = 'Need $cost RP, you have $rp.';
    } else if (spawns.isEmpty) {
      reason = 'All spawn squares for ${type.name} are occupied.';
    } else {
      reason = 'Revival unavailable.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reason),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // _positionToAlgebraic is no longer needed; Position.algebraic getter is used directly.
}

/// A single square tile showing a piece image, its RP cost, and a
/// green (eligible) or red (ineligible) border.
class _PieceTile extends StatelessWidget {
  final PieceType type;
  final String colorName;
  final int cost;
  final bool canRevive;
  final VoidCallback onTap;

  const _PieceTile({
    required this.type,
    required this.colorName,
    required this.cost,
    required this.canRevive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = canRevive ? Colors.greenAccent : Colors.redAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed-size square container for the piece image.
            SizedBox(
              width: 52,
              height: 52,
              child: Image.asset(
                pieceAssetPath(type, colorName),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$cost RP',
              style: TextStyle(
                color: canRevive ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
