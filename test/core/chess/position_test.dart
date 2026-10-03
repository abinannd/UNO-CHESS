import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/chess/position.dart';

void main() {
  group('Position', () {
    test('valid positions are created successfully', () {
      const pos = Position(0, 0); // a1
      expect(pos.file, equals(0));
      expect(pos.rank, equals(0));
    });

    test('fromAlgebraic creates correct position', () {
      final a1 = Position.fromAlgebraic('a1');
      expect(a1.file, equals(0));
      expect(a1.rank, equals(0));

      final h8 = Position.fromAlgebraic('h8');
      expect(h8.file, equals(7));
      expect(h8.rank, equals(7));

      final e4 = Position.fromAlgebraic('e4');
      expect(e4.file, equals(4));
      expect(e4.rank, equals(3));
    });

    test('algebraic property returns correct string', () {
      expect(const Position(0, 0).algebraic, equals('a1'));
      expect(const Position(7, 7).algebraic, equals('h8'));
      expect(const Position(4, 3).algebraic, equals('e4'));
    });

    test('fromAlgebraic handles uppercase', () {
      final pos = Position.fromAlgebraic('E4');
      expect(pos.file, equals(4));
      expect(pos.rank, equals(3));
    });

    test('fromAlgebraic throws on invalid notation length', () {
      expect(() => Position.fromAlgebraic('a'), throwsFormatException);
      expect(() => Position.fromAlgebraic('a12'), throwsFormatException);
    });

    test('fromAlgebraic throws on out of bounds', () {
      expect(() => Position.fromAlgebraic('i1'), throwsFormatException);
      expect(() => Position.fromAlgebraic('a9'), throwsFormatException);
      expect(() => Position.fromAlgebraic('a0'), throwsFormatException);
    });

    test('equality works correctly', () {
      const p1 = Position(3, 4);
      final p2 = Position.fromAlgebraic('d5');
      const p3 = Position(3, 5);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, equals(p2.hashCode));
    });
  });
}
