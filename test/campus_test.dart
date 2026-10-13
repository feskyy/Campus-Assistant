import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_repository.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });
  test('old authentication flag never grants access', () {
    SharedPreferences.setMockInitialValues({'is_authenticated': true});
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(authControllerProvider), SessionMode.signedOut);
    container.read(authControllerProvider.notifier).enterDemo();
    expect(container.read(authControllerProvider), SessionMode.demo);
  });
  test('day and group filter and chronological order', () {
    final items = [
      ...StaticData.lessons.reversed,
      const Lesson(
        id: 'other',
        subject: 'Other',
        teacher: 'T',
        building: 'B',
        room: '1',
        weekday: 1,
        startMinutes: 1,
        endMinutes: 2,
        group: 'OTHER',
      ),
    ];
    final result = lessonsForDay(items, 1, 'CS-221');
    expect(result.map((e) => e.id), ['l1', 'l2', 'l3']);
    expect(lessonsForDay(items, 7, 'CS-221'), isEmpty);
  });
  test('current lesson has exclusive end and next lesson crosses days', () {
    final first = StaticData.lessons.first;
    expect(isCurrentLesson(first, DateTime(2026, 10, 12, 9)), isTrue);
    expect(isCurrentLesson(first, DateTime(2026, 10, 12, 10, 30)), isFalse);
    final next = nextLesson(
      StaticData.lessons,
      'CS-221',
      DateTime(2026, 10, 12, 23),
    );
    expect(next!.lesson.id, 'l4');
    expect(next.start, DateTime(2026, 10, 13, 9));
    expect(
      nextLesson(StaticData.lessons, 'unknown', DateTime(2026, 10, 12)),
      isNull,
    );
  });
  test('favorites restore in a new provider container', () async {
    final first = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await first.read(favoritesProvider.notifier).toggle('news', 'n1');
    first.dispose();
    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);
    expect(second.read(favoritesProvider), {'news:n1'});
    await second.read(favoritesProvider.notifier).toggle('news', 'n1');
    expect(second.read(favoritesProvider), isEmpty);
  });
  test('theme and group restore in a new provider container', () async {
    final first = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    first.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.dark);
    first.read(appSettingsProvider.notifier).setSelectedGroup('OTHER');
    await Future<void>.delayed(Duration.zero);
    first.dispose();
    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);
    expect(second.read(appSettingsProvider).themeMode, ThemeMode.dark);
    expect(second.read(appSettingsProvider).selectedGroup, 'OTHER');
  });
  test('demo source is explicit and does not need network', () async {
    final data = await CampusRepository(prefs: prefs, baseUrl: '').load();
    expect(data.source, contains('демонстрационные'));
    expect(data.lessons, isNotEmpty);
  });
  test('real HTTP JSON is cached and available when server stops', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final base = 'http://127.0.0.1:${server.port}';
    server.listen((request) {
      final payload = switch (request.uri.path) {
        '/schedule' => StaticData.lessons.map((e) => e.toJson()).toList(),
        '/news' => StaticData.news.map((e) => e.toJson()).toList(),
        '/events' => StaticData.events.map((e) => e.toJson()).toList(),
        _ => [],
      };
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(payload));
      request.response.close();
    });
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpOverrides.runWithHttpOverrides(
        () => HttpClient(),
        RealHttpOverrides(),
      ),
    );
    final repository = CampusRepository(prefs: prefs, baseUrl: base, dio: dio);
    final online = await repository.load();
    expect(online.source, 'Данные API');
    expect(repository.cached()!.news.length, StaticData.news.length);
    await server.close(force: true);
    final offline = await repository.load();
    expect(offline.source, 'Сохранённые данные API');
    expect(offline.warning, isNotNull);
    expect(offline.lessons.length, online.lessons.length);
  });
  test('network error without cache never silently returns demo', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final base = 'http://127.0.0.1:${server.port}';
    await server.close(force: true);
    expect(
      CampusRepository(prefs: prefs, baseUrl: base).load(),
      throwsFormatException,
    );
  });
  test('invalid JSON shape rejected', () {
    expect(
      () =>
          CampusData.fromJson({'lessons': {}, 'news': [], 'events': []}, 'API'),
      throwsFormatException,
    );
  });
}

class RealHttpOverrides extends HttpOverrides {}
