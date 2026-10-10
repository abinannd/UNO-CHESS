# Phase 2, Step 1: UNO Card UI Report

## Changed Files
1. `pubspec.yaml`:
   - Added `assets/cards/` to the flutter assets section so the UNO card images can be loaded.
2. `lib/ui/cards/uno_card_widget.dart` (New File):
   - Created `UnoCardWidget`, a reusable stateless widget for rendering an `UnoCard`.
   - Maps the internal `UnoCard` model attributes to the exact asset filenames in `assets/cards/`.
3. `lib/screens/game/game_screen.dart`:
   - Imported and integrated `UnoCardWidget` into the layout above the chessboard using a `Column`.
   - Handles the initial `null` state before the first card is drawn by showing a stylized card back placeholder.

## Supported Card Types & Asset Mapping
The `UnoCardWidget` dynamically builds the asset path based on `UnoCardType`, `UnoColor`, and `SpecialEffect` or `numberValue`:

- **Number Cards (0-4)**: Mapped to `<Color>_<Number>.jpg` (e.g., `Blue_1.jpg`, `Red_0.jpg`).
- **+2 Cards**: Mapped to `<Color>_Draw_2.jpg` (e.g., `Yellow_Draw_2.jpg`).
- **Skip Cards**: Mapped to `<Color>_Skip.jpg` (e.g., `Green_Skip.jpg`).
- **Reverse Cards**: Mapped to `<Color>_Reverse.jpg`. Specifically handles the irregular filename `RED_Reverse.jpg`.
- **+4 Cards**: Mapped directly to `plus_4_draw card.png`.
- **Rainbow/Wild Cards**: Mapped to `rainbow.png` for color-change functionality.

## Limitations & UI Considerations
- **Aspect Ratio**: The widget enforces a `1:1.5` aspect ratio. The `BoxFit.contain` property is used so that assets maintain their original dimensions without cropping or stretching.
- **Transparency**: The image renderer itself doesn't apply a solid background, satisfying the requirement to avoid white backgrounds on transparent PNGs (e.g., `plus_4_draw card.png`).
- **Fallback UI**: If the card is `null` (e.g. before the first draw) or the asset path fails to resolve, a dark styled rounded rectangle displaying "UNO" is rendered.
- **Responsive Layout**: The UNO card is constrained to a fixed width of `100` suitable for mobile viewing, while the chessboard retains the remaining space via an `Expanded` widget.
