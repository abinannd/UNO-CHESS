import '../chess/board.dart';
import '../chess/chess_color.dart';
import '../chess/chess_engine.dart';
import '../chess/chess_move.dart';
import '../chess/piece_type.dart';
import '../chess/position.dart';
import '../uno/uno_card.dart';
import '../uno/uno_effect.dart';
import 'game_status.dart';
import 'player_state.dart';
import 'turn_system.dart';

/// The central GameState representing the entire UNO Chess game.
/// Composes the TurnSystem and ChessBoard, serving as the single source of truth.
class GameState {
  final TurnSystem _turnSystem;
  final ChessBoard _board;
  GameStatus status;

  GameState({
    TurnSystem? turnSystem,
    ChessBoard? board,
    this.status = GameStatus.active,
  })  : _turnSystem = turnSystem ?? TurnSystem(),
        _board = board ?? ChessBoard.initial() {
    _updateGameStatus();
  }

  // ── Exposed State Properties ───────────────────────────────────────────────

  PlayerState get player1 => _turnSystem.player1;
  PlayerState get player2 => _turnSystem.player2;
  PlayerState get currentPlayer => _turnSystem.currentPlayer;

  ChessBoard get board => _board;

  int get movesAllowed => _turnSystem.movesAllowed;
  int get movesCompleted => _turnSystem.movesCompleted;

  UnoCard? get currentCard => _turnSystem.currentCard;
  UnoEffect? get currentEffect => _turnSystem.currentEffect;

  bool get isBoardReversed => _turnSystem.isBoardReversed;
  TurnPhase get turnPhase => _turnSystem.phase;

  // ── API for Game Progression ────────────────────────────────────────────────

  /// Draws a UNO card for the current player.
  void drawCard(UnoCard card) {
    if (status != GameStatus.active) return;
    _turnSystem.drawCard(card);
    _updateGameStatus();
  }

  /// Resolves a drawn Rainbow card into a specific effect.
  void resolveRainbow(UnoEffect effect) {
    if (status != GameStatus.active) return;
    _turnSystem.resolveRainbow(effect);
    _updateGameStatus();
  }

  /// Completes the Reverse card effect after the UI delay.
  void completeReverse() {
    if (status != GameStatus.active) return;
    _turnSystem.completeReverse();
    _updateGameStatus();
  }

  /// Completes the Skip card effect after the UI delay.
  void completeSkip() {
    if (status != GameStatus.active) return;
    _turnSystem.completeSkip();
    _updateGameStatus();
  }

  /// Completes the +2/+4 card effect after the UI delay.
  void completeDraw2Draw4() {
    if (status != GameStatus.active) return;
    _turnSystem.completeDraw2Draw4();
    _updateGameStatus();
  }

  /// Executes a chess move on the board.
  /// Returns true if the move was legal and successful.
  bool executeChessMove(ChessMove move) {
    if (status != GameStatus.active) return false;

    final success = _turnSystem.executeChessMove(move, _board);
    if (success) {
      _updateGameStatus();
    }
    return success;
  }

  // ── Revival API ────────────────────────────────────────────────────────────

  /// Returns true if the current player can revive any piece.
  bool get canReviveAny {
    if (status != GameStatus.active) return false;
    final player = _turnSystem.currentPlayer;
    for (final cp in player.capturedPieces) {
      if (player.revivalSystem.canRevive(cp.type, cp.color, _board)) return true;
    }
    return false;
  }

  /// Executes a revival for the current player.
  /// Delegates entirely to [RevivalSystem.revive]; throws [RevivalException] on failure.
  void revive(PieceType type, Position spawnSquare) {
    if (status != GameStatus.active) return;
    final player = _turnSystem.currentPlayer;
    player.revivalSystem.revive(type, player.controlledColor, spawnSquare, _board);
    _updateGameStatus();
  }

  // ── Internal Helpers ───────────────────────────────────────────────────────

  void _updateGameStatus() {
    if (status != GameStatus.active) return;

    final engine = ChessEngine(_board);

    // Evaluate terminal states universally across both sides
    if (engine.isCheckmate(ChessColor.white) || engine.isCheckmate(ChessColor.black)) {
      status = GameStatus.checkmate;
    } else if (engine.isStalemate(ChessColor.white) || engine.isStalemate(ChessColor.black)) {
      status = GameStatus.stalemate;
    }
  }
}
