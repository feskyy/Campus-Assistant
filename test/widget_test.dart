import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen for unauthenticated user', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const CampusAssistantApp(),
      ),
    );

    expect(find.text('Вход в приложение'), findsOneWidget);
  });
}
