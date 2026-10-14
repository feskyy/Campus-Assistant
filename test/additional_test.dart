import 'image_test_support.dart';

import 'package:campus_assistant/core/di/storage_providers.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('next weekly lesson wraps to the same weekday next week', () {
    final next = nextLesson(
      [StaticData.lessons.first],
      'CS-221',
      DateTime(2026, 10, 12, 23),
    );
    expect(next!.start, DateTime(2026, 10, 19, 9));
  });
  test('malformed models reject bad dates and reversed lesson times', () {
    final news = StaticData.news.first.toJson()..['publishedAt'] = 'broken';
    expect(() => NewsItem.fromJson(news), throwsFormatException);
    final lesson = StaticData.lessons.first.toJson()..['endMinutes'] = 1;
    expect(() => Lesson.fromJson(lesson), throwsFormatException);
  });
  test('rapid favorite changes do not lose updates', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final favorites = container.read(favoritesProvider.notifier);
    await Future.wait([
      favorites.toggle('news', 'n1'),
      favorites.toggle('event', 'e1'),
      favorites.toggle('news', 'n2'),
    ]);
    expect(container.read(favoritesProvider), {
      'news:n1',
      'event:e1',
      'news:n2',
    });
    expect(container.read(localStoreProvider).read('favorite_news_ids'), [
      'n1',
      'n2',
    ]);
    expect(prefs.containsKey('favorite_news_ids'), isFalse);
    await Future.wait([
      favorites.toggle('news', 'n1'),
      favorites.toggle('news', 'n1'),
    ]);
    expect(container.read(favoritesProvider), contains('news:n1'));
  });
  testWidgets('small screen keeps login and tabs usable', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Расписание').last);
    await settleCampus(tester);
    await tester.tap(find.text('Пн'));
    await settleCampus(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Карта'));
    await settleCampus(tester);
    await tester.enterText(find.byType(TextField), '305');
    await settleCampus(tester);
    await tester.scrollUntilVisible(
      find.text('Этаж 3 · Аудитория 305'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await settleCampus(tester);
    expect(find.text('Этаж 3 · Аудитория 305'), findsOneWidget);
    await tester.ensureVisible(find.text('Этаж 3 · Аудитория 305'));
    await settleCampus(tester);
    await tester.tap(find.text('Этаж 3 · Аудитория 305'));
    await settleCampus(tester);
    expect(find.textContaining('Аудитория: 305'), findsOneWidget);
    expect(find.byKey(const ValueKey('map-room-info')), findsOneWidget);
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    await tester.tap(find.byTooltip('Закрыть'));
    await settleCampus(tester);
    await tester.tap(find.text('Профиль'));
    await settleCampus(tester);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
