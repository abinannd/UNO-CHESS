# Phase 1 — Chess Core: Checkmate & Stalemate

## Implementation Date
2026-10-03

## Files Created
- `archives/phase1_chess_checkmate_stalemate_report.md`

## Files Modified
- `lib/core/chess/chess_engine.dart`
- `test/core/chess/chess_engine_test.dart`

## APIs Added
- `bool isCheckmate(ChessColor color)` added to `ChessEngine`
- `bool isStalemate(ChessColor color)` added to `ChessEngine`

## Checkmate Logic
Implemented cleanly within the `ChessEngine` by returning `true` only if the specified player is currently in check (`isInCheck(color)`) AND has absolutely zero legal moves (`!hasLegalMoves(color)`).

## Stalemate Logic
Implemented within the `ChessEngine` by returning `true` only if the specified player is NOT currently in check (`!isInCheck(color)`) AND has absolutely zero legal moves (`!hasLegalMoves(color)`). 

## Edge Cases Tested
1. Player in check with no legal move (Checkmate).
2. Player in check with an escape move (Not Checkmate).
3. Check can be blocked by another friendly piece (Not Checkmate).
4. Attacking piece can be captured safely by a friendly piece (Not Checkmate).
5. Player not in check with zero legal moves (Stalemate).
6. Player not in check with legal moves (Not Stalemate).

## Tests Added
6 new explicit board setup test cases were added specifically targeting checkmate and stalemate edge cases within `test/core/chess/chess_engine_test.dart`.

## Total Tests Passing
36 tests are currently passing in the suite.

## flutter analyze Result
```text
Analyzing UNO-CHESS...                                          
No issues found! (ran in 11.5s)
```

## flutter test Result
```text
All tests passed!
```

## Architectural Decisions
- Kept the checkmate and stalemate evaluations purely mathematical using the existing `isInCheck()` and `hasLegalMoves()` building blocks instead of creating parallel state trackers. 
- Avoided mutating board state for game-end scenarios; checkmate/stalemate are simply queried engine properties rather than hardcoded states stored within the `ChessBoard`. 

## Issues / Ambiguities
None. The established pseudo-legal to legal pipeline natively and elegantly supported checkmate and stalemate derivations without requiring architecture overhauls.
