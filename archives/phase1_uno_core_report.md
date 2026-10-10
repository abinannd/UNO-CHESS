# Phase 1 — UNO Core

## Status
COMPLETE — all UNO Core models, generator, effects, and tests implemented and verified.

## Files Created
- `lib/core/uno/uno_color.dart` — `UnoColor` enum (red, yellow, green, blue, rainbow)
- `lib/core/uno/uno_card_type.dart` — `UnoCardType` enum (number, special, rainbow)
- `lib/core/uno/special_effect.dart` — `SpecialEffect` enum (plusTwo, plusFour, skip, reverse)
- `lib/core/uno/uno_card.dart` — immutable `UnoCard` with named factories
- `lib/core/uno/uno_effect.dart` — `UnoEffect` result model consumed by future Turn System
- `lib/core/uno/uno_card_generator.dart` — pure-Dart card generator with injectable `Random`
- `test/core/uno/uno_core_test.dart` — comprehensive test suite

## Files Modified
None. Chess Core untouched.

## Card Model
Three categories via typed factories:
- `UnoCard.number(value, color)` — value ∈ {1,2,3,4}, color ∈ normal colors
- `UnoCard.special(effect, color)` — effect ∈ SpecialEffect, color ∈ normal colors
- `UnoCard.rainbow()` — color = rainbow, no value/effect until resolved

## Probability Implementation
Implemented as cumulative threshold comparisons on `Random.nextDouble()`:
- Category: number < 0.45, special < 0.90, rainbow ≥ 0.90
- Within-number: 1 < 0.45, 2 < 0.75, 3 < 0.90, else 4
- Within-special: +2 < 0.25, +4 < 0.40, skip < 0.70, else reverse

Math verified by unit tests:
- Category totals = 1.0
- Within-number totals = 1.0
- Within-special totals = 1.0
- All 9 overall probabilities match spec (e.g. p(1) = 0.45×0.45 = 0.2025)

## Effects Implemented
| Card | Effect |
|---|---|
| Number 1–4 | `chessMoves` = 1–4 |
| +2 | `revivalPoints` = 2 |
| +4 | `revivalPoints` = 4 |
| Skip | `isSkip` = true, 0 moves |
| Reverse | `isReverse` = true |
| Rainbow | `isRainbow` = true (unresolved) |
| Rainbow resolved | Any of the above via `UnoEffect.resolve()` |

## Tests Added
52 new tests in `test/core/uno/uno_core_test.dart`:
- Card model (factories, all values, all colors, all effects)
- UnoEffect (all 9 card types, rainbow resolution to all 8 targets)
- Probability math (3 within-category checks + overall sum + all 9 individual values)
- Deterministic generator (fixed Random stub, all branches)
- Statistical sanity (10 000 draws, all types/values/effects/colors appear)

## Final Test Count
89 (chess) + 52 (UNO) = **141**

## flutter analyze Result
No issues found.

## flutter test Result
All tests passed.

## Important Decisions
- `UnoEffect` is a pure data object — no PlayerState mutation, consumed by future Turn System.
- `UnoCardGenerator` accepts an optional `Random` parameter for deterministic testing.
- Rainbow resolution is separated (`UnoEffect.resolve`) so the game/UI layer decides the choice.
- No `dart:math` usage in models — only in the generator.

## Issues / Ambiguities
None. All specified probabilities implemented exactly.
