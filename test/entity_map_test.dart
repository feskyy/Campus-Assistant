import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/di/external_links.dart';
import 'package:campus_assistant/features/map/domain/entities/room.dart';
import 'package:campus_assistant/features/map/presentation/campus_map_view.dart';
import 'package:campus_assistant/features/map/presentation/map_screen.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart';
import 'package:campus_assistant/main.dart';

class FakeLinks implements ExternalLinks {
  final calls = <Uri>[];
  @override
  Future<bool> open(Uri uri) async {
    calls.add(uri);
    return false;
  }
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    280,
    scrollable: find.byType(Scrollable).first,
  );
  await settleCampus(tester);
  await tester.ensureVisible(target);
  await settleCampus(tester);
}

void main() {
  test('room hints are optional, serialized and validated', () {
    expect(Room.fromJson({'number': '214'}).hint, isNull);
    final r = Room.fromJson({
      'number': '214',
      'floor': 2,
      'hint': 'Этаж 2, налево от лестницы',
    });
    expect(Room.fromJson(r.toJson()).hint, r.hint);
    expect(
      () => Room.fromJson({'number': '214', 'hint': 7}),
      throwsFormatException,
    );
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(360, 640), const Size(1280, 800)]) {
      testWidgets('${mode.name} $size lesson subject teacher map', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
        final prefs = await SharedPreferences.getInstance();
        final links = FakeLinks();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              externalLinksProvider.overrideWithValue(links),
            ],
            child: const CampusAssistantApp(),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(Scaffold).first),
        );
        container.read(authControllerProvider.notifier).enterDemo();
        await settleCampus(tester);
        final router = container.read(routerProvider);
        router.pushNamed(Routes.lesson, pathParameters: {'id': 'l1'});
        await settleCampus(tester);
        expect(find.byType(StatRow), findsOneWidget);
        expect(find.text('Группа CS-221'), findsOneWidget);
        expect(find.byType(Hero), findsWidgets);
        await reveal(tester, find.text('Показать на карте'));
        await tester.tap(find.text('Показать на карте'));
        await settleCampus(tester);
        expect(
          tester.widget<MapScreen>(find.byType(MapScreen)).building,
          'main',
        );
        expect(tester.widget<MapScreen>(find.byType(MapScreen)).room, '214');
        expect(find.byType(CampusPlanView), findsOneWidget);
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
        final roomTile = find.byKey(const ValueKey('room:main:214'));
        await reveal(tester, roomTile);
        await tester.tap(roomTile);
        await settleCampus(tester);
        final infoScroll = find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.text('Этаж 2, налево от лестницы'),
          180,
          scrollable: infoScroll,
        );
        await settleCampus(tester);
        expect(find.text('Этаж 2, налево от лестницы'), findsOneWidget);
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byKey(const ValueKey('map-room-info')), findsOneWidget);
        expect(find.byType(DraggableScrollableSheet), findsNothing);
        await tester.scrollUntilVisible(
          find.text('Маршрут'),
          180,
          scrollable: infoScroll,
        );
        await settleCampus(tester);
        await tester.ensureVisible(find.text('Маршрут'));
        await settleCampus(tester);
        await tester.tap(find.text('Маршрут'));
        await settleCampus(tester);
        expect(links.calls.last.host, 'www.google.com');
        expect(links.calls.last.queryParameters['destination'], isNotEmpty);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Понятно'));
        await settleCampus(tester);
        await tester.tap(find.byTooltip('Закрыть'));
        await settleCampus(tester);
        await tester.scrollUntilVisible(
          find.text('Все корпуса'),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await settleCampus(tester);
        await tester.tap(find.text('Все корпуса'));
        await settleCampus(tester);
        await tester.scrollUntilVisible(
          find.byType(TextField),
          -160,
          scrollable: find.byType(Scrollable).first,
        );
        await settleCampus(tester);
        await tester.enterText(find.byType(TextField), '305');
        await settleCampus(tester);
        await tester.scrollUntilVisible(
          find.text('Этаж 3 · Аудитория 305'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.text('Этаж 3 · Аудитория 305'));
        await settleCampus(tester);
        await tester.tap(find.text('Этаж 3 · Аудитория 305'));
        await settleCampus(tester);
        expect(find.text('Аудитория: 305'), findsOneWidget);
        await tester.tap(find.byTooltip('Закрыть'));
        await settleCampus(tester);
        router.pushNamed(Routes.lesson, pathParameters: {'id': 'l1'});
        await settleCampus(tester);
        await reveal(tester, find.byKey(const ValueKey('subject-link:math')));
        await tester.tap(find.byKey(const ValueKey('subject-link:math')));
        await settleCampus(tester);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          '/subject/math',
        );
        await reveal(
          tester,
          find.byKey(const ValueKey('section:Программа курса')),
        );
        expect(find.text('Программа курса'), findsWidgets);
        await reveal(tester, find.byKey(const ValueKey('teacher-link:ivanov')));
        await tester.tap(find.byKey(const ValueKey('teacher-link:ivanov')));
        await settleCampus(tester);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          '/teacher/ivanov',
        );
        await reveal(tester, find.text('Написать'));
        await tester.tap(find.text('Написать'));
        await settleCampus(tester);
        expect(links.calls.last.scheme, 'mailto');
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Понятно'));
        await settleCampus(tester);
        for (var i = 0; i < 8; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -400),
          );
          await settleCampus(tester);
          expect(tester.takeException(), isNull);
        }
        for (final entry in [
          (Routes.lesson, 'l1'),
          (Routes.subject, 'math'),
          (Routes.teacher, 'ivanov'),
        ]) {
          router.goNamed(entry.$1, pathParameters: {'id': entry.$2});
          await settleCampus(tester);
          for (var i = 0; i < 16; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -400),
            );
            await settleCampus(tester);
            expect(tester.takeException(), isNull);
          }
        }
        for (final kind in [Routes.lesson, Routes.subject, Routes.teacher]) {
          router.goNamed(kind, pathParameters: {'id': 'missing'});
          await settleCampus(tester);
          expect(find.text('Не найдено'), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
