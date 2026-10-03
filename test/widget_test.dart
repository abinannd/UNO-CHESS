import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chess/main.dart';

void main() {
  testWidgets('App loads placeholder screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UnoChessApp());

    // Verify that our text is present.
    expect(find.text('UNO Chess Architecture Ready'), findsOneWidget);
  });
}
