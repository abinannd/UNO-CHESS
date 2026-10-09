import 'package:flutter/material.dart';
import 'package:uno_chess/core/game/game_state.dart';
import 'package:uno_chess/core/game/game_status.dart';
import 'package:uno_chess/core/game/player_identity.dart';
import 'package:uno_chess/ui/cards/uno_card_widget.dart';

class GameHudWidget extends StatelessWidget {
  final GameState gameState;
  final bool isInCheck;

  const GameHudWidget({
    super.key,
    required this.gameState,
    required this.isInCheck,
  });

  String _formatIdentity(PlayerIdentity identity) {
    return identity == PlayerIdentity.player1 ? 'Player 1' : 'Player 2';
  }

  Widget _rpText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.amberAccent,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = gameState.currentPlayer;
    final movesRemaining = gameState.movesAllowed - gameState.movesCompleted;

    String statusText = 'ACTIVE';
    Color statusColor = Colors.greenAccent;
    if (gameState.status == GameStatus.checkmate) {
      statusText = 'CHECKMATE';
      statusColor = Colors.redAccent;
    } else if (gameState.status == GameStatus.stalemate) {
      statusText = 'STALEMATE';
      statusColor = Colors.orangeAccent;
    } else if (isInCheck) {
      statusText = 'CHECK';
      statusColor = Colors.redAccent;
    }

    String playerIdentityName = _formatIdentity(currentPlayer.identity);
    String colorName = currentPlayer.controlledColor.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnoCardWidget(
            card: gameState.currentCard,
            width: 70,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '$playerIdentityName ($colorName)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Moves Remaining: $movesRemaining',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1, thickness: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _rpText('P1 RP: ${gameState.player1.revivalPoints}'),
                    _rpText('P2 RP: ${gameState.player2.revivalPoints}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
