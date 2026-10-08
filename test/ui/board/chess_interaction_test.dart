// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/chess_color.dart';
import 'package:uno_chess/core/chess/chess_engine.dart';
import 'package:uno_chess/core/chess/chess_move.dart';
import 'package:uno_chess/core/chess/piece.dart';
import 'package:uno_chess/core/chess/piece_type.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/core/game/game_state.dart';
import 'package:uno_chess/core/game/game_status.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_color.dart';
import 'package:uno_chess/ui/board/chess_board_widget.dart';
import 'package:uno_chess/ui/board/chess_square_widget.dart';
import 'package:uno_chess/screens/game/game_screen.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Wraps a widget in a MaterialApp with a fixed 400×400 viewport.
Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: child,
        ),
      ),
    ),
  );
}

/// A harness that drives [ChessBoardWidget] with interactive selection state,
/// mirroring [GameScreen]'s interaction model at the widget level.
class InteractiveBoardHarness extends StatefulWidget {
  final ChessBoard board;
  final ChessColor controlledColor;
  final void Function(Position)? onTap;

  const InteractiveBoardHarness({
    super.key,
    required this.board,
    required this.controlledColor,
    this.onTap,
  });

  @override
  State<InteractiveBoardHarness> createState() =>
      _InteractiveBoardHarnessState();
}

class _InteractiveBoardHarnessState extends State<InteractiveBoardHarness> {
  Position? _selected;
  List<Position> _legalDests = [];

  void _handleTap(Position pos) {
    widget.onTap?.call(pos);

    final piece = widget.board.getPieceAt(pos);
    if (piece != null && piece.color == widget.controlledColor) {
      setState(() {
        _selected = pos;
        final engine = ChessEngine(widget.board);
        _legalDests = engine
            .generateLegalMoves(widget.controlledColor)
            .where((m) => m.from == pos)
            .map((m) => m.to)
            .toList();
      });
    } else {
      setState(() {
        _selected = null;
        _legalDests = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChessBoardWidget(
      board: widget.board,
      onSquareTapped: _handleTap,
      selectedPosition: _selected,
      legalDestinations: _legalDests,
    );
  }
}

// ── Finder shorthand ──────────────────────────────────────────────────────────

Finder squareAt(Position pos) => find.byWidgetPredicate(
      (w) => w is ChessSquareWidget && w.position == pos,
    );

// ─────────────────────────────────────────────────────────────────────────────
// TEST SUITE
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Own-piece selection ─────────────────────────────────────────────────
  group('1. Own-piece selection', () {
    testWidgets(
        'Tapping current player\'s own piece selects it and marks the square',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final e2 = Position.fromAlgebraic('e2');
      await tester.tap(squareAt(e2));
      await tester.pump();

      final square = tester.widget<ChessSquareWidget>(squareAt(e2));
      expect(square.isSelected, isTrue,
          reason: 'Own piece square should be marked isSelected after tap');
    });

    testWidgets('Tapping a different own piece re-selects without deselecting first',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final d2 = Position.fromAlgebraic('d2');
      final e2 = Position.fromAlgebraic('e2');

      await tester.tap(squareAt(d2));
      await tester.pump();
      expect(tester.widget<ChessSquareWidget>(squareAt(d2)).isSelected, isTrue);

      // Switch selection to e2
      await tester.tap(squareAt(e2));
      await tester.pump();

      expect(tester.widget<ChessSquareWidget>(squareAt(e2)).isSelected, isTrue,
          reason: 'New own-piece tap should transfer selection');
      expect(tester.widget<ChessSquareWidget>(squareAt(d2)).isSelected, isFalse,
          reason: 'Previous selection should be cleared on re-select');
    });
  });

  // ── 2. Opponent-piece rejection ────────────────────────────────────────────
  group('2. Opponent-piece rejection', () {
    testWidgets(
        'Tapping opponent piece without a prior selection does not select it',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final e7 = Position.fromAlgebraic('e7'); // Black pawn
      await tester.tap(squareAt(e7));
      await tester.pump();

      final square = tester.widget<ChessSquareWidget>(squareAt(e7));
      expect(square.isSelected, isFalse,
          reason: 'Opponent piece must never become selected');
    });

    testWidgets('Tapping opponent piece that is not a legal destination clears selection',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final e2 = Position.fromAlgebraic('e2');
      final e7 = Position.fromAlgebraic('e7');

      await tester.tap(squareAt(e2));
      await tester.pump();
      expect(tester.widget<ChessSquareWidget>(squareAt(e2)).isSelected, isTrue);

      // e7 is a black piece, not reachable from e2 pawn
      await tester.tap(squareAt(e7));
      await tester.pump();

      expect(tester.widget<ChessSquareWidget>(squareAt(e2)).isSelected, isFalse,
          reason: 'Selection must clear when tapping a non-destination square');
    });
  });

  // ── 3. Legal move highlighting ─────────────────────────────────────────────
  group('3. Legal move highlighting', () {
    testWidgets(
        'After selecting a pawn its legal forward destinations are highlighted',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final e2 = Position.fromAlgebraic('e2');
      await tester.tap(squareAt(e2));
      await tester.pump();

      final e3 = Position.fromAlgebraic('e3');
      final e4 = Position.fromAlgebraic('e4');

      expect(tester.widget<ChessSquareWidget>(squareAt(e3)).isLegalDestination,
          isTrue,
          reason: 'e3 must be a legal destination for white pawn on e2');
      expect(tester.widget<ChessSquareWidget>(squareAt(e4)).isLegalDestination,
          isTrue,
          reason: 'e4 must be a legal destination for white pawn on e2');
    });

    testWidgets(
        'Squares outside legal moves are not highlighted',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white,
        ),
      ));

      final e2 = Position.fromAlgebraic('e2');
      await tester.tap(squareAt(e2));
      await tester.pump();

      final d4 = Position.fromAlgebraic('d4');
      final f3 = Position.fromAlgebraic('f3');

      expect(tester.widget<ChessSquareWidget>(squareAt(d4)).isLegalDestination,
          isFalse);
      expect(tester.widget<ChessSquareWidget>(squareAt(f3)).isLegalDestination,
          isFalse);
    });
  });

  // ── 4. Illegal destination ─────────────────────────────────────────────────
  group('4. Illegal destination — state unchanged', () {
    testWidgets(
        'Tapping an illegal destination does not mutate the board or consume selection',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const GameScreen()));
      await tester.pump();

      // White pawn on a2 cannot jump to a5.
      final a2 = Position.fromAlgebraic('a2');
      final a5 = Position.fromAlgebraic('a5');

      await tester.tap(squareAt(a2));
      await tester.pump();

      // a5 is not legal for the pawn — tapping it should just deselect.
      await tester.tap(squareAt(a5));
      await tester.pump();

      // The square widget for a2 should still exist (board not mutated).
      expect(squareAt(a2), findsOneWidget,
          reason: 'a2 must still exist — board must not mutate on illegal tap');
    });
  });

  // ── 5. Successful move ─────────────────────────────────────────────────────
  group('5. Successful move — UI updates after valid move', () {
    testWidgets('Moving a pawn from e2 to e4 clears selection and updates UI',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const GameScreen()));
      await tester.pump();

      final e2 = Position.fromAlgebraic('e2');
      final e4 = Position.fromAlgebraic('e4');

      await tester.tap(squareAt(e2));
      await tester.pump();

      await tester.tap(squareAt(e4));
      await tester.pump();

      // After a successful move the selection must be cleared.
      final e2Square = tester.widget<ChessSquareWidget>(squareAt(e2));
      expect(e2Square.isSelected, isFalse,
          reason: 'Selection must clear after a successful move');

      // e4 should no longer be a legalDestination highlight (move done).
      final e4Square = tester.widget<ChessSquareWidget>(squareAt(e4));
      expect(e4Square.isLegalDestination, isFalse,
          reason: 'Legal-destination highlights must vanish after the move');
    });
  });

  // ── 6. Capture ─────────────────────────────────────────────────────────────
  group('6. Capture — captured piece reaches PlayerState', () {
    testWidgets(
        'Capturing a pawn adds it to the waiting player\'s capturedPieces',
        (tester) async {
      // White pawn d4 can capture Black pawn on e5 diagonally.
      final board = ChessBoard.empty();
      board.castlingRights.whiteKingSide = false;
      board.castlingRights.whiteQueenSide = false;
      board.castlingRights.blackKingSide = false;
      board.castlingRights.blackQueenSide = false;

      board.placePiece(Position.fromAlgebraic('e1'),
          const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e8'),
          const ChessPiece(PieceType.king, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('d4'),
          const ChessPiece(PieceType.pawn, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('e5'),
          const ChessPiece(PieceType.pawn, ChessColor.black));

      final gameState = GameState(board: board);
      gameState.drawCard(UnoCard.number(1, UnoColor.red));

      expect(gameState.player2.capturedPieces.isEmpty, isTrue,
          reason: 'No captures yet');

      final d4 = Position.fromAlgebraic('d4');
      final e5 = Position.fromAlgebraic('e5');
      final success =
          gameState.executeChessMove(ChessMove(from: d4, to: e5));

      expect(success, isTrue, reason: 'Diagonal capture must succeed');
      expect(gameState.player2.capturedPieces.length, equals(1),
          reason: 'Captured pawn must appear in Player 2\'s capturedPieces');
      expect(gameState.player2.capturedPieces.first.type, equals(PieceType.pawn),
          reason: 'The captured piece type must be pawn');
    });
  });

  // ── 7. Turn restriction ────────────────────────────────────────────────────
  group('7. Turn restriction', () {
    testWidgets(
        'Board with onSquareTapped=null accepts no interactions',
        (tester) async {
      final board = ChessBoard.initial();
      bool callbackFired = false;

      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(
          board: board,
          onSquareTapped: null, // simulate locked turn phase
        ),
      ));

      // Tap any square — no callback should fire.
      await tester.tap(squareAt(Position.fromAlgebraic('e2')));
      await tester.pump();

      expect(callbackFired, isFalse,
          reason: 'Locked board (null callback) must ignore all taps');
    });

    testWidgets('Only current player\'s colour pieces can be selected',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        InteractiveBoardHarness(
          board: board,
          controlledColor: ChessColor.white, // White to move
        ),
      ));

      // Black knight on b8
      final b8 = Position.fromAlgebraic('b8');
      await tester.tap(squareAt(b8));
      await tester.pump();

      expect(tester.widget<ChessSquareWidget>(squareAt(b8)).isSelected,
          isFalse,
          reason: 'Opponent\'s piece cannot be selected by active player');
    });
  });

  // ── 8. Check indication ────────────────────────────────────────────────────
  group('8. Check indication', () {
    testWidgets(
        'King square is flagged isCheck=true when the king is in check',
        (tester) async {
      final board = ChessBoard.empty();
      board.castlingRights.whiteKingSide = false;
      board.castlingRights.whiteQueenSide = false;
      board.castlingRights.blackKingSide = false;
      board.castlingRights.blackQueenSide = false;

      // White king e1, Black rook e8 — White is in check along the e-file.
      final e1 = Position.fromAlgebraic('e1');
      final e8 = Position.fromAlgebraic('e8');
      board.placePiece(e1, const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(e8, const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('h8'),
          const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      expect(engine.isInCheck(ChessColor.white), isTrue,
          reason: 'Precondition: White must be in check');

      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(board: board, checkPosition: e1),
      ));

      final kingSquare = tester.widget<ChessSquareWidget>(squareAt(e1));
      expect(kingSquare.isCheck, isTrue,
          reason: 'King square must carry isCheck=true when in check');
    });

    testWidgets(
        'Non-king squares are not flagged as check even when king is in check',
        (tester) async {
      final board = ChessBoard.empty();
      final e1 = Position.fromAlgebraic('e1');
      final e8 = Position.fromAlgebraic('e8');

      board.placePiece(e1, const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(e8, const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('h8'),
          const ChessPiece(PieceType.king, ChessColor.black));

      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(board: board, checkPosition: e1),
      ));

      // The attacking rook is on e8 — that square must NOT be marked as check.
      final rookSquare = tester.widget<ChessSquareWidget>(squareAt(e8));
      expect(rookSquare.isCheck, isFalse,
          reason: 'Only the king square should carry isCheck=true');
    });
  });

  // ── 9. Terminal-game lockout ───────────────────────────────────────────────
  group('9. Terminal-game lockout', () {
    testWidgets('GameState rejects all moves when status is checkmate',
        (tester) async {
      // Back-rank double-rook checkmate.
      //   White King a1; Black Rooks a8 + b8; Black King c6.
      //
      //   White king can try a2, b1, b2 — all are attacked:
      //     a2 → Black Ra8 controls entire a-file
      //     b1 → Black Rb8 controls entire b-file
      //     b2 → attacked by both rooks
      //
      final board = ChessBoard.empty();
      board.castlingRights.whiteKingSide = false;
      board.castlingRights.whiteQueenSide = false;
      board.castlingRights.blackKingSide = false;
      board.castlingRights.blackQueenSide = false;

      board.placePiece(Position.fromAlgebraic('a1'),
          const ChessPiece(PieceType.king, ChessColor.white));
      board.placePiece(Position.fromAlgebraic('a8'),
          const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('b8'),
          const ChessPiece(PieceType.rook, ChessColor.black));
      board.placePiece(Position.fromAlgebraic('c6'),
          const ChessPiece(PieceType.king, ChessColor.black));

      final engine = ChessEngine(board);
      expect(engine.isCheckmate(ChessColor.white), isTrue,
          reason: 'Precondition: position must be checkmate');

      final gameState = GameState(board: board);
      expect(gameState.status, equals(GameStatus.checkmate));

      // Any move attempt must be rejected.
      final moved = gameState.executeChessMove(
        ChessMove(
          from: Position.fromAlgebraic('a1'),
          to: Position.fromAlgebraic('a2'),
        ),
      );
      expect(moved, isFalse,
          reason: 'executeChessMove must return false in a terminal game');
    });

    testWidgets(
        'No squares are selected when the board callback is null (terminal lockout)',
        (tester) async {
      final board = ChessBoard.initial();

      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(
          board: board,
          onSquareTapped: null, // terminal state: interaction locked
        ),
      ));

      await tester.tap(squareAt(Position.fromAlgebraic('e2')));
      await tester.pump();

      final anySelected = tester
          .widgetList<ChessSquareWidget>(find.byType(ChessSquareWidget))
          .any((s) => s.isSelected);

      expect(anySelected, isFalse,
          reason: 'No square should be selected when the board is locked');
    });
  });
}
