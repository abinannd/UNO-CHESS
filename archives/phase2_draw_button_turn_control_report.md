# Phase 2, Step 3: Draw Button & Turn Control Report

## Changed Files
1. `lib/screens/game/game_screen.dart`
2. `lib/core/game/turn_system.dart`

## DRAW Button Behavior
- **UI Addition**: A full-width `ElevatedButton` labeled "DRAW" was added at the bottom of the game screen, strictly beneath the chessboard.
- **Action**: When tapped, it instantiates an `UnoCardGenerator`, generates a random card according to the official probabilities, and passes it to `GameState.drawCard()`.
- **Availability**: The button is strictly bound to the existing game state. It is dynamically enabled only when `_gameState.turnPhase == TurnPhase.awaitingDraw` and disabled otherwise, preventing duplicate draws.
- **Cleanup**: Previously added temporary "auto-draw" mockups in `initState` and `_executeMove` were removed, ensuring true manual turn flow.

## Internal Draw-State Handling
- Introduced internal boolean state flags (`_p1HasDrawnInitialNumber`, `_p2HasDrawnInitialNumber`) inside `TurnSystem` to rigorously track whether each player has fulfilled the first-draw rule for the entirety of the game.

## First-Draw Enforcement
- In `TurnSystem.drawCard`, if a player has not yet drawn their initial number card (`!_currentPlayerHasInitialNumber`), the drawn card's type is verified.
- If a non-number card is drawn, the card is displayed via `currentCard = card`, but the phase is intentionally **not advanced**. It remains `TurnPhase.awaitingDraw`, naturally requiring the player to press "DRAW" again and redraw until a valid number card is obtained.
- Normal card-generation probabilities remain completely intact without arbitrary weighting.

## Chess Move Restrictions
- Chess piece movement remains locked behind `TurnPhase.awaitingChessMove`.
- Because an invalid first-draw fails to advance the phase, illegal chess moves are entirely blocked from occurring before a valid draw.
- Post-draw legal chess moves are counted normally. Invalid chess moves are rejected by `TurnSystem.executeChessMove` without advancing the move count, preserving exact rules.

## Limitations
- Drawing a Rainbow card accurately shifts the phase to `TurnPhase.awaitingRainbowResolution`, but since the Rainbow resolution menu is not implemented yet in the UI, the game will halt waiting for input. This is expected behavior and will be addressed in an upcoming Rainbow card UI step.
