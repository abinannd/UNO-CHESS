import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/chess_color.dart';

void main() {
  group('ChessColor', () {
    test('opponent of white is black', () {
      expect(ChessColor.white.opponent, equals(ChessColor.black));
    });

    test('opponent of black is white', () {
      expect(ChessColor.black.opponent, equals(ChessColor.white));
    });
  });
}
