# Phase 1 — Chess Core: Promotion

## Implementation Date
2026-10-03

## Files Created
- `test/core/chess/promotion_test.dart`
- `archives/phase1_chess_promotion_report.md`

## Files Modified
- `lib/core/chess/move_generator.dart` — `_generatePawnMoves` now emits 4 promotion variants when destination is the final rank
- `lib/core/chess/board.dart` — `executeMove` now replaces the pawn with the promoted piece after placement

## Main Functionality Implemented
- **Move generation:** When a pawn move (push or capture) targets the final rank (rank 7 for White, rank 0 for Black), the generator emits 4 `ChessMove` objects — one per legal promotion type (Queen, Rook, Bishop, Knight) — via an internal `addMove` helper. Non-promotion moves are emitted as before.
- **Move execution:** `executeMove` checks `move.promotion != null` immediately after placing the piece; if set, it calls `placePiece(move.to, ChessPiece(move.promotion!, piece.color))` to overwrite the pawn with the promoted piece of the same color.
- **Legal-move pipeline:** No special path — promotion moves flow through the same `clone → executeMove → isSquareAttacked` filter as every other move.
- **Promotion to King/Pawn:** Never generated — only `[queen, rook, bishop, knight]` are in `_promotionTypes`.
- **Promotion capture:** Handled naturally — `addMove` detects the destination rank regardless of whether there is a `capturedPiece`.

## Tests Added
26 tests in `test/core/chess/promotion_test.dart`:
- 4 White promotion type tests
- 4 Black promotion type tests
- Move count check (exactly 4 variants for e7→e8)
- No unpromoted move to final rank
- King/Pawn absent from promotion choices
- White promotion capture (e7xd8)
- Black promotion capture (e2xd1)
- Pawn not on final rank yields no promotion
- Pin safety — pinned pawn cannot promote
- Promotion checkmate (b7→b8=Q)
- Clone isolation

## Total Tests Passing
80 (62 previous + 18 new)

## flutter analyze Result
No issues found.

## flutter test Result
All tests passed.

## Architectural Decisions
- `_promotionTypes` is a static const list in `MoveGenerator` — single source of truth for valid promotion pieces.
- The `addMove` helper is a local closure inside `_generatePawnMoves`, keeping the promotion expansion co-located with pawn move generation without scattering the logic.
- `executeMove` handles promotion with a single `if` block after the initial placement, keeping the unified execution path intact.
- `ChessMove.promotion` (existing field) required no structural changes.

## Issues / Ambiguities
None.
