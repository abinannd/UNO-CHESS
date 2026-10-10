# Phase 2 — Chess Interaction

## Status
COMPLETE — Full chess-board interaction is implemented on top of the existing Chess Board UI.

## Files Modified
| File | Change |
|------|--------|
| `lib/screens/game/game_screen.dart` | Refined `_onSquareTapped` to re-select another own piece instead of deselecting (UX fix). All interaction logic was already scaffolded; this is the only behavioural correction made. |

## Files Created
| File | Purpose |
|------|---------|
| `test/ui/board/chess_interaction_test.dart` | 15 focused widget/unit tests across 9 groups covering every required interaction scenario. |

## Architecture — No Core Changes
All chess rules remain in the pure-Dart game core. The Flutter UI exclusively delegates to `ChessEngine` and `GameState`:

| Interaction Concern | Handled By |
|---------------------|-----------|
| Legal move generation | `ChessEngine.generateLegalMoves` |
| Move execution + capture tracking | `GameState.executeChessMove` → `TurnSystem` |
| Turn phase / color restriction | `GameState.turnPhase`, `currentPlayer.controlledColor` |
| Check detection | `ChessEngine.isInCheck` |
| Terminal status | `GameState.status` (`GameStatus.checkmate` / `stalemate`) |
| Promotion rules | Core `MoveGenerator` generates 4 promotion variants; UI shows picker |

## Implemented Behaviours

### 1. Piece Selection
- Tap own-color piece → selected, legal destinations computed and passed to `ChessBoardWidget`.
- Tap a different own piece while one is already selected → re-selects (switches without an intermediate deselect).
- Tap empty square or non-legal opponent square → deselects.

### 2. Legal Move Highlighting
- `ChessEngine.generateLegalMoves(controlledColor)` called on every selection.
- Filtered to the selected piece's `from` position.
- Destination `Position` list passed into `ChessBoardWidget.legalDestinations` → rendered as dots by `ChessSquareWidget`.
- No chess logic lives in the widget layer.

### 3. Move Execution
- Tap a highlighted destination → `GameState.executeChessMove(ChessMove(from, to))`.
- Core returns `bool`; only `true` triggers `setState`.
- Illegal taps are silently ignored — board and selection remain unchanged.

### 4. Captures
- Core `TurnSystem.executeChessMove` records the captured piece in the waiting player's `RevivalSystem`.
- UI calls the same path as any other move; no capture-specific Flutter code added.

### 5. Turn Restrictions
- `_onSquareTapped` returns immediately if `GameState.status != active` or `turnPhase != awaitingChessMove`.
- Only `currentPlayer.controlledColor` pieces are selectable.
- `GameState.executeChessMove` internally enforces move count limits via `TurnSystem`.

### 6. Promotion
- `MoveGenerator` generates four `ChessMove` variants (queen, rook, bishop, knight) for any pawn reaching the back rank.
- When any matching move for the chosen destination has `promotion != null`, `_showPromotionDialog` is invoked.
- User selects a piece type → executes the move with the correct `PieceType` promotion.
- Core handles the board mutation; UI contributes only the picker `AlertDialog`.

### 7. Check
- `_checkPosition` getter: calls `ChessEngine.isInCheck` for both colours after each render.
- Passes the king's `Position` as `checkPosition` to `ChessBoardWidget`.
- `ChessSquareWidget` colours the square red when `isCheck == true`.

### 8. Terminal Lockout
- `GameState` constructor calls `_updateGameStatus()` immediately; terminal boards are detected before the first frame.
- `_onSquareTapped` early-exits when `status != active`.
- `ChessBoardWidget.onSquareTapped` receives `null` in terminal states, preventing all interaction.

## Tests Added — 9 Groups, 15 Tests

| # | Group | Tests | What Is Verified |
|---|-------|------:|------------------|
| 1 | Own-piece selection | 2 | Square marked `isSelected`; re-selection switches cleanly |
| 2 | Opponent-piece rejection | 2 | No selection on opponent tap; prior selection cleared |
| 3 | Legal move highlighting | 2 | Correct squares flagged `isLegalDestination`; others not |
| 4 | Illegal destination | 1 | Board unchanged; selection cleared |
| 5 | Successful move | 1 | Selection cleared; legal-destination highlights removed after move |
| 6 | Capture | 1 | `PlayerState.capturedPieces` gains the captured piece with correct type |
| 7 | Turn restriction | 2 | `null` callback ignores taps; opponent pieces cannot be selected |
| 8 | Check indication | 2 | King square `isCheck=true`; other squares `isCheck=false` |
| 9 | Terminal lockout | 2 | `GameState` rejects moves post-checkmate; locked board ignores taps |

## Test Counts

| Scope | Before | After |
|-------|-------:|------:|
| Total passing | 209 | **224** |
| New interaction tests | — | **+15** |

## Analyze Result
`flutter analyze`: **0 errors, 0 warnings.**
16 pre-existing `info`-level lints in Phase 1 files (UNO card generator, `chess_square_widget`) — none introduced by this phase.

## Not Implemented (Per Specification)
- UNO card UI
- Animations / sounds
- HUD / player information display
- New game rules

## Issues / Ambiguities Resolved
- **Re-selection bug:** Original code deselected when tapping a second own piece rather than switching selection. Fixed in `_onSquareTapped` to re-select any own-piece tap regardless of current selection state.
- All other interaction behaviours were already correctly scaffolded from the Phase 2 Chess Board UI phase.

