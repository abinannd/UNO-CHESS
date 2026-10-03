import 'package:flutter/material.dart';
import 'package:uno_chess/screens/game/game_screen.dart';

void main() {
  runApp(const UnoChessApp());
}

class UnoChessApp extends StatelessWidget {
  const UnoChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNO Chess',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
