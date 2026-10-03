import '../chess/chess_color.dart';
import '../revival/captured_piece.dart';
import '../revival/revival_system.dart';
import 'player_identity.dart';

/// Represents the state of a single player in the UNO Chess game.
///
/// This class is immutable regarding its identity and controlled color,
/// supporting color swapping via [copyWith] (for the Reverse card effect).
/// It holds a reference to the mutable [RevivalSystem] which manages
/// the player's Revival Points (RP) and captured pieces pool.
class PlayerState {
  /// The fixed identity of the player.
  final PlayerIdentity identity;

  /// The chess color currently controlled by this player.
  final ChessColor controlledColor;

  /// The revival system tracking RP and captured pieces for this player.
  final RevivalSystem revivalSystem;

  PlayerState({
    required this.identity,
    required this.controlledColor,
    RevivalSystem? revivalSystem,
  }) : revivalSystem = revivalSystem ?? RevivalSystem();

  /// Creates an initial state for Player 1, controlling White.
  factory PlayerState.initialPlayer1() {
    return PlayerState(
      identity: PlayerIdentity.player1,
      controlledColor: ChessColor.white,
    );
  }

  /// Creates an initial state for Player 2, controlling Black.
  factory PlayerState.initialPlayer2() {
    return PlayerState(
      identity: PlayerIdentity.player2,
      controlledColor: ChessColor.black,
    );
  }

  /// Creates a copy of this player state, optionally replacing specific fields.
  /// Primarily used for handling Reverse card effects (swapping controlledColor).
  PlayerState copyWith({
    PlayerIdentity? identity,
    ChessColor? controlledColor,
    RevivalSystem? revivalSystem,
  }) {
    return PlayerState(
      identity: identity ?? this.identity,
      controlledColor: controlledColor ?? this.controlledColor,
      revivalSystem: revivalSystem ?? this.revivalSystem,
    );
  }

  // ── Convenience Accessors ───────────────────────────────────────────────────

  /// The current number of Revival Points this player has.
  int get revivalPoints => revivalSystem.revivalPoints;

  /// The list of pieces this player has lost and can potentially revive.
  List<CapturedPiece> get capturedPieces => revivalSystem.capturedPieces;

  @override
  bool operator ==(Object other) =>
      other is PlayerState &&
      identity == other.identity &&
      controlledColor == other.controlledColor &&
      revivalSystem == other.revivalSystem;

  @override
  int get hashCode =>
      identity.hashCode ^ controlledColor.hashCode ^ revivalSystem.hashCode;

  @override
  String toString() =>
      'PlayerState(${identity.name}, ${controlledColor.name}, RP: $revivalPoints, Captured: ${capturedPieces.length})';
}
