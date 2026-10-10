# Phase 1 — Revival System

## Status
COMPLETE — all revival rules, validation, and tests implemented and verified.

## Files Created
- `lib/core/revival/revival_cost.dart` — static RP cost lookup; King deliberately excluded
- `lib/core/revival/captured_piece.dart` — lightweight captured-piece record
- `lib/core/revival/revival_system.dart` — per-player revival pool, RP tracking, spawn logic, atomic revival
- `test/core/revival/revival_test.dart` — comprehensive test suite
- `archives/phase1_revival_system_report.md`

## Files Modified
None. Chess/UNO Core untouched.

## Revival Rules Implemented
| Rule | Implementation |
|---|---|
| Pawn=1, Knight/Bishop=3, Rook=5, Queen=10 RP | `RevivalCost._costs` map |
| King cannot be revived | `RevivalCost.of(king)` throws `ArgumentError` |
| Only captured pieces revivable | `capturedPieces` list checked before revival |
| RP deducted on revival | `revivalPoints -= cost` in `revive()` |
| Piece removed from pool | `capturedPieces.removeAt(index)` |
| Placed on valid unoccupied spawn square | `board.placePiece(spawnSquare, ...)` |
| Spawn squares per spec | Static `_whiteSpawns` / `_blackSpawns` maps |
| Any-order revival | No FIFO — searches by type match |

## Tests Added
36 tests in `test/core/revival/revival_test.dart`:
- All 5 costs + King throws + isRevivable checks
- RP accumulation
- Capture recording + King silently ignored
- Spawn square detection (all types, both colors, occupied filtering)
- canRevive (all failure modes + success)
- revive success (all 5 types × 2 colors = 10 cases)
- revive rejection (King, insufficient RP, not captured, invalid square, occupied square)
- Alternative spawn when first occupied
- Multiple revivals in any order (queen→pawn→rook)
- No duplicate piece creation

## Final Test Count
128 (chess+UNO) + 36 (revival) = **164**

## flutter analyze Result
No issues found.

## flutter test Result
All tests passed.

## Important Decisions
- `RevivalSystem` is per-player — the Turn System will hold one per color.
- `revive()` is atomic: validates fully before mutating anything.
- Spawn squares are `const` static maps — no runtime allocation per call.
- `recordCapture(king, ...)` is silently ignored (King cannot be revived, no error needed).

## Issues / Ambiguities
None.
