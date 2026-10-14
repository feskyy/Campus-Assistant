import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/main.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart';
import 'package:campus_assistant/features/map/presentation/map_screen.dart';

void main() {
  testWidgets(
    'next lesson route targets room; category filters photo listings',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            clockProvider.overrideWith(
              (ref) => Stream.value(DateTime(2026, 10, 12, 8, 35)),
            ),
          ],
          child: const CampusAssistantApp(),
        ),
      );
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(authControllerProvider.notifier)
          .enterDemo();
      await settleCampus(tester);
      expect(find.textContaining('через 25 мин'), findsOneWidget);
      await tester.ensureVisible(find.text('Маршрут'));
      await settleCampus(tester);
      await tester.tap(find.text('Маршрут'));
      await settleCampus(tester);
      expect(tester.widget<MapScreen>(find.byType(MapScreen)).room, '214');
      expect(tester.widget<MapScreen>(find.byType(MapScreen)).building, 'main');
      await tester.scrollUntilVisible(
        find.text('Этаж 2 · Аудитория 214'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await settleCampus(tester);
      expect(find.text('Этаж 2 · Аудитория 214'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Главная'),
        ),
      );
      await settleCampus(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Лента'),
        ),
      );
      await settleCampus(tester);
      await tester.tap(find.text('События'));
      await settleCampus(tester);
      final sportCategory = find.widgetWithText(FilterChip, 'Спорт');
      await tester.scrollUntilVisible(
        sportCategory,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(sportCategory);
      await settleCampus(tester);
      await tester.tap(find.text('Спорт'));
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.text('Студенческий турнир по волейболу'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await settleCampus(tester);
      expect(find.text('Студенческий турнир по волейболу'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListingCard),
          matching: find.text('Хакатон Mobile Dev Weekend'),
        ),
        findsNothing,
      );
      expect(find.byType(CampusImage), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
