# Phase 1 — Chess Core: Castling

## Implementation Date
2026-10-03

## Files Created
- `archives/phase1_chess_castling_report.md`
- `test/core/chess/castling_test.dart`

## Files Modified
- `lib/core/chess/board.dart`
- `lib/core/chess/chess_move.dart`
- `lib/core/chess/move_generator.dart`
- `lib/core/chess/chess_engine.dart`

## Castling Rights Representation
A new class `CastlingRights` was created to track `whiteKingSide`, `whiteQueenSide`, `blackKingSide`, and `blackQueenSide` booleans. This object is properly cloned alongside the board during engine state simulations so that temporary moves do not irreversibly forfeit the game's actual castling rights.

## King-Side Castling
Implemented by calculating paths from `e1/e8` to `g1/g8`. Added validations strictly rejecting the move if:
1. `f` or `g` are occupied.
2. `f` or `g` are attacked by an enemy.
3. The king is currently in check.
4. The rights were already permanently lost.

## Queen-Side Castling
Implemented by calculating paths from `e1/e8` to `c1/c8`. Validations added:
1. `b`, `c`, or `d` are occupied.
2. `c` or `d` are attacked by an enemy (the King does not traverse `b`, thus its attack safety is correctly ignored per standard chess rules).
3. The king is currently in check.
4. The rights were already permanently lost.

## Attack Validation
Successfully integrated the existing `isSquareAttacked` to assert that no square traversed by the King is under attack. Did not require writing redundant or recursive systems. 

## Castling Execution
Added a unified `executeMove(ChessMove move)` operation directly to the `ChessBoard`. For castling moves, this handler automatically relocates the appropriate Rook simultaneously with the King's placement, maintaining an atomic board update without intermediate invalid states.

## State Simulation
Replaced direct `movePiece` calls within the `ChessEngine`'s simulation loops with the new `executeMove` method to securely duplicate all rules. The Board's `.clone()` function was explicitly upgraded to deep-copy the `CastlingRights`.

## Edge Cases Tested
1. Path Blocked by friendly or enemy piece.
2. Currently in check.
3. Traversing an attacked square.
4. Ending on an attacked square.
5. King moves (Rights forfeit permanently).
6. Rook moves (Specific side right forfeit permanently).
7. Rook captured on its original square (Specific side right forfeit permanently).
8. Execution atomicity guarantees the board visually transitions from the before-state to the after-state seamlessly.

## Tests Added
11 highly specific edge-case scenarios were added into `test/core/chess/castling_test.dart` utilizing custom, minimalistic board constructions.

## Total Tests Passing
47 tests in total are currently passing flawlessly.

## flutter analyze Result
```
Analyzing UNO-CHESS...                                          
No issues found! (ran in 11.3s)
```

## flutter test Result
```
All tests passed!
```

## Architectural Decisions
- Centralized the rights and the execution of castling directly within `ChessBoard` while `MoveGenerator` purely handles the possibility computations. This safely restricts the application logic layer and preserves the "dumb board" model we established earlier while providing a fully featured API.
- Introduced a simple `isCastling` boolean property to `ChessMove` to allow downstream logic (like `executeMove`) to trigger atomic double-piece modifications rapidly without redundantly calculating algebraic file diffs.

## Issues / Ambiguities
None. 
