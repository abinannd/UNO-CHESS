import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/board.dart';
import 'package:uno_chess/core/chess/position.dart';
import 'package:uno_chess/ui/board/chess_board_widget.dart';
import 'package:uno_chess/ui/board/chess_piece_widget.dart';
import 'package:uno_chess/ui/board/chess_square_widget.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 800,
            child: child,
          ),
        ),
      ),
    );
  }

  group('ChessBoardWidget UI Tests', () {
    testWidgets('Renders 64 squares', (WidgetTester tester) async {
      final board = ChessBoard.empty();
      
      await tester.pumpWidget(buildTestApp(ChessBoardWidget(board: board)));
      
      expect(find.byType(ChessSquareWidget), findsNWidgets(64));
    });

    testWidgets('Renders initial pieces accurately (32 total pieces)', (WidgetTester tester) async {
      final board = ChessBoard.initial();
      
      await tester.pumpWidget(buildTestApp(ChessBoardWidget(board: board)));
      
      expect(find.byType(ChessPieceWidget), findsNWidgets(32));
    });

    testWidgets('Tapping a square triggers callback with correct position', (WidgetTester tester) async {
      final board = ChessBoard.empty();
      Position? tappedPosition;
      
      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(
          board: board,
          onSquareTapped: (pos) => tappedPosition = pos,
        ),
      ));
      
      // The bottom-left square in normal orientation is a1 (file 0, rank 0).
      // Find the first square in the widget tree (top-left visual is a8 normally, but let's just tap one)
      // Rank 8 (top) row comes first in _buildRanks, File 0 (left) comes first in _buildFiles.
      // So the very first widget is a8 (file 0, rank 7).
      
      final firstSquare = find.byType(ChessSquareWidget).first;
      await tester.tap(firstSquare);
      
      expect(tappedPosition, equals(Position.fromAlgebraic('a8')));
    });

    testWidgets('Reversed orientation renders correctly', (WidgetTester tester) async {
      final board = ChessBoard.empty();
      Position? tappedPosition;
      
      await tester.pumpWidget(buildTestApp(
        ChessBoardWidget(
          board: board,
          isReversed: true,
          onSquareTapped: (pos) => tappedPosition = pos,
        ),
      ));
      
      // In reversed orientation, Rank 1 (index 0) is at the top, File 8 (index 7) is on the left.
      // So the top-left square is h1 (file 7, rank 0).
      
      final firstSquare = find.byType(ChessSquareWidget).first;
      await tester.tap(firstSquare);
      
      expect(tappedPosition, equals(Position.fromAlgebraic('h1')));
    });
  });
}
