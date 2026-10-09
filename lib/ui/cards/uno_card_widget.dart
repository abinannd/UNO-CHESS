import 'package:flutter/material.dart';
import 'package:uno_chess/core/uno/uno_card.dart';
import 'package:uno_chess/core/uno/uno_card_type.dart';
import 'package:uno_chess/core/uno/special_effect.dart';
import 'package:uno_chess/core/uno/uno_color.dart';

class UnoCardWidget extends StatelessWidget {
  final UnoCard? card;
  final double width;
  
  const UnoCardWidget({super.key, this.card, this.width = 100});

  String _getAssetPath() {
    if (card == null) return '';

    if (card!.type == UnoCardType.rainbow) {
      return 'assets/cards/rainbow.png';
    }

    if (card!.type == UnoCardType.special) {
      if (card!.effect == SpecialEffect.plusFour) {
        return 'assets/cards/plus_4_draw card.png';
      }
      
      String colorStr = _getColorString(card!.color);
      
      if (card!.effect == SpecialEffect.plusTwo) {
        return 'assets/cards/${colorStr}_Draw_2.jpg';
      } else if (card!.effect == SpecialEffect.skip) {
        return 'assets/cards/${colorStr}_Skip.jpg';
      } else if (card!.effect == SpecialEffect.reverse) {
        if (card!.color == UnoColor.red) {
          return 'assets/cards/RED_Reverse.jpg';
        }
        return 'assets/cards/${colorStr}_Reverse.jpg';
      }
    }

    if (card!.type == UnoCardType.number) {
      String colorStr = _getColorString(card!.color);
      return 'assets/cards/${colorStr}_${card!.numberValue}.jpg';
    }

    return '';
  }

  String _getColorString(UnoColor color) {
    switch (color) {
      case UnoColor.red: return 'Red';
      case UnoColor.blue: return 'Blue';
      case UnoColor.green: return 'Green';
      case UnoColor.yellow: return 'Yellow';
      case UnoColor.rainbow: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath();

    if (assetPath.isEmpty || card == null) {
      return SizedBox(
        width: width,
        height: width * 1.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: const Center(
            child: Text(
              'UNO',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: width * 1.5,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
