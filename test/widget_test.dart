import 'package:flutter_test/flutter_test.dart';
import 'package:jobsy/main.dart'; // Import your main app

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Jobsy());

    // Verify that the "START WORK LOG" button is present.
    expect(find.text('START WORK LOG'), findsOneWidget);
  });
}
