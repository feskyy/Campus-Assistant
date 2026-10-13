import 'dart:async';

import 'package:campus_assistant/core/presentation/startup_screen.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first frame shows loading before preferences are ready', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final pending = Completer<SharedPreferences>();
    await tester.pumpWidget(
      CampusBootstrap(
        preferencesLoader: () => pending.future,
        child: const CampusAssistantApp(),
      ),
    );
    expect(find.text('Загружаем настройки…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(prefs);
    await tester.pumpAndSettle();
    expect(find.text('Вход в приложение'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('failed initialization shows retry and can recover', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var attempts = 0;
    await tester.pumpWidget(
      CampusBootstrap(
        preferencesLoader: () {
          attempts++;
          return attempts == 1
              ? Future<SharedPreferences>.error(StateError('storage failed'))
              : Future.value(prefs);
        },
        child: const CampusAssistantApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Не удалось загрузить локальные данные'),
      findsOneWidget,
    );
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Вход в приложение'), findsOneWidget);
    expect(attempts, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
