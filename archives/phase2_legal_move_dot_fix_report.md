# Phase 2 — Legal Move Dot Fix

## Issue
The custom legal-move indicator (`assets/ui/dot.png`) was rendering with an opaque white rectangular box around the dot, occluding the underlying chess board square color.

## Root Cause
The `dot.png` image asset lacks a transparent alpha channel, meaning it consists of a black dot on a solid white background. Rendering it directly with `Image.asset` simply drew the solid white pixels over the board.

## Fix Implemented
In `lib/ui/board/chess_square_widget.dart`, the `Image.asset` rendering was replaced with a `Container` using a `BoxDecoration`. The image is applied as a `DecorationImage`, and the box composites it against the board using `backgroundBlendMode: BlendMode.multiply`. 

Because pure white has RGB values of `(1, 1, 1)`, multiplying it against the underlying chess square color leaves the square color completely unchanged (effectively rendering the white transparent). The black dot `(0, 0, 0)` multiplied by the background results in black, cleanly overlaying the dot onto the board exactly as desired.

### Constraints Respected
- **No opaque background/opacity layers added:** The fix relies purely on blending mathematics rather than adding masking containers.
- **Board original color visible:** Yes, the white background is mathematically stripped away.
- **API and Rules unchanged:** Chess logic, piece widgets, and the interaction flow are untouched.
- **No changes to the PNG:** The original `assets/ui/dot.png` asset is preserved and utilized directly.
