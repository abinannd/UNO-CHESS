import 'uno_card_type.dart';
import 'uno_color.dart';
import 'special_effect.dart';

/// An immutable UNO card.
///
/// - Number card: [type] == number, [numberValue] in {1,2,3,4}, [color] in normal colors.
/// - Special card: [type] == special, [effect] is set, [color] in normal colors.
/// - Rainbow card: [type] == rainbow, [color] == UnoColor.rainbow. No value/effect until resolved.
class UnoCard {
  final UnoCardType type;
  final UnoColor color;
  final int? numberValue;
  final SpecialEffect? effect;

  const UnoCard._({
    required this.type,
    required this.color,
    this.numberValue,
    this.effect,
  });

  /// Creates a Number card. [value] must be 1–4. [color] must be a normal color.
  factory UnoCard.number(int value, UnoColor color) {
    assert(value >= 1 && value <= 4, 'Number value must be 1–4');
    assert(color != UnoColor.rainbow, 'Number cards cannot be rainbow');
    return UnoCard._(type: UnoCardType.number, color: color, numberValue: value);
  }

  /// Creates a Special card. [color] must be a normal color.
  factory UnoCard.special(SpecialEffect effect, UnoColor color) {
    assert(color != UnoColor.rainbow, 'Special cards cannot be rainbow');
    return UnoCard._(type: UnoCardType.special, color: color, effect: effect);
  }

  /// Creates a Rainbow (magical) card.
  factory UnoCard.rainbow() {
    return const UnoCard._(type: UnoCardType.rainbow, color: UnoColor.rainbow);
  }

  @override
  String toString() {
    switch (type) {
      case UnoCardType.number:
        return 'UnoCard(number $numberValue, ${color.name})';
      case UnoCardType.special:
        return 'UnoCard(${effect!.name}, ${color.name})';
      case UnoCardType.rainbow:
        return 'UnoCard(rainbow)';
    }
  }
}
