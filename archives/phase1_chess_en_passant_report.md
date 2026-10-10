# Phase 1 — Chess Core: En Passant

## Implementation Date
2026-10-03

## Files Created
- `test/core/chess/en_passant_test.dart`
- `archives/phase1_chess_en_passant_report.md`

## Files Modified
- `lib/core/chess/chess_move.dart` — Added `isEnPassant` property
- `lib/core/chess/board.dart` — Added `enPassantTarget` field, clone propagation, and `executeMove` en passant handling
- `lib/core/chess/move_generator.dart` — Added en passant move generation in `_generatePawnMoves`

## En Passant State Representation
A `Position? enPassantTarget` field was added to `ChessBoard`. It stores the square the capturing pawn would move **to** (the intermediate square behind the double-stepped pawn). It is:
- Set by `executeMove` whenever a pawn performs a two-square advance
- Cleared by `executeMove` on every other move (including another pawn single-step)
- Deep-copied by `clone()` so simulations do not affect real game state

This avoids storing a bare boolean and instead stores enough information to pinpoint the exact eligible square.

## White En Passant
When White pawn is on rank 5 (index 4) and `enPassantTarget` points to rank 6 (index 5) at an adjacent file, the `MoveGenerator` emits a `ChessMove` with `isEnPassant: true` and `to = enPassantTarget`. On execution, the White pawn moves to `d6`/`f6` and the Black pawn is removed from `d5`/`f5` (one rank behind the destination).

## Black En Passant
Symmetric: Black pawn on rank 4 (index 3), `enPassantTarget` on rank 3 (index 2). Captured White pawn removed from rank 4.

## Expiration Logic
Every call to `executeMove` unconditionally sets `enPassantTarget = null` unless the moved piece was a pawn performing a double-step. This means:
- Any non-double-step move clears the target.
- The opportunity is strictly one-move-window.
- A delayed capture attempt will find `enPassantTarget == null` and no EP move is generated.

## Move Generation
Added inside `_generatePawnMoves`:
1. Read `board.enPassantTarget`.
2. If non-null and on the correct target rank (`pos.rank + direction`), check file adjacency (`abs(epTarget.file - pos.file) == 1`).
3. Look up the pawn that sits at `Position(epTarget.file, pos.rank)` — the actual enemy pawn.
4. If it is an enemy pawn, emit `ChessMove(from, to=epTarget, capturedPiece, isEnPassant: true)`.

The move is also filtered through the existing `ChessEngine.generateLegalMoves` King-safety pipeline (clone → execute → check-king) so no special path is bypassed.

## Move Execution
`executeMove` in `ChessBoard` handles `isEnPassant`:
1. Moves capturing pawn from `from` to `to`.
2. Derives captured pawn rank: `move.to.rank - 1` (White) or `move.to.rank + 1` (Black).
3. Calls `removePiece(Position(move.to.file, capturedRank))` — the destination column, original rank.
4. Clears `enPassantTarget` since the opportunity is consumed.

## King Safety
En passant candidates flow through `ChessEngine.generateLegalMoves` identical to normal moves:
1. Clone board + state (including `enPassantTarget`).
2. Call `simulatedBoard.executeMove(move)` — this removes both the captured pawn and moving pawn from the correct squares.
3. Check whether the moving player's King is attacked via `isSquareAttacked`.
4. If King is in check after the simulated EP, the move is discarded.

No separate shortcut was introduced.

## Discovered-Check Scenario
Test: White King on `e5`, White pawn on `d5`, Black pawn on `c5`, Black rook on `a5`.  
`enPassantTarget = c6`.  
En passant `d5xc6` would clear both `d5` and `c5`, opening the entire rank 5 from `a5` to `e5`, putting the White King in check from the rook.  
The engine correctly rejects this move.

## Edge Cases Tested
1. Basic White en passant
2. Basic Black en passant
3. No double-step → enPassantTarget null → no EP moves
4. Capturing pawn on wrong rank (e4 instead of e5 with ep target at d6)
5. Capturing pawn too far away (a5 instead of adjacent e5)
6. Same-color adjacent pawn → EP not generated (color check)
7. Expiration: executeMove with non-double-step clears enPassantTarget
8. Execution: captured pawn removed from actual square (not destination)
9. Black en passant execution atomicity
10. executeMove sets enPassantTarget on double-step
11. executeMove clears enPassantTarget on single-step
12. Discovered-check via rank opening → EP rejected
13. Valid EP with safe King remains legal
14. clone() correctly copies enPassantTarget
15. Simulated clone does not mutate real board

## Tests Added
15 new tests in `test/core/chess/en_passant_test.dart`.

## Total Tests Passing
62 total tests passing (47 previous + 15 new).

## flutter analyze Result
```
Analyzing UNO-CHESS...
No issues found!
```

## flutter test Result
```
All tests passed!
```

## Architectural Decisions
- `enPassantTarget` lives on `ChessBoard` alongside `castlingRights` — both are historical game state, not inferable from board position alone.
- `clone()` copies both, so simulations are fully isolated.
- `isEnPassant` flag on `ChessMove` is the single source of truth that triggers special execution in `executeMove`. The captured pawn square is derived inside `executeMove` deterministically, not stored redundantly.
- No global variables, no magic strings, no parallel mutation paths.

## Issues / Ambiguities
None. The existing architecture composed cleanly with en passant without requiring structural changes.
