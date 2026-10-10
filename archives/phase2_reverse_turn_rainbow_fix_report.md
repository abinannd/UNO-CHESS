# Phase 2, Step 3: Draw / Reverse / Turn Control Bug Fix Report

## 1. Minimal Fixes Implemented
- Introduced a new core phase `TurnPhase.resolvingReverse` and `completeReverse()` method to delay Reverse execution.
- Added a 1-second delay in `GameScreen` when a Reverse is drawn, preserving the `currentCard` for HUD rendering before finalizing the orientation and color swap.
- Implemented `_showRainbowDialog()` in `GameScreen` to provide the missing UI for `TurnPhase.awaitingRainbowResolution`. It passes the selected `UnoEffect` back to `GameState.resolveRainbow()`.

## 2. Root Cause Summaries
- **Reverse Card Not Displayed & Timing**: `_endTurn` was previously called synchronously inside `_applyEffect` for Reverse. This cleared `currentCard` immediately (hiding it from the HUD) and instantly rotated the board. By shifting this to a delayed `completeReverse()` phase, the HUD gets time to render.
- **Player Ownership / Turn Bug After Reverse**: The premature call to `_endTurn(swapPlayer: false)` caused the internal turn lifecycle to desynchronize between `currentPlayerIdentity` and the controlled colors. Shifting the player state swaps into `completeReverse()` ensures player identity and assigned colors mutate cleanly only after the UI delay is fulfilled.
- **Initial Number-Card Requirement**: This was functioning correctly at the core level (rejecting Special/Rainbow cards), but ensuring it properly halted the Turn Phase relies on the UI waiting for a valid phase transition. No rules were weakened.
- **Rainbow Card**: The core correctly paused the game in `TurnPhase.awaitingRainbowResolution`, but the UI lacked the dialog integration to allow the player to select the desired effect and pipe it to `resolveRainbow()`.

## 3. Files Changed
1. `lib/core/game/turn_system.dart` (Added `TurnPhase.resolvingReverse` and `completeReverse()`)
2. `lib/core/game/game_state.dart` (Exposed `completeReverse()`)
3. `lib/screens/game/game_screen.dart` (Added 1-second UI delay for Reverse and `_showRainbowDialog()` for Rainbow effects)

## 4. Unresolved Issues / Ambiguities
- The 1-second delay for Reverse uses `Future.delayed`. If the user rapidly closes the screen within that 1 second, the `mounted` check protects against exceptions, but the game state effectively pauses. This is expected for now until proper animation controllers are introduced.
- Rainbow resolution handles the Reverse effect recursively (if a user chooses Reverse from the Rainbow dialog, it safely triggers the 1-second Reverse delay logic). This is completely functional but slightly visually abrupt without final animations.
