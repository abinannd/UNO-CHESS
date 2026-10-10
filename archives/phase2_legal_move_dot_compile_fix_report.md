# Phase 2 — Legal Move Dot Compile Fix

## Error Addressed
Flutter threw an assertion error during compilation/tests: 
`backgroundBlendMode applies to BoxDecoration's background color or gradient, but no color or gradient was provided.`

This occurred because `BlendMode.multiply` was assigned to a `BoxDecoration` without a `color` parameter, which is illegal in Flutter.

## Fix Implemented
In `lib/ui/board/chess_square_widget.dart`, the invalid `BoxDecoration` and `Container` wrapper were completely removed. 

Instead, the `Image.asset` is now wrapped in a `ColorFiltered` widget using a custom `ColorFilter.matrix`. 

### How it works
The color matrix (`[-1, 0, 0, 0, 255]`) maps the image's luminance directly into its alpha channel while clamping the RGB channels to `0` (black). 
- Pure white pixels (R=255) resolve to an Alpha of 0 (completely transparent).
- Pure black pixels (R=0) resolve to an Alpha of 255 (completely opaque black).
- Grey/anti-aliased edge pixels become perfectly translucent black pixels.

This elegantly converts the opaque white background of `assets/ui/dot.png` into true transparency and yields a smooth, translucent black dot, matching the desired Chess.com style without violating any Flutter constraints.

## Constraints Respected
- **Transparent dot.png overlay:** Achieved perfectly via the color matrix.
- **Original chessboard square color unchanged:** The underlying background renders cleanly through the converted transparency.
- **No changes to game logic or rules:** The fix was strictly confined to `chess_square_widget.dart`.
