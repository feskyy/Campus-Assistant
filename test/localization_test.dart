import 'image_test_support.dart';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('English navigation and locale persist', (tester) async {
    SharedPreferences.setMockInitialValues({'locale_code': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    container.read(authControllerProvider.notifier).enterDemo();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusAssistantApp(),
      ),
    );
    await settleCampus(tester);
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await settleCampus(tester);
    expect(find.text('Profile and settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    await container.read(appSettingsProvider.notifier).setLocale('ru');
    await settleCampus(tester);
    expect(find.text('Профиль и настройки'), findsOneWidget);
    expect(prefs.getString('locale_code'), 'ru');
    await tester.pumpWidget(const SizedBox());
  });
}
