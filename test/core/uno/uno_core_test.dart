import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/core/uno/special_effect.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_card_generator.dart';
import 'package:uno_chess/core/uno/uno_card_type.dart';
import 'package:uno_chess/core/uno/uno_color.dart';
import 'package:uno_chess/core/uno/uno_effect.dart';

// ── Deterministic Random stub ─────────────────────────────────────────────────
// Returns a fixed sequence of values, cycling through them.
class _FixedRandom implements Random {
  final List<double> _doubles;
  final List<int>    _ints;
  int _di = 0;
  int _ii = 0;

  _FixedRandom({List<double> doubles = const [], List<int> ints = const []})
      : _doubles = doubles,
        _ints    = ints;

  @override double nextDouble() => _doubles[_di++ % _doubles.length];
  @override int    nextInt(int max) => _ints[_ii++ % _ints.length];
  @override bool   nextBool() => nextDouble() >= 0.5;
}

void main() {

  // ────────────────────────────────────────────────────────────────────────────
  group('UnoCard model', () {

    test('Number card stores value and color correctly', () {
      final card = UnoCard.number(3, UnoColor.red);
      expect(card.type, equals(UnoCardType.number));
      expect(card.numberValue, equals(3));
      expect(card.color, equals(UnoColor.red));
      expect(card.effect, isNull);
    });

    test('Special card stores effect and color correctly', () {
      final card = UnoCard.special(SpecialEffect.skip, UnoColor.blue);
      expect(card.type, equals(UnoCardType.special));
      expect(card.effect, equals(SpecialEffect.skip));
      expect(card.color, equals(UnoColor.blue));
      expect(card.numberValue, isNull);
    });

    test('Rainbow card has rainbow color and no value/effect', () {
      final card = UnoCard.rainbow();
      expect(card.type, equals(UnoCardType.rainbow));
      expect(card.color, equals(UnoColor.rainbow));
      expect(card.numberValue, isNull);
      expect(card.effect, isNull);
    });

    test('All four number values are representable', () {
      for (int v = 1; v <= 4; v++) {
        final card = UnoCard.number(v, UnoColor.green);
        expect(card.numberValue, equals(v));
      }
    });

    test('All special effects are representable', () {
      for (final e in SpecialEffect.values) {
        final card = UnoCard.special(e, UnoColor.yellow);
        expect(card.effect, equals(e));
      }
    });

    test('All normal colors are representable on number cards', () {
      for (final c in [UnoColor.red, UnoColor.yellow, UnoColor.green, UnoColor.blue]) {
        final card = UnoCard.number(1, c);
        expect(card.color, equals(c));
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('UnoEffect', () {

    test('Number 1 → 1 chess move', () {
      final card = UnoCard.number(1, UnoColor.red);
      final effect = UnoEffect.fromCard(card);
      expect(effect.chessMoves, equals(1));
      expect(effect.revivalPoints, equals(0));
      expect(effect.isSkip, isFalse);
      expect(effect.isReverse, isFalse);
      expect(effect.isRainbow, isFalse);
    });

    test('Number 2 → 2 chess moves', () {
      expect(UnoEffect.fromCard(UnoCard.number(2, UnoColor.blue)).chessMoves, equals(2));
    });

    test('Number 3 → 3 chess moves', () {
      expect(UnoEffect.fromCard(UnoCard.number(3, UnoColor.green)).chessMoves, equals(3));
    });

    test('Number 4 → 4 chess moves', () {
      expect(UnoEffect.fromCard(UnoCard.number(4, UnoColor.yellow)).chessMoves, equals(4));
    });

    test('+2 special → 2 Revival Points, 0 moves', () {
      final effect = UnoEffect.fromCard(UnoCard.special(SpecialEffect.plusTwo, UnoColor.red));
      expect(effect.chessMoves, equals(0));
      expect(effect.revivalPoints, equals(2));
      expect(effect.isSkip, isFalse);
      expect(effect.isReverse, isFalse);
    });

    test('+4 special → 4 Revival Points, 0 moves', () {
      final effect = UnoEffect.fromCard(UnoCard.special(SpecialEffect.plusFour, UnoColor.red));
      expect(effect.revivalPoints, equals(4));
      expect(effect.chessMoves, equals(0));
    });

    test('Skip → 0 moves, isSkip true', () {
      final effect = UnoEffect.fromCard(UnoCard.special(SpecialEffect.skip, UnoColor.blue));
      expect(effect.chessMoves, equals(0));
      expect(effect.isSkip, isTrue);
      expect(effect.revivalPoints, equals(0));
    });

    test('Reverse → isReverse true', () {
      final effect = UnoEffect.fromCard(UnoCard.special(SpecialEffect.reverse, UnoColor.green));
      expect(effect.isReverse, isTrue);
      expect(effect.chessMoves, equals(0));
    });

    test('Rainbow → isRainbow true, unresolved', () {
      final effect = UnoEffect.fromCard(UnoCard.rainbow());
      expect(effect.isRainbow, isTrue);
      expect(effect.chessMoves, equals(0));
      expect(effect.revivalPoints, equals(0));
    });

    test('Rainbow resolves to move counts 1–4', () {
      for (int m = 1; m <= 4; m++) {
        final resolved = UnoEffect.resolve(moves: m);
        expect(resolved.chessMoves, equals(m));
        expect(resolved.isRainbow, isFalse);
      }
    });

    test('Rainbow resolves to every special effect', () {
      final p2 = UnoEffect.resolve(specialEffect: SpecialEffect.plusTwo);
      expect(p2.revivalPoints, equals(2));

      final p4 = UnoEffect.resolve(specialEffect: SpecialEffect.plusFour);
      expect(p4.revivalPoints, equals(4));

      final sk = UnoEffect.resolve(specialEffect: SpecialEffect.skip);
      expect(sk.isSkip, isTrue);

      final rv = UnoEffect.resolve(specialEffect: SpecialEffect.reverse);
      expect(rv.isReverse, isTrue);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('Probability configuration', () {
    const double epsilon = 1e-9;

    test('Category probabilities total 100%', () {
      const pNum     = 0.45;
      const pSpecial = 0.45;
      const pRainbow = 0.10;
      expect(pNum + pSpecial + pRainbow, closeTo(1.0, epsilon));
    });

    test('Within-number probabilities total 100%', () {
      const p1 = 0.45;
      const p2 = 0.30;
      const p3 = 0.15;
      const p4 = 0.10;
      expect(p1 + p2 + p3 + p4, closeTo(1.0, epsilon));
    });

    test('Within-special probabilities total 100%', () {
      const pP2  = 0.25;
      const pP4  = 0.15;
      const pSkip = 0.30;
      const pRev  = 0.30;
      expect(pP2 + pP4 + pSkip + pRev, closeTo(1.0, epsilon));
    });

    test('Overall number-card probabilities match spec', () {
      const pNum = 0.45;
      expect(pNum * 0.45, closeTo(0.2025, epsilon)); // 1
      expect(pNum * 0.30, closeTo(0.1350, epsilon)); // 2
      expect(pNum * 0.15, closeTo(0.0675, epsilon)); // 3
      expect(pNum * 0.10, closeTo(0.0450, epsilon)); // 4
    });

    test('Overall special-card probabilities match spec', () {
      const pSpec = 0.45;
      expect(pSpec * 0.25, closeTo(0.1125, epsilon)); // +2
      expect(pSpec * 0.15, closeTo(0.0675, epsilon)); // +4
      expect(pSpec * 0.30, closeTo(0.1350, epsilon)); // Skip
      expect(pSpec * 0.30, closeTo(0.1350, epsilon)); // Reverse
    });

    test('Overall probabilities sum to 100%', () {
      const total = 0.2025 + 0.1350 + 0.0675 + 0.0450   // numbers
                  + 0.1125 + 0.0675 + 0.1350 + 0.1350   // specials
                  + 0.10;                                 // rainbow
      expect(total, closeTo(1.0, epsilon));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('UnoCardGenerator — deterministic', () {
    // Each generator call uses two random rolls:
    // 1. categoryRoll (nextDouble)
    // 2. within-category roll (nextDouble) + color roll (nextInt(4))

    test('categoryRoll < 0.45 → number card', () {
      final gen = UnoCardGenerator(
        _FixedRandom(doubles: [0.10, 0.50], ints: [0]), // 0.50 → value=2, color=red
      );
      final card = gen.generate();
      expect(card.type, equals(UnoCardType.number));
      expect(card.numberValue, equals(2)); // 0.50 ≥ 0.45 and < 0.75 → value 2
    });

    test('0.45 ≤ categoryRoll < 0.90 → special card', () {
      final gen = UnoCardGenerator(
        _FixedRandom(doubles: [0.60, 0.10], ints: [1]), // +2
      );
      final card = gen.generate();
      expect(card.type, equals(UnoCardType.special));
      expect(card.effect, equals(SpecialEffect.plusTwo));
    });

    test('categoryRoll ≥ 0.90 → rainbow card', () {
      final gen = UnoCardGenerator(
        _FixedRandom(doubles: [0.95], ints: []),
      );
      final card = gen.generate();
      expect(card.type, equals(UnoCardType.rainbow));
      expect(card.color, equals(UnoColor.rainbow));
    });

    test('Within-number: roll < 0.45 → value 1', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.10, 0.20], ints: [0]));
      expect(gen.generate().numberValue, equals(1));
    });

    test('Within-number: 0.45 ≤ roll < 0.75 → value 2', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.10, 0.60], ints: [0]));
      expect(gen.generate().numberValue, equals(2));
    });

    test('Within-number: 0.75 ≤ roll < 0.90 → value 3', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.10, 0.80], ints: [0]));
      expect(gen.generate().numberValue, equals(3));
    });

    test('Within-number: roll ≥ 0.90 → value 4', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.10, 0.95], ints: [0]));
      expect(gen.generate().numberValue, equals(4));
    });

    test('Within-special: roll < 0.25 → +2', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.60, 0.10], ints: [0]));
      expect(gen.generate().effect, equals(SpecialEffect.plusTwo));
    });

    test('Within-special: 0.25 ≤ roll < 0.40 → +4', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.60, 0.30], ints: [0]));
      expect(gen.generate().effect, equals(SpecialEffect.plusFour));
    });

    test('Within-special: 0.40 ≤ roll < 0.70 → skip', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.60, 0.55], ints: [0]));
      expect(gen.generate().effect, equals(SpecialEffect.skip));
    });

    test('Within-special: roll ≥ 0.70 → reverse', () {
      final gen = UnoCardGenerator(_FixedRandom(doubles: [0.60, 0.85], ints: [0]));
      expect(gen.generate().effect, equals(SpecialEffect.reverse));
    });

    test('Color index 0–3 map to normal colors', () {
      final colors = [UnoColor.red, UnoColor.yellow, UnoColor.green, UnoColor.blue];
      for (int i = 0; i < 4; i++) {
        final gen = UnoCardGenerator(_FixedRandom(doubles: [0.10, 0.20], ints: [i]));
        expect(gen.generate().color, equals(colors[i]));
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('UnoCardGenerator — statistical sanity', () {
    test('All card categories appear in 10 000 draws', () {
      final gen = UnoCardGenerator(Random(42));
      final types = <UnoCardType>{};
      for (int i = 0; i < 10000; i++) {
        types.add(gen.generate().type);
      }
      expect(types, containsAll(UnoCardType.values));
    });

    test('All number values 1–4 appear in 10 000 draws', () {
      final gen = UnoCardGenerator(Random(42));
      final values = <int>{};
      for (int i = 0; i < 10000; i++) {
        final card = gen.generate();
        if (card.type == UnoCardType.number) values.add(card.numberValue!);
      }
      expect(values, containsAll([1, 2, 3, 4]));
    });

    test('All special effects appear in 10 000 draws', () {
      final gen = UnoCardGenerator(Random(42));
      final effects = <SpecialEffect>{};
      for (int i = 0; i < 10000; i++) {
        final card = gen.generate();
        if (card.type == UnoCardType.special) effects.add(card.effect!);
      }
      expect(effects, containsAll(SpecialEffect.values));
    });

    test('All normal colors appear in 10 000 draws', () {
      final gen = UnoCardGenerator(Random(42));
      final colors = <UnoColor>{};
      for (int i = 0; i < 10000; i++) {
        final card = gen.generate();
        if (card.color != UnoColor.rainbow) colors.add(card.color);
      }
      for (final c in [UnoColor.red, UnoColor.yellow, UnoColor.green, UnoColor.blue]) {
        expect(colors, contains(c));
      }
    });
  });
}
