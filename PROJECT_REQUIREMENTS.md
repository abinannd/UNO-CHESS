# UNO CHESS — PROJECT REQUIREMENTS

## 1. PROJECT IDENTITY

Project Name:
UNO Chess

Project Type:
Two-player hybrid strategy game

Core Concept:
UNO Chess combines the standard rules of Chess with UNO-style cards.

Primary Objective:
Checkmate the opponent's King.

Target Platforms:
- Android
- iOS
- Windows

Primary Development Technology:
- Flutter
- Dart

Development Approach:
Mobile-first, cross-platform, modular, and testable.


## 2. CORE GAME CONCEPT

The Chess system remains the foundation of the game.

Standard Chess mechanics must remain valid, including:

- Piece movement
- Legal moves
- Captures
- Check
- Checkmate
- Stalemate
- Castling
- En passant
- Pawn promotion
- King safety

UNO mechanics modify the flow of the game but must NEVER allow
an illegal Chess move.

The ultimate objective remains checkmate.


## 3. PLAYERS

The game supports exactly two players.

Initial assignment:

Player 1 → White
Player 2 → Black

The Reverse card can change which player controls White and Black.


## 4. UNO CARD SYSTEM

There are three card categories:

1. Number Cards
2. Special Cards
3. Magical Card

Overall probability:

Number Cards → 45%
Special Cards → 45%
Magical Card → 10%

Normal card colors:

- Red
- Yellow
- Green
- Blue

The Magical Card is Rainbow.


## 5. NUMBER CARDS

Available:

1
2
3
4

A number card determines how many consecutive legal Chess
moves the player can make during that turn.

Number distribution inside Number Cards:

1 → 45%
2 → 30%
3 → 15%
4 → 10%

Overall probabilities:

1 → 20.25%
2 → 13.50%
3 → 6.75%
4 → 4.50%


## 6. SPECIAL CARDS

Available:

+2
+4
Skip
Reverse

Distribution inside Special Cards:

+2 → 25%
+4 → 15%
Skip → 30%
Reverse → 30%

Overall probabilities:

+2 → 11.25%
+4 → 6.75%
Skip → 13.50%
Reverse → 13.50%


## 7. +2 CARD

The +2 card gives the current player:

2 Revival Points (RP)

The player can use RP to revive eligible captured pieces.

The player can select any eligible lost piece.

There is no FIFO restriction.


## 8. +4 CARD

The +4 card gives:

4 Revival Points (RP)

The player can spend these points to revive eligible captured pieces.

The player chooses which eligible lost piece to revive.


## 9. REVIVAL COSTS

Piece revival costs:

Pawn → 1 RP
Knight → 3 RP
Bishop → 3 RP
Rook → 5 RP
Queen → 10 RP
King → Cannot be revived

A player can only revive pieces that were actually lost.

A player cannot create a new piece through revival.


## 10. REVIVAL SPAWN SYSTEM

A revived piece must be placed on a valid original starting
square for that piece.

The selected square must:

1. Be a valid starting square for that piece.
2. Currently be unoccupied.

White starting positions:

Rooks:
a1, h1

Knights:
b1, g1

Bishops:
c1, f1

Queen:
d1

Pawns:
a2, b2, c2, d2, e2, f2, g2, h2

King:
Cannot be revived.

Black starting positions:

Rooks:
a8, h8

Knights:
b8, g8

Bishops:
c8, f8

Queen:
d8

Pawns:
a7, b7, c7, d7, e7, f7, g7, h7

King:
Cannot be revived.

If all valid spawn positions for a piece are occupied,
that piece cannot currently be revived.


## 11. REVIVAL POINT MANAGEMENT

Revival Points belong to the player.

Unused RP may remain available according to the game rules.

When a piece is successfully revived:

- Deduct its RP cost.
- Remove that piece from the captured/lost collection.
- Place it on the selected valid spawn square.


## 12. SKIP CARD

When Skip is drawn:

- The player makes 0 Chess moves.
- The player's turn immediately ends.
- Control passes to the other player.


## 13. REVERSE CARD

Reverse performs:

1. Swap the colors controlled by the two players.
2. Flip the Chessboard orientation.
3. Keep the player who drew Reverse as the next active player.

Initial:

Player 1 → White
Player 2 → Black

After Reverse:

Player 1 → Black
Player 2 → White


## 14. RAINBOW CARD

Rainbow is the Magical Card.

Probability:

10%

Rainbow is flexible.

When drawn, the player can convert it into an available
card/effect.

Possible conversions:

- Number 1
- Number 2
- Number 3
- Number 4
- +2
- +4
- Skip
- Reverse

Rainbow provides player choice instead of a predetermined effect.


## 15. COMPLETE CARD PROBABILITY

Final distribution:

Number 1 → 20.25%
Number 2 → 13.50%
Number 3 → 6.75%
Number 4 → 4.50%

+2 → 11.25%
+4 → 6.75%
Skip → 13.50%
Reverse → 13.50%

Rainbow → 10.00%

Total → 100.00%


## 16. TURN SYSTEM

Normal turn:

START TURN
↓
Draw UNO Card
↓
Identify Card Type
↓
Apply Card Effect / Determine Moves
↓
Perform Legal Chess Actions
↓
Turn Ends
↓
Next Player

For Number Cards:

N = 1, 2, 3, or 4

The player receives N consecutive legal Chess moves.

An illegal Chess move:

- Does NOT count as a move.
- Must not alter the board.
- The player must make a legal move.


## 17. CAPTURE TRACKING

The game must maintain captured/lost pieces separately
for each player.

Example:

White lost:
- Pawn
- Pawn
- Knight
- Rook

These pieces become eligible for revival according to RP
and spawn-position rules.

After successful revival, the piece is removed from the
captured-piece collection.


## 18. REQUIRED GAME STATE

The game state must maintain at least:

- Current Player
- Player 1 Color
- Player 2 Color
- Board State
- Captured Pieces — Player 1
- Captured Pieces — Player 2
- Revival Points — Player 1
- Revival Points — Player 2
- Current UNO Card
- Current Card Color
- Number of Moves Allowed
- Number of Moves Completed
- Game Status
- Board Orientation


# 19. IMPLEMENTATION ARCHITECTURE

The project must use a separated game core.

Flutter UI must NOT contain the main game rules.

Architecture:

UNO CHESS
│
├── GAME CORE
│   ├── Chess Engine
│   ├── UNO Engine
│   ├── Revival System
│   ├── Turn System
│   ├── Player State
│   └── Game State
│
└── FLUTTER UI
    ├── Chessboard
    ├── Chess Pieces
    ├── UNO Cards
    ├── HUD
    ├── Menus
    ├── Dialogs
    ├── Animations
    └── Effects


# 20. TECHNOLOGY STACK

Programming Language:
Dart

Framework:
Flutter

Platforms:
- Android
- iOS
- Windows

Game Core:
Pure Dart

UI:
Flutter

Rendering:
Flutter Widgets / CustomPaint where required

Animation:
Flutter Animation Framework

Audio:
Flutter-compatible audio solution

Persistence:
Flutter-compatible local storage solution

Important:
The game logic must remain independent from Flutter UI
where practical.


# 21. PROJECT STRUCTURE

Recommended structure:

lib/
│
├── core/
│   ├── chess/
│   ├── uno/
│   ├── revival/
│   └── game/
│
├── ui/
│   ├── board/
│   ├── cards/
│   ├── hud/
│   ├── dialogs/
│   └── menus/
│
├── screens/
│   ├── home/
│   ├── game/
│   ├── result/
│   └── settings/
│
├── assets/
│   ├── images/
│   ├── cards/
│   ├── pieces/
│   ├── sounds/
│   └── fonts/
│
└── main.dart


# 22. DEVELOPMENT PHASES

The project must be developed in four major phases.


## PHASE 1 — GAME CORE

Focus only on functionality and rules.

Implement:

- Chess board
- Chess pieces
- Legal Chess moves
- Captures
- Check
- Checkmate
- Stalemate
- Castling
- En passant
- Promotion
- UNO card generation
- Card probability system
- Number cards
- +2
- +4
- Skip
- Reverse
- Rainbow
- Revival Points
- Revival costs
- Captured-piece tracking
- Revival spawn validation
- Turn management
- Player state
- Complete game state

Phase 1 must be testable without depending heavily on
visual presentation.


## PHASE 2 — FLUTTER CHESS UI

Build the actual game interface.

Implement:

- Responsive Chessboard
- Chess piece rendering
- Touch-based piece movement
- Legal move highlighting
- Capture feedback
- UNO card display
- Card drawing interface
- Move counter
- Revival Point display
- Captured piece display
- Player information
- Turn indicator
- Game status
- Menus
- Dialogs
- Mobile-first layouts

The UI must work across:

- Android
- iOS
- Windows


## PHASE 3 — GAME FEEL

Improve the game experience.

Implement:

- Piece movement animations
- Capture animations
- Card draw animations
- Card flip animations
- UNO card effects
- Revival animations
- Reverse animation
- Board rotation
- Check indication
- Checkmate indication
- Turn transitions
- Sound effects
- Background music where appropriate
- Haptic feedback on supported mobile devices
- Screen transitions
- Visual effects


## PHASE 4 — MOBILE-FIRST OPTIMIZATION

Prepare the game for real users.

Focus on:

- Android optimization
- iOS optimization
- Windows compatibility
- Responsive layouts
- Touch controls
- Performance
- Memory usage
- Animation performance
- Asset optimization
- Loading times
- Error handling
- Save/state handling
- Device compatibility
- Build configuration
- Release builds
- Store-readiness

The primary design priority is mobile.


# 23. DESIGN PHILOSOPHY

Chess provides:

- Positioning
- Calculation
- Tactics
- Checkmate
- Piece value
- Board control

UNO provides:

- Random events
- Variable turn length
- Revival mechanics
- Player choices
- Board reversal
- Unexpected situations

The game should preserve the strategic foundation of Chess
while introducing controlled randomness and player decisions.


# 24. IMPORTANT DEVELOPMENT RULES

1. Do not silently change established game rules.

2. Do not implement illegal Chess moves.

3. Do not allow revival of pieces that were never lost.

4. Do not allow revival of the King.

5. Do not place revived pieces on invalid spawn squares.

6. Do not allow a revival if the required spawn positions
   are occupied.

7. Illegal Chess moves must not consume a move.

8. Reverse must swap player-controlled colors and flip
   board orientation.

9. The player drawing Reverse remains the active player.

10. Card probabilities must total exactly 100%.

11. Game logic must remain separated from UI logic.

12. Mobile is the primary target.

13. Android, iOS, and Windows should share the same core
    game logic.

14. New features must not break existing game rules.

15. Any rule ambiguity or conflict must be identified before
    implementation rather than guessed.


# 25. SUCCESS CRITERIA

The project is considered functionally complete when:

- A complete Chess game can be played.
- UNO cards correctly modify gameplay.
- Card probabilities work correctly.
- Revival works according to RP and spawn rules.
- Reverse works correctly.
- Rainbow works correctly.
- Turns work correctly.
- Check/checkmate work correctly.
- Game state remains consistent.
- The UI provides a complete playable experience.
- Android build works.
- iOS build works.
- Windows build works.
- The game is responsive and usable on mobile devices.

Final objective:

Create a polished, mobile-first hybrid Chess + UNO strategy
game that is technically reliable, visually engaging, and
ready for future expansion.