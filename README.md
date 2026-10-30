# UNO Chess

A two-player, local multiplayer strategy game that combines classic chess with UNO-inspired turn modifiers and a revival-point economy. Built with Flutter and a custom, pure-Dart game core.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Windows-blue)
![Status](https://img.shields.io/badge/status-playable%20prototype-orange)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Game Rules Summary](#game-rules-summary)
- [Supported Platforms](#supported-platforms)
- [Getting Started](#getting-started)
- [Testing and Quality](#testing-and-quality)
- [Building](#building)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Project Status and Roadmap](#project-status-and-roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

UNO Chess keeps the full rules of chess and adds a card-drawing layer on top. Each turn, a player draws a card whose effect changes how many chess moves they get, who moves next, or how the turn resolves. Captured pieces earn Revival Points (RP), which can be spent to bring pieces back onto the board.

The game logic is implemented as a standalone Dart core, separate from the Flutter UI, so the rules stay testable and independent of widgets.

For the complete rule specification, see [`PROJECT_REQUIREMENTS.md`](PROJECT_REQUIREMENTS.md).

## Features

**Chess engine (custom)**
- Full piece movement with sliding-piece obstruction
- Attack detection and legal-move filtering (a move may not leave your own king in check)
- Castling, en passant, and pawn promotion (queen, rook, bishop, knight)
- Check, checkmate, and stalemate detection

**UNO card system**
- Weighted random card generation with an injectable `Random` for deterministic testing
- Number cards, +2, +4, Skip, Reverse, and Rainbow effects
- Turn phases and move counting handled by a dedicated turn system

**Revival system**
- Captured-piece tracking per player
- Revival Points economy
- Fixed spawn squares, empty-square validation, and a rule that kings cannot be revived

**Game UI**
- Playable game screen with board, card, HUD, and revival components
- Custom piece, card, and UI assets

### Card Probabilities

| Card category | Probability |
|---------------|-------------|
| Number cards  | 45%         |
| Special cards | 45%         |
| Rainbow       | 10%         |

| Card effect | Overall probability |
|-------------|---------------------|
| Number 1    | 20.25%              |
| Number 2    | 13.50%              |
| Number 3    | 6.75%               |
| Number 4    | 4.50%               |
| +2          | 11.25%              |
| +4          | 6.75%               |
| Skip        | 13.50%              |
| Reverse     | 13.50%              |
| Rainbow     | 10.00%              |

## Game Rules Summary

1. Two players share one device and play on a standard 8×8 chessboard.
2. On their turn, a player draws a UNO card instead of simply moving.
3. The card determines the turn: number cards grant that many consecutive chess moves, while Skip, Reverse, +2, +4, and Rainbow alter the turn flow or resources.
4. Capturing pieces earns Revival Points, which can be spent to revive a captured piece (never a king) on its original, empty spawn square.
5. The game ends by checkmate or stalemate.

> This is a summary only. [`PROJECT_REQUIREMENTS.md`](PROJECT_REQUIREMENTS.md) is the authoritative source for rules.

## Supported Platforms

The project requirements target:

- Android
- iOS
- Windows

Flutter scaffolding for Linux, macOS, and web is also present in the repository.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A configured device, emulator, or desktop target

### Installation

```bash
git clone https://github.com/abinannd/UNO-CHESS.git
cd UNO-CHESS
flutter pub get
```

### Run

```bash
flutter run
```

To pick a specific target:

```bash
flutter devices
flutter run -d <device-id>
```

## Testing and Quality

```bash
flutter analyze
flutter test
```

The test suite covers the chess engine (castling, en passant, promotion, checkmate and stalemate, integration scenarios), UNO card generation, turn management, revival, board interaction, and a widget smoke test.

## Building

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release
```

A GitHub Actions workflow (`.github/workflows/build-android-apk.yml`) builds an Android release APK.

## Architecture

The game core is plain Dart with no Flutter dependency; the UI observes it and never owns the rules.

```
        Flutter UI
            │
        GameScreen
            │
        GameState
   ┌────────┼─────────┐
TurnSystem  ChessBoard  PlayerState
   │          │            │
UnoEffect  ChessEngine  RevivalSystem
   │          │            │
UnoCard-   MoveGenerator  Captured
Generator                  pieces
```

| Module | Responsibility |
|--------|----------------|
| `ChessBoard` | Board representation and mutation |
| `MoveGenerator` | Pseudo-legal moves and attack detection |
| `ChessEngine` | Legal-move filtering, check, checkmate, stalemate |
| `UnoCardGenerator` | Weighted card generation |
| `UnoEffect` | Translates cards into game effects |
| `TurnSystem` | Turn phases, player identity, move counts |
| `RevivalSystem` | Captured pieces, RP, spawn validation |
| `GameState` | Coordinates all systems behind one API |

## Project Structure

```
lib/
├── core/
│   ├── chess/      # board, pieces, move generation, engine
│   ├── game/       # game state, status, turn system, players
│   ├── revival/    # captured pieces, costs, revival system
│   └── uno/        # cards, generator, effects
├── screens/
│   └── game/       # game screen
├── ui/
│   ├── board/
│   ├── cards/
│   ├── hud/
│   └── revival/
└── main.dart

test/               # unit and widget tests mirroring lib/
assets/             # cards, pieces, UI images
archives/           # phase and implementation audit reports
```

## Project Status and Roadmap

UNO Chess is a **playable prototype** with a substantial, tested core. Planned work:

- [ ] Finalize and document stalemate evaluation under multi-move turns
- [ ] Define and enforce the turn phase in which revival is allowed
- [ ] Confirm and document the opening number-card rule
- [ ] Run `flutter analyze` and `flutter test` in CI before building
- [ ] Introduce a game controller layer with explicit, validated state transitions
- [ ] Decide between infinite probability draws and a managed deck
- [ ] Permanent application ID and release signing configuration
- [ ] Expanded README screenshots and web metadata

## Contributing

Issues and pull requests are welcome.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Keep game rules in `lib/core/`, not in widgets
4. Run `flutter analyze` and `flutter test` before committing
5. Open a pull request describing the change

## License

No license has been specified yet. Add a `LICENSE` file to define usage terms.

---

Made by [abinannd](https://github.com/abinannd)
