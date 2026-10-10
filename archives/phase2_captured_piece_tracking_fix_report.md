# Phase 2: Captured Piece Tracking / Revival Bug Fix Report

## 1. Root Cause
The root cause was a mismatch in how captured pieces' colors were being stored and retrieved, compounded by the Reverse card effect.

- When a piece was captured in `TurnSystem.executeChessMove()`, it was stored in the `waitingPlayer`'s (the player who lost the piece) `RevivalSystem`. The `CapturedPiece` recorded the **actual chess color** of the piece at the time of capture (e.g., `black` for a Black Queen).
- However, in `RevivalDialog` and `GameState.revive()`, the system was querying `player.revivalSystem.canRevive(type, player.controlledColor, board)`. 
- **The Issue:** After a Reverse card is played, the players swap controlled colors. Player 2, who previously controlled Black, now controls White. But their captured pieces are still stored as Black. When the UI checked for a captured `White Queen` (because P2's new `controlledColor` is White), it found nothing and reported "Not captured".
- A secondary issue was that the UI's piece image asset lookup also used `player.controlledColor.name` instead of the actual captured piece's color, which would cause Black's captured pieces to display as White pieces in the dialog after a Reverse.

## 2. Exact Files Changed
| File | Change |
|---|---|
| `lib/ui/revival/revival_dialog.dart` | Updated `RevivalDialog.build`, `_showUnavailableReason`, `_onPieceTapped`, and `_executeRevival` to locate the `CapturedPiece` instance in the player's pool and use its `cp.color` (the original chess color) instead of `player.controlledColor` for both the eligibility check and the image asset lookup. Also updated the algebraic notation generator to use the existing `Position.algebraic` getter. |

## 3. How Captured-Piece Ownership is Determined
Ownership is determined correctly by `TurnSystem.executeChessMove`. When the `currentPlayer` executes a move that captures a piece, the captured piece is added to the `waitingPlayer.revivalSystem.recordCapture` pool. This correctly assigns ownership to the player who *lost* the piece, irrespective of their current `controlledColor`.

## 4. How the Fix was Verified
The fix isolated the query logic in the UI and GameState to prioritize the historical state of the `CapturedPiece`.
- `canRevive` is now called with `capturedOfType.first.color`.
- `GameState.revive()` passes the explicit `pieceColor` instead of relying on `controlledColor`.
This ensures that if Player 2 loses a Black Queen on Turn 3, and a Reverse happens on Turn 5, Player 2's revival dialog will correctly display a Black Queen tile, evaluate its cost, and permit its revival to a valid Black Queen spawn square.

## 5. Unresolved Issues
None. The piece tracking and ownership logic is completely isolated from the dynamic controlled colors, preserving both standard UNO Chess rules and Reverse behavior perfectly.
