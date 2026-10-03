import 'special_effect.dart';
import 'uno_card.dart';
import 'uno_card_type.dart';

/// The resolved effect that results from drawing (and optionally resolving) a UNO card.
///
/// The Turn System consumes this to determine what happens next:
/// - [chessMoves] : how many legal chess moves the active player may make (0–4).
/// - [revivalPoints] : Revival Points granted (0, 2, or 4).
/// - [isSkip] : the player's turn is skipped (no moves).
/// - [isReverse] : the two players swap their chess-color assignments.
/// - [isRainbow] : the card is Rainbow and must be resolved before the effect is known.
class UnoEffect {
  final int chessMoves;
  final int revivalPoints;
  final bool isSkip;
  final bool isReverse;
  final bool isRainbow;

  const UnoEffect({
    this.chessMoves = 0,
    this.revivalPoints = 0,
    this.isSkip = false,
    this.isReverse = false,
    this.isRainbow = false,
  });

  // ── Canonical effect instances ────────────────────────────────────────────

  static const move1    = UnoEffect(chessMoves: 1);
  static const move2    = UnoEffect(chessMoves: 2);
  static const move3    = UnoEffect(chessMoves: 3);
  static const move4    = UnoEffect(chessMoves: 4);
  static const plusTwo  = UnoEffect(revivalPoints: 2);
  static const plusFour = UnoEffect(revivalPoints: 4);
  static const skip     = UnoEffect(isSkip: true);
  static const reverse  = UnoEffect(isReverse: true);
  static const rainbow  = UnoEffect(isRainbow: true);

  /// Derives the [UnoEffect] directly from a drawn [card].
  /// For Rainbow cards, returns [UnoEffect.rainbow] — the Turn System must call
  /// [UnoEffect.resolve] once the player selects their desired effect.
  factory UnoEffect.fromCard(UnoCard card) {
    switch (card.type) {
      case UnoCardType.number:
        switch (card.numberValue!) {
          case 1: return move1;
          case 2: return move2;
          case 3: return move3;
          case 4: return move4;
          default: throw StateError('Invalid number value: ${card.numberValue}');
        }
      case UnoCardType.special:
        switch (card.effect!) {
          case SpecialEffect.plusTwo:  return plusTwo;
          case SpecialEffect.plusFour: return plusFour;
          case SpecialEffect.skip:     return skip;
          case SpecialEffect.reverse:  return reverse;
        }
      case UnoCardType.rainbow:
        return rainbow;
    }
  }

  /// Resolves a Rainbow card to a specific [SpecialEffect] or a number of [moves].
  /// Exactly one of [moves] (1–4) or [specialEffect] must be provided.
  static UnoEffect resolve({int? moves, SpecialEffect? specialEffect}) {
    assert(
      (moves != null) != (specialEffect != null),
      'Exactly one of moves or specialEffect must be provided',
    );
    if (moves != null) {
      assert(moves >= 1 && moves <= 4, 'Rainbow move resolution must be 1–4');
      return UnoEffect(chessMoves: moves);
    }
    switch (specialEffect!) {
      case SpecialEffect.plusTwo:  return plusTwo;
      case SpecialEffect.plusFour: return plusFour;
      case SpecialEffect.skip:     return skip;
      case SpecialEffect.reverse:  return reverse;
    }
  }

  @override
  String toString() {
    if (isRainbow) return 'UnoEffect(rainbow — unresolved)';
    if (isSkip)    return 'UnoEffect(skip)';
    if (isReverse) return 'UnoEffect(reverse)';
    if (revivalPoints > 0) return 'UnoEffect(+${revivalPoints}RP)';
    return 'UnoEffect(${chessMoves} move${chessMoves == 1 ? "" : "s"})';
  }
}
