import 'dart:math';

import 'special_effect.dart';
import 'uno_card.dart';
import 'uno_color.dart';

/// Exact probability weights used for card generation.
///
/// Category weights (sum = 1.0):
///   Number  = 0.45
///   Special = 0.45
///   Rainbow = 0.10
///
/// Within-Number weights (sum = 1.0):
///   1 = 0.45,  2 = 0.30,  3 = 0.15,  4 = 0.10
///
/// Within-Special weights (sum = 1.0):
///   +2 = 0.25, +4 = 0.15, Skip = 0.30, Reverse = 0.30
///
/// Overall probabilities match the specification exactly:
///   1→20.25%, 2→13.50%, 3→6.75%, 4→4.50%
///   +2→11.25%, +4→6.75%, Skip→13.50%, Reverse→13.50%, Rainbow→10%
class UnoCardGenerator {
  static const double _pNumber  = 0.45;
  static const double _pSpecial = 0.45;
  // _pRainbow = 0.10 (remainder)

  // Within-number cumulative thresholds
  static const double _n1 = 0.45;
  static const double _n2 = 0.75; // 0.45 + 0.30
  static const double _n3 = 0.90; // + 0.15

  // Within-special cumulative thresholds
  static const double _s_p2  = 0.25;
  static const double _s_p4  = 0.40; // 0.25 + 0.15
  static const double _s_skip = 0.70; // + 0.30

  static const List<UnoColor> _normalColors = [
    UnoColor.red,
    UnoColor.yellow,
    UnoColor.green,
    UnoColor.blue,
  ];

  final Random _random;

  /// Provide a [Random] instance for testability; defaults to [Random()].
  UnoCardGenerator([Random? random]) : _random = random ?? Random();

  /// Generates a single UNO card according to the specified probabilities.
  UnoCard generate() {
    final categoryRoll = _random.nextDouble();

    if (categoryRoll < _pNumber) {
      return _generateNumber();
    } else if (categoryRoll < _pNumber + _pSpecial) {
      return _generateSpecial();
    } else {
      return UnoCard.rainbow();
    }
  }

  UnoCard _generateNumber() {
    final color = _randomNormalColor();
    final roll  = _random.nextDouble();
    final int value;
    if (roll < _n1)      value = 1;
    else if (roll < _n2) value = 2;
    else if (roll < _n3) value = 3;
    else                 value = 4;
    return UnoCard.number(value, color);
  }

  UnoCard _generateSpecial() {
    final color = _randomNormalColor();
    final roll  = _random.nextDouble();
    final SpecialEffect effect;
    if (roll < _s_p2)       effect = SpecialEffect.plusTwo;
    else if (roll < _s_p4)  effect = SpecialEffect.plusFour;
    else if (roll < _s_skip) effect = SpecialEffect.skip;
    else                    effect = SpecialEffect.reverse;
    return UnoCard.special(effect, color);
  }

  UnoColor _randomNormalColor() {
    return _normalColors[_random.nextInt(_normalColors.length)];
  }
}
