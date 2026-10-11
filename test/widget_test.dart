import 'package:flutter_test/flutter_test.dart';
import 'package:campus_assistant/main.dart';

void main() {
  testWidgets('shows greeting text', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusAssistantApp());

    expect(find.text('Hello, Campus Assistant!'), findsOneWidget);
  });
}
