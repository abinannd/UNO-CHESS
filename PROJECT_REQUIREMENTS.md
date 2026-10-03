# UNO Chess

A two-player hybrid strategy game that combines standard Chess with UNO-style cards. Cards control how many moves a player gets, grant revival points for captured pieces, skip turns, or swap sides, while the goal stays the same: **checkmate the opponent's King**. Built with Flutter and Dart for Android, iOS, and Windows, using a pure-Dart game core separated from the UI.

---

## Index

| # | Section | Description |
|---|---------|-------------|
| 1 | [Project Identity](#1-project-identity) | Name, type, platforms, and tech |
| 2 | [Core Game Concept](#2-core-game-concept) | Chess foundation and UNO modifiers |
| 3 | [Players](#3-players) | Player count and color assignment |
| 4 | [UNO Card System](#4-uno-card-system) | Card categories and overall odds |
| 5 | [Number Cards](#5-number-cards) | Consecutive move cards (1-4) |
| 6 | [Special Cards](#6-special-cards) | +2, +4, Skip, Reverse |
| 7 | [+2 Card](#7-2-card) | Grants 2 Revival Points |
| 8 | [+4 Card](#8-4-card) | Grants 4 Revival Points |
| 9 | [Revival Costs](#9-revival-costs) | RP cost per piece type |
| 10 | [Revival Spawn System](#10-revival-spawn-system) | Valid spawn squares |
| 11 | [Revival Point Management](#11-revival-point-management) | RP ownership and spending |
| 12 | [Skip Card](#12-skip-card) | Ends turn with zero moves |
| 13 | [Reverse Card](#13-reverse-card) | Color swap and board flip |
| 14 | [Rainbow Card](#14-rainbow-card) | Magical wildcard |
| 15 | [Complete Card Probability](#15-complete-card-probability) | Final distribution table |
| 16 | [Turn System](#16-turn-system) | Turn flow and move rules |
| 17 | [Capture Tracking](#17-capture-tracking) | Lost-piece collections |
| 18 | [Required Game State](#18-required-game-state) | Mandatory state fields |
| 19 | [Implementation Architecture](#19-implementation-architecture) | Game core vs. Flutter UI |
| 20 | [Technology Stack](#20-technology-stack) | Language, framework, tooling |
| 21 | [Project Structure](#21-project-structure) | Recommended folder layout |
| 22 | [Development Phases](#22-development-phases) | Four-phase roadmap |
| 23 | [Design Philosophy](#23-design-philosophy) | Chess and UNO roles |
| 24 | [Important Development Rules](#24-important-development-rules) | Mandatory rules for contributors |
| 25 | [Success Criteria](#25-success-criteria) | Definition of done |

---

## 1. Project Identity

| Field | Value |
|-------|-------|
| **Project Name** | UNO Chess |
| **Project Type** | Two-player hybrid strategy game |
| **Core Concept** | Standard Chess rules combined with UNO-style cards |
| **Primary Objective** | Checkmate the opponent's King |
| **Target Platforms** | Android, iOS, Windows |
| **Technology** | Flutter, Dart |
| **Approach** | Mobile-first, cross-platform, modular, and testable |

---

## 2. Core Game Concept

The Chess system is the foundation of the game. All standard Chess mechanics must remain valid:

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

UNO mechanics modify the **flow** of the game but must **never** allow an illegal Chess move. The ultimate objective remains checkmate.

---

## 3. Players

The game supports exactly two players.

| Player | Initial Color |
|--------|---------------|
| Player 1 | White |
| Player 2 | Black |

The **Reverse** card can change which player controls White and Black.

---

## 4. UNO Card System

There are three card categories:

| Category | Probability |
|----------|-------------|
| Number Cards | 45% |
| Special Cards | 45% |
| Magical Card | 10% |

- **Normal card colors:** Red, Yellow, Green, Blue
- **Magical Card:** Rainbow

---

## 5. Number Cards

Available: `1`, `2`, `3`, `4`

A number card determines how many **consecutive legal Chess moves** the player can make during that turn.

| Number | Within Number Cards | Overall Probability |
|--------|--------------------:|--------------------:|
| 1 | 45% | 20.25% |
| 2 | 30% | 13.50% |
| 3 | 15% | 6.75% |
| 4 | 10% | 4.50% |

---

## 6. Special Cards

Available: `+2`, `+4`, `Skip`, `Reverse`

| Card | Within Special Cards | Overall Probability |
|------|---------------------:|--------------------:|
| +2 | 25% | 11.25% |
| +4 | 15% | 6.75% |
| Skip | 30% | 13.50% |
| Reverse | 30% | 13.50% |

---

## 7. +2 Card

Gives the current player **2 Revival Points (RP)**.

- RP can be used to revive eligible captured pieces.
- The player may select any eligible lost piece.
- There is no FIFO restriction.

---

## 8. +4 Card

Gives the current player **4 Revival Points (RP)**.

- RP can be spent to revive eligible captured pieces.
- The player chooses which eligible lost piece to revive.

---

## 9. Revival Costs

| Piece | Cost |
|-------|-----:|
| Pawn | 1 RP |
| Knight | 3 RP |
| Bishop | 3 RP |
| Rook | 5 RP |
| Queen | 10 RP |
| King | Cannot be revived |

- A player can only revive pieces that were actually lost.
- A player cannot create a new piece through revival.

---

## 10. Revival Spawn System

A revived piece must be placed on a valid original starting square for that piece. The selected square must:

1. Be a valid starting square for that piece.
2. Currently be unoccupied.

### White Starting Positions

| Piece | Squares |
|-------|---------|
| Rooks | a1, h1 |
| Knights | b1, g1 |
| Bishops | c1, f1 |
| Queen | d1 |
| Pawns | a2, b2, c2, d2, e2, f2, g2, h2 |
| King | Cannot be revived |

### Black Starting Positions

| Piece | Squares |
|-------|---------|
| Rooks | a8, h8 |
| Knights | b8, g8 |
| Bishops | c8, f8 |
| Queen | d8 |
| Pawns | a7, b7, c7, d7, e7, f7, g7, h7 |
| King | Cannot be revived |

If all valid spawn positions for a piece are occupied, that piece cannot currently be revived.

---

## 11. Revival Point Management

Revival Points belong to the player. Unused RP may remain available according to the game rules.

When a piece is successfully revived:

1. Deduct its RP cost.
2. Remove that piece from the captured/lost collection.
3. Place it on the selected valid spawn square.

---

## 12. Skip Card

When Skip is drawn:

- The player makes **0** Chess moves.
- The player's turn immediately ends.
- Control passes to the other player.

---

## 13. Reverse Card

Reverse performs:

1. Swap the colors controlled by the two players.
2. Flip the Chessboard orientation.
3. Keep the player who drew Reverse as the next active player.

| State | Player 1 | Player 2 |
|-------|----------|----------|
| Initial | White | Black |
| After Reverse | Black | White |

---

## 14. Rainbow Card

Rainbow is the Magical Card, with a **10%** draw probability.

When drawn, the player can convert it into any available card/effect:

- Number 1
- Number 2
- Number 3
- Number 4
- +2
- +4
- Skip
- Reverse

Rainbow provides player choice instead of a predetermined effect.

---

## 15. Complete Card Probability

| Card | Probability |
|------|------------:|
| Number 1 | 20.25% |
| Number 2 | 13.50% |
| Number 3 | 6.75% |
| Number 4 | 4.50% |
| +2 | 11.25% |
| +4 | 6.75% |
| Skip | 13.50% |
| Reverse | 13.50% |
| Rainbow | 10.00% |
| **Total** | **100.00%** |

---

## 16. Turn System

```text
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
```

For Number Cards (N = 1, 2, 3, or 4), the player receives N consecutive legal Chess moves.

An illegal Chess move:

- Does **not** count as a move.
- Must not alter the board.
- Requires the player to make a legal move.

---

## 17. Capture Tracking

The game must maintain captured/lost pieces **separately for each player**.

Example, White lost:

- Pawn
- Pawn
- Knight
- Rook

These pieces become eligible for revival according to RP and spawn-position rules. After a successful revival, the piece is removed from the captured-piece collection.

---

## 18. Required Game State

The game state must maintain at least:

- Current Player
- Player 1 Color
- Player 2 Color
- Board State
- Captured Pieces (Player 1)
- Captured Pieces (Player 2)
- Revival Points (Player 1)
- Revival Points (Player 2)
- Current UNO Card
- Current Card Color
- Number of Moves Allowed
- Number of Moves Completed
- Game Status
- Board Orientation

---

## 19. Implementation Architecture

The project uses a separated game core. The Flutter UI must **not** contain the main game rules.

```text
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
```

---

## 20. Technology Stack

| Area | Choice |
|------|--------|
| Language | Dart |
| Framework | Flutter |
| Platforms | Android, iOS, Windows |
| Game Core | Pure Dart |
| UI | Flutter |
| Rendering | Flutter Widgets / `CustomPaint` where required |
| Animation | Flutter Animation Framework |
| Audio | Flutter-compatible audio solution |
| Persistence | Flutter-compatible local storage solution |

> **Important:** Game logic must remain independent from Flutter UI where practical.

---

## 21. Project Structure

```text
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
```

---

## 22. Development Phases

The project is developed in four major phases.

| Phase | Name | Focus |
|-------|------|-------|
| 1 | Game Core | Functionality and rules |
| 2 | Flutter Chess UI | Playable interface |
| 3 | Game Feel | Animation, audio, effects |
| 4 | Mobile-First Optimization | Release readiness |

### Phase 1: Game Core

Focus only on functionality and rules. Phase 1 must be testable without depending heavily on visual presentation.

- [ ] Chess board
- [ ] Chess pieces
- [ ] Legal Chess moves
- [ ] Captures
- [ ] Check
- [ ] Checkmate
- [ ] Stalemate
- [ ] Castling
- [ ] En passant
- [ ] Promotion
- [ ] UNO card generation
- [ ] Card probability system
- [ ] Number cards
- [ ] +2
- [ ] +4
- [ ] Skip
- [ ] Reverse
- [ ] Rainbow
- [ ] Revival Points
- [ ] Revival costs
- [ ] Captured-piece tracking
- [ ] Revival spawn validation
- [ ] Turn management
- [ ] Player state
- [ ] Complete game state

### Phase 2: Flutter Chess UI

The UI must work across Android, iOS, and Windows.

- [ ] Responsive Chessboard
- [ ] Chess piece rendering
- [ ] Touch-based piece movement
- [ ] Legal move highlighting
- [ ] Capture feedback
- [ ] UNO card display
- [ ] Card drawing interface
- [ ] Move counter
- [ ] Revival Point display
- [ ] Captured piece display
- [ ] Player information
- [ ] Turn indicator
- [ ] Game status
- [ ] Menus
- [ ] Dialogs
- [ ] Mobile-first layouts

### Phase 3: Game Feel

- [ ] Piece movement animations
- [ ] Capture animations
- [ ] Card draw animations
- [ ] Card flip animations
- [ ] UNO card effects
- [ ] Revival animations
- [ ] Reverse animation
- [ ] Board rotation
- [ ] Check indication
- [ ] Checkmate indication
- [ ] Turn transitions
- [ ] Sound effects
- [ ] Background music where appropriate
- [ ] Haptic feedback on supported mobile devices
- [ ] Screen transitions
- [ ] Visual effects

### Phase 4: Mobile-First Optimization

The primary design priority is mobile.

- [ ] Android optimization
- [ ] iOS optimization
- [ ] Windows compatibility
- [ ] Responsive layouts
- [ ] Touch controls
- [ ] Performance
- [ ] Memory usage
- [ ] Animation performance
- [ ] Asset optimization
- [ ] Loading times
- [ ] Error handling
- [ ] Save/state handling
- [ ] Device compatibility
- [ ] Build configuration
- [ ] Release builds
- [ ] Store-readiness

---

## 23. Design Philosophy

| Chess provides | UNO provides |
|----------------|--------------|
| Positioning | Random events |
| Calculation | Variable turn length |
| Tactics | Revival mechanics |
| Checkmate | Player choices |
| Piece value | Board reversal |
| Board control | Unexpected situations |

The game preserves the strategic foundation of Chess while introducing controlled randomness and player decisions.

---

## 24. Important Development Rules

1. Do not silently change established game rules.
2. Do not implement illegal Chess moves.
3. Do not allow revival of pieces that were never lost.
4. Do not allow revival of the King.
5. Do not place revived pieces on invalid spawn squares.
6. Do not allow a revival if the required spawn positions are occupied.
7. Illegal Chess moves must not consume a move.
8. Reverse must swap player-controlled colors and flip board orientation.
9. The player drawing Reverse remains the active player.
10. Card probabilities must total exactly 100%.
11. Game logic must remain separated from UI logic.
12. Mobile is the primary target.
13. Android, iOS, and Windows should share the same core game logic.
14. New features must not break existing game rules.
15. Any rule ambiguity or conflict must be identified before implementation rather than guessed.

---

## 25. Success Criteria

The project is considered functionally complete when:

- [ ] A complete Chess game can be played.
- [ ] UNO cards correctly modify gameplay.
- [ ] Card probabilities work correctly.
- [ ] Revival works according to RP and spawn rules.
- [ ] Reverse works correctly.
- [ ] Rainbow works correctly.
- [ ] Turns work correctly.
- [ ] Check/checkmate work correctly.
- [ ] Game state remains consistent.
- [ ] The UI provides a complete playable experience.
- [ ] Android build works.
- [ ] iOS build works.
- [ ] Windows build works.
- [ ] The game is responsive and usable on mobile devices.

**Final objective:** Create a polished, mobile-first hybrid Chess + UNO strategy game that is technically reliable, visually engaging, and ready for future expansion.
