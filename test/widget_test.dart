import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/main.dart';

void main() {
  testWidgets('App loads GameScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UnoChessApp());

    // Verify that our app bar text is present.
    expect(find.text('UNO Chess'), findsOneWidget);
  });
}
