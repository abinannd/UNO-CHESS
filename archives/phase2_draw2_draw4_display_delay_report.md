# Phase 2: +2 / +4 Display Delay and RP Resolution Fix Report

## 1. +2 / +4 Display Delay Implemented
- Introduced a new `TurnPhase.resolvingDraw2Draw4` phase and a `completeDraw2Draw4()` method, exactly mirroring the `resolvingReverse` and `resolvingSkip` architectures.
- When a +2 or +4 is drawn, `_applyEffect` halts state mutation by entering this new phase, intentionally delaying the RP award and turn transition.
- `GameScreen` handles this phase by invoking a 1-second `Future.delayed` which allows the HUD to display the +2/+4 card natively.
- After 1 second, `completeDraw2Draw4()` executes: it accurately awards the RP to the active player's revival system and then safely ends their turn, transitioning control to the opponent.

## 2. Root Cause
Similarly to the Reverse and Skip bugs, `_applyEffect` was synchronously awarding the Revival Points and ending the turn via `_endTurn(swapPlayer: true)`. Because `_endTurn` resets `currentCard` to `null` to cleanly start the opponent's turn, the +2/+4 card was cleared from state before the Flutter framework could render it in the HUD. Shifting the RP assignment and turn swap into the `completeDraw2Draw4()` method resolves the race condition, enforcing the proper visual sequence.

## 3. Exact Files Changed
1. `lib/core/game/turn_system.dart` (Added `TurnPhase.resolvingDraw2Draw4`, moved RP addition to `completeDraw2Draw4()`)
2. `lib/core/game/game_state.dart` (Exposed `completeDraw2Draw4()`)
3. `lib/screens/game/game_screen.dart` (Added 1-second UI delay check for `resolvingDraw2Draw4` in `_resolveRainbow()` and the `DRAW` button logic).

## 4. Unresolved Issues
- As with Skip and Reverse, the test suites (which attempt to simulate drawing Special cards on Turn 1) currently fail because they are unaware of the Initial Number-Card requirement. These tests must be updated to simulate a valid opening sequence.
- The 1-second delay uses `Future.delayed`. It works functionally, but if the user backgrounds the app rapidly, it might pause execution. Proper animation controllers are still necessary for production polish.
