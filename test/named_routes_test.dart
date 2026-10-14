import 'image_test_support.dart';

import 'package:campus_assistant/features/feed/presentation/detail_screen.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('named route parameters and unknown path/id', (tester) async {
    SharedPreferences.setMockInitialValues({});
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
    final router = container.read(routerProvider);
    router.goNamed(Routes.feed, queryParameters: {'tab': 'events'});
    await settleCampus(tester);
    expect(find.text('Новости и события'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['tab'],
      'events',
    );
    router.pushNamed(Routes.news, pathParameters: {'id': 'unknown/id'});
    await settleCampus(tester);
    expect(find.text('Не найдено'), findsOneWidget);
    expect(
      tester.widget<DetailScreen>(find.byType(DetailScreen)).id,
      'unknown/id',
    );
    router.go('/missing-page');
    await settleCampus(tester);
    expect(find.text('404'), findsOneWidget);
    expect(find.text('Не найдено'), findsOneWidget);
    await tester.tap(find.text('На главную'));
    await settleCampus(tester);
    expect(find.text('Добро пожаловать, гость!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
