# Phase 2: Revival UI Report

## 1. Files Changed
| File | Change |
|---|---|
| `lib/core/game/game_state.dart` | Added `canReviveAny` getter and `revive(type, square)` method. Added missing imports for `PieceType` and `Position`. |
| `lib/ui/revival/revival_dialog.dart` | New file — the complete revival dialog widget. |
| `lib/screens/game/game_screen.dart` | Added `revival_dialog.dart` import, `_showRevivalDialog()` method, and REVIVE button alongside DRAW button. |

## 2. How Eligibility Is Calculated
Eligibility per piece tile is determined by calling the **existing** `RevivalSystem.canRevive(type, color, board)` method on the current player's revival system. This method checks:
1. `RevivalCost.isRevivable(type)` — King is excluded automatically.
2. `revivalPoints >= RevivalCost.of(type)` — sufficient RP.
3. At least one `CapturedPiece` of that type/color exists in the player's pool.
4. At least one valid original spawn square for that piece is currently unoccupied on the board.

If all four conditions are met, the tile gets a **green** border. Otherwise **red**. No secondary revival rules were implemented in the UI — it reads directly from the core.

## 3. How Piece Selection and Spawn-Square Selection Work
- **Single spawn square**: When tapping a green tile and only one valid spawn exists, revival is executed immediately via `GameState.revive()`.
- **Multiple spawn squares**: A secondary `AlertDialog` appears listing all available algebraic-notation squares (e.g., "a1", "h1"). The player selects one, then `GameState.revive()` is called.
- **Red tile tap**: Does not mutate any state. A `SnackBar` explains why revival is unavailable (no captured piece, insufficient RP, or all spawn squares blocked).

## 4. Core Revival Rules Preserved
- King tiles are never displayed (filtered by `RevivalCost.isRevivable`).
- RP is only deducted inside `RevivalSystem.revive()` after all checks pass.
- Captured piece is removed from the pool only inside `RevivalSystem.revive()` on success.
- Piece placement is done by `RevivalSystem.revive()` via `ChessBoard.placePiece()`.
- Failed revive calls throw `RevivalException`; the UI catches this and shows a SnackBar, leaving state unchanged.
- Player identity drives which revival system is queried — `gameState.currentPlayer` is used, not a hardcoded P1/P2 assumption. This means Reverse-card color swaps are handled correctly.

## 5. Unresolved Issues
- The REVIVE button is available whenever `canReviveAny` is true, regardless of which `TurnPhase` the game is in. Depending on future game design decisions, it may need to be restricted to specific phases (e.g., only `awaitingDraw` or `awaitingChessMove`). This is a product decision, not a defect.
- Piece images use `assets/pieces/{color}_{type}.png` paths (e.g., `assets/pieces/white_pawn.png`). These match the confirmed filenames in `assets/pieces/`. If `pubspec.yaml` doesn't already include `assets/pieces/` as a registered asset path, images will fail to load.
