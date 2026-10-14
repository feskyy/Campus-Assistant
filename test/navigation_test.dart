import 'image_test_support.dart';

import 'package:campus_assistant/features/feed/presentation/detail_screen.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'demo navigation, day selection, details, favorites, search and logout',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const CampusAssistantApp(),
        ),
      );
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(authControllerProvider.notifier)
          .enterDemo();
      await settleCampus(tester);
      expect(find.text('Добро пожаловать, гость!'), findsOneWidget);
      await tester.tap(find.text('Расписание').last);
      await settleCampus(tester);
      await tester.tap(find.text('Вс'));
      await settleCampus(tester);
      expect(find.text('В этот день занятий нет'), findsOneWidget);
      await tester.tap(find.text('Пн'));
      await settleCampus(tester);
      await tester.ensureVisible(find.text('Математический анализ').first);
      await settleCampus(tester);
      await tester.tap(find.text('Математический анализ').first);
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.text('Группа CS-221'),
        250,
        scrollable: find
            .descendant(
              of: find.byType(DetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await settleCampus(tester);
      expect(find.text('Группа CS-221'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await settleCampus(tester);
      await tester.tap(find.text('Лента'));
      await settleCampus(tester);
      await tester.ensureVisible(
        find.text('Открыта запись в студенческие клубы'),
      );
      await settleCampus(tester);
      await tester.tap(find.text('Открыта запись в студенческие клубы'));
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.text('В избранное'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(DetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('В избранное'));
      await settleCampus(tester);
      expect(find.text('Удалить из избранного'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.text('Избранное'),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Избранное'));
      await settleCampus(tester);
      expect(find.text('Изменился график работы библиотеки'), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'нет совпадений');
      await tester.pump(const Duration(milliseconds: 350));
      await settleCampus(tester);
      expect(find.text('Ничего не найдено'), findsOneWidget);
      await tester.tap(find.text('Профиль'));
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.text('Завершить демонстрацию'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await settleCampus(tester);
      await tester.tap(find.text('Завершить демонстрацию'));
      await settleCampus(tester);
      expect(find.text('Вход в приложение'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
