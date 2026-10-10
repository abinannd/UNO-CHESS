import '../chess/board.dart';
import '../chess/chess_engine.dart';
import '../chess/chess_move.dart';
import '../uno/uno_card.dart';
import '../uno/uno_card_type.dart';
import '../uno/uno_effect.dart';
import 'player_identity.dart';
import 'player_state.dart';

/// The distinct phases of a player's turn.
enum TurnPhase {
  awaitingDraw,
  awaitingRainbowResolution,
  resolvingReverse,
  resolvingSkip,
  resolvingDraw2Draw4,
  awaitingChessMove,
}

/// The Turn System coordinates players, UNO card effects, and chess moves.
class TurnSystem {
  PlayerState player1;
  PlayerState player2;
  PlayerIdentity currentPlayerIdentity;

  TurnPhase phase = TurnPhase.awaitingDraw;
  UnoCard? currentCard;
  UnoEffect? currentEffect;
  int movesAllowed = 0;
  int movesCompleted = 0;
  bool isBoardReversed = false;

  bool _p1HasDrawnInitialNumber = false;
  bool _p2HasDrawnInitialNumber = false;

  bool get _currentPlayerHasInitialNumber =>
      currentPlayerIdentity == PlayerIdentity.player1
          ? _p1HasDrawnInitialNumber
          : _p2HasDrawnInitialNumber;

  void _setCurrentPlayerInitialNumber() {
    if (currentPlayerIdentity == PlayerIdentity.player1) {
      _p1HasDrawnInitialNumber = true;
    } else {
      _p2HasDrawnInitialNumber = true;
    }
  }

  TurnSystem({
    PlayerState? player1,
    PlayerState? player2,
    this.currentPlayerIdentity = PlayerIdentity.player1,
  })  : player1 = player1 ?? PlayerState.initialPlayer1(),
        player2 = player2 ?? PlayerState.initialPlayer2();

  /// Returns the state of the currently active player.
  PlayerState get currentPlayer =>
      currentPlayerIdentity == PlayerIdentity.player1 ? player1 : player2;

  /// Returns the state of the inactive player.
  PlayerState get waitingPlayer =>
      currentPlayerIdentity == PlayerIdentity.player1 ? player2 : player1;

  /// Draws a UNO card to start the turn.
  void drawCard(UnoCard card) {
    if (phase != TurnPhase.awaitingDraw) {
      throw StateError('Cannot draw card in phase $phase');
    }

    if (!_currentPlayerHasInitialNumber) {
      if (card.type != UnoCardType.number) {
        // First draw MUST be a number card. Discard and stay in awaitingDraw.
        currentCard = card;
        return;
      }
      _setCurrentPlayerInitialNumber();
    }

    currentCard = card;
    final effect = UnoEffect.fromCard(card);
    if (effect.isRainbow) {
      currentEffect = effect;
      phase = TurnPhase.awaitingRainbowResolution;
    } else {
      _applyEffect(effect);
    }
  }

  /// Resolves a Rainbow card selection.
  void resolveRainbow(UnoEffect resolvedEffect) {
    if (phase != TurnPhase.awaitingRainbowResolution) {
      throw StateError('Not awaiting rainbow resolution');
    }
    if (resolvedEffect.isRainbow) {
      throw ArgumentError('Cannot resolve rainbow to another rainbow');
    }
    _applyEffect(resolvedEffect);
  }

  void completeReverse() {
    if (phase != TurnPhase.resolvingReverse) {
      throw StateError('Not resolving reverse');
    }
    final p1Color = player1.controlledColor;
    final p2Color = player2.controlledColor;
    player1 = player1.copyWith(controlledColor: p2Color);
    player2 = player2.copyWith(controlledColor: p1Color);
    isBoardReversed = !isBoardReversed;
    _endTurn(swapPlayer: false);
  }

  void completeSkip() {
    if (phase != TurnPhase.resolvingSkip) {
      throw StateError('Not resolving skip');
    }
    _endTurn(swapPlayer: true);
  }

  void completeDraw2Draw4() {
    if (phase != TurnPhase.resolvingDraw2Draw4) {
      throw StateError('Not resolving +2/+4');
    }
    final effect = currentEffect;
    if (effect != null && effect.revivalPoints > 0) {
      currentPlayer.revivalSystem.addRevivalPoints(effect.revivalPoints);
    }
    _endTurn(swapPlayer: true);
  }

  void _applyEffect(UnoEffect effect) {
    currentEffect = effect;
    movesAllowed = effect.chessMoves;
    movesCompleted = 0;

    final p = currentPlayer;

    // +2 or +4 requires UI delay, shift to resolvingDraw2Draw4 phase
    if (effect.revivalPoints > 0) {
      phase = TurnPhase.resolvingDraw2Draw4;
      return;
    }

    // Reverse requires UI delay, shift to resolvingReverse phase
    if (effect.isReverse) {
      phase = TurnPhase.resolvingReverse;
      return;
    }

    // Skip requires UI delay, shift to resolvingSkip phase
    if (effect.isSkip) {
      phase = TurnPhase.resolvingSkip;
      return;
    }

    // Number cards grant chess moves
    phase = TurnPhase.awaitingChessMove;
  }

  /// Attempts to execute a chess move.
  /// Returns true if successful. If illegal, returns false and state is unchanged.
  bool executeChessMove(ChessMove move, ChessBoard board) {
    if (phase != TurnPhase.awaitingChessMove) {
      throw StateError('Not in chess move phase');
    }

    final engine = ChessEngine(board);
    final legalMoves = engine.generateLegalMoves(currentPlayer.controlledColor);

    // Find the exact matching legal move to ensure captures/flags are fully populated
    ChessMove? matchingMove;
    for (final m in legalMoves) {
      if (m.from == move.from &&
          m.to == move.to &&
          m.promotion == move.promotion) {
        matchingMove = m;
        break;
      }
    }

    if (matchingMove == null) {
      return false; // Move is illegal
    }

    // Execute move
    board.executeMove(matchingMove);

    // Record capture in the opponent's revival system
    if (matchingMove.capturedPiece != null) {
      waitingPlayer.revivalSystem.recordCapture(
        matchingMove.capturedPiece!.type,
        matchingMove.capturedPiece!.color,
      );
    }

    movesCompleted++;

    if (movesCompleted >= movesAllowed) {
      _endTurn(swapPlayer: true);
    }

    return true;
  }

  void _endTurn({required bool swapPlayer}) {
    currentCard = null;
    currentEffect = null;
    movesAllowed = 0;
    movesCompleted = 0;
    phase = TurnPhase.awaitingDraw;

    if (swapPlayer) {
      currentPlayerIdentity = currentPlayerIdentity == PlayerIdentity.player1
          ? PlayerIdentity.player2
          : PlayerIdentity.player1;
    }
  }
}
