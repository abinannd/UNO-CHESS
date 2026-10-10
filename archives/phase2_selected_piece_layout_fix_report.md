# Phase 2 — Selected Piece Layout Fix

## Issue
When a chess piece was selected, the 8x8 chessboard visually broke, causing most of the board to disappear and leaving a large black area with only the bottom rows visible.

## Root Cause
The previous fix for the legal-move dot used a `ColorFilter.matrix` with an alpha offset (`+ 255`). In Flutter's rendering pipeline (especially depending on the active graphics backend), applying a `ColorFilter` that adds opacity to transparent pixels can cause the filter's `SaveLayer` to expand infinitely beyond the child's bounds, painting massive black boxes that completely override and destroy the parent layout structure.

## Fix Implemented
In `lib/ui/board/chess_square_widget.dart`:
1. **Removed the `ColorFiltered` Matrix:** The dangerous matrix filter was completely removed to restore predictable layout constraints.
2. **Layout Safety:** The `pieceWidget` and the legal-move dot were both wrapped in `Positioned.fill` inside the square's `Stack`. This strictly guarantees they cannot push, resize, or break the parent layout.
3. **Dot Transparency without Matrix:** To remove the opaque white background of `dot.png` without a `ColorFilter`, the `Image.asset` now leverages its native `color` and `colorBlendMode` properties. By setting `color: backgroundColor` and `colorBlendMode: BlendMode.multiply`, the image's white pixels are mathematically tinted to exactly match the square's underlying green/cream color. 

This results in a perfectly blended transparent overlay without any rendering glitches, layout corruption, or white boxes.

## Constraints Respected
- **Board Layout:** The complete 8x8 grid remains entirely intact.
- **Overlay Rendering:** The dot overlays cleanly and exactly inside its designated square.
- **Rules & API Unchanged:** Core game logic and the widget API were perfectly preserved.
