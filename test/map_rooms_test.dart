import 'dart:async';

import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';
import 'package:campus_assistant/features/map/domain/entities/room.dart';
import 'package:campus_assistant/features/map/domain/room_schedule.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/main.dart';

Future<ProviderContainer> openMap(
  WidgetTester tester,
  ThemeMode mode, {
  Stream<DateTime>? clock,
}) async {
  SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWith(
          (ref) => clock ?? Stream.value(DateTime(2026, 10, 12, 9, 30)),
        ),
      ],
      child: const CampusAssistantApp(),
    ),
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  );
  container.read(authControllerProvider.notifier).enterDemo();
  container.read(routerProvider).goNamed(Routes.map);
  await settleCampus(tester);
  return container;
}

Future<void> revealRoom(WidgetTester tester, String id) async {
  final tile = find.byKey(ValueKey(id));
  await tester.scrollUntilVisible(
    tile,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(tile);
  await settleCampus(tester);
}

void main() {
  const building = Building(id: 'main', name: 'Главный корпус');
  const room = Room(number: '214');
  Lesson lesson(
    String id, {
    String? buildingId = 'main',
    String group = 'CS-221',
    int start = 540,
    int end = 630,
  }) => Lesson(
    id: id,
    subject: id,
    teacher: 'Преподаватель',
    building: 'Главный корпус',
    room: '214',
    weekday: 1,
    startMinutes: start,
    endMinutes: end,
    buildingId: buildingId,
    group: group,
  );
  test('availability includes all groups, isolates buildings, supports legacy names and sorts without mutation', () {
    final lessons = [
      lesson('later', start: 720, end: 810),
      lesson('other-group', group: 'CS-222'),
      lesson('wrong-building', buildingId: 'other'),
      lesson('legacy', buildingId: null),
    ];
    final snapshot = RoomSchedule(
      building: building,
      room: room,
      lessons: lessons,
      now: DateTime(2026, 10, 12, 9, 30),
    );
    expect(
      snapshot.current.map((l) => l.id),
      unorderedEquals(['other-group', 'legacy']),
    );
    expect(snapshot.isFree, isFalse);
    expect(snapshot.next?.id, 'later');
    expect(lessons.first.id, 'later');
    expect(snapshot.today, hasLength(3));
  });
  test('occupied from start until exclusive end; a different weekday is free by timetable', () {
    for (final entry in [
      (8, 59, true),
      (9, 0, false),
      (10, 29, false),
      (10, 30, true),
    ]) {
      expect(
        RoomSchedule(
          building: building,
          room: room,
          lessons: [lesson('l')],
          now: DateTime(2026, 10, 12, entry.$1, entry.$2),
        ).isFree,
        entry.$3,
      );
    }
    expect(
      RoomSchedule(
        building: building,
        room: room,
        lessons: [lesson('l')],
        now: DateTime(2026, 10, 13, 9, 30),
      ).today,
      isEmpty,
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(320, 640), const Size(1280, 800)]) {
      testWidgets(
        '${mode.name} $size: fixed preview, explicit building selection and floating information',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 1.6;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await openMap(tester, mode);
          expect(find.byType(Dialog), findsNothing);
          expect(find.byType(DraggableScrollableSheet), findsNothing);
          final preview = tester.widget<InteractiveViewer>(
            find.byType(InteractiveViewer),
          );
          expect(preview.panEnabled, isFalse);
          expect(preview.scaleEnabled, isFalse);
          final pageScroll = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          await tester.drag(
            find.byKey(const ValueKey('map-preview')),
            const Offset(0, -80),
          );
          await settleCampus(tester);
          expect(
            pageScroll.position.pixels,
            greaterThan(0),
            reason: 'Dragging the fixed preview must scroll the page',
          );
          pageScroll.position.jumpTo(0);
          await settleCampus(tester);
          expect(
            tester.getSize(find.byKey(const ValueKey('map-preview'))).height,
            160,
          );
          await tester.tap(find.byTooltip('Главный корпус'));
          await settleCampus(tester);
          expect(
            find.byKey(const ValueKey('building-info:main')),
            findsOneWidget,
          );
          expect(
            find.text(StaticData.buildings.first.address!),
            findsOneWidget,
          );
          await tester.tap(find.byTooltip('Закрыть'));
          await settleCampus(tester);
          await tester.tap(find.byKey(const ValueKey('map-expand-button')));
          await settleCampus(tester);
          expect(
            find.byKey(const ValueKey('map-building-floating')),
            findsNothing,
          );
          final expanded = tester.widget<InteractiveViewer>(
            find.byType(InteractiveViewer).last,
          );
          expect(expanded.panEnabled, isTrue);
          expect(expanded.scaleEnabled, isTrue);
          await tester.tap(find.widgetWithText(FilledButton, 'Главный корпус'));
          await settleCampus(tester);
          expect(
            find.byKey(const ValueKey('map-building-floating')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('building-info:main')),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Корпус Б'));
          await settleCampus(tester);
          expect(
            find.byKey(const ValueKey('building-info:main')),
            findsNothing,
          );
          final blockB = StaticData.buildings.firstWhere(
            (b) => b.name == 'Корпус Б',
          );
          expect(
            find.byKey(ValueKey('building-info:${blockB.id}')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('map-expanded-close')));
          await settleCampus(tester);
          expect(find.byType(Dialog), findsNothing);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
    testWidgets(
      '${mode.name}: availability filter, room details and timetable navigation',
      (tester) async {
        final container = await openMap(tester, mode);
        await revealRoom(tester, 'room:main:214');
        final occupied = find.byKey(const ValueKey('room:main:214'));
        expect(
          find.descendant(
            of: occupied,
            matching: find.text('Сейчас идёт занятие'),
          ),
          findsOneWidget,
        );
        await tester.tap(occupied);
        await settleCampus(tester);
        expect(find.byKey(const ValueKey('map-room-info')), findsOneWidget);
        expect(find.text('Этаж 2, налево от лестницы'), findsOneWidget);
        final infoScroll = find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.text('Подробнее о занятии'),
          200,
          scrollable: infoScroll,
        );
        await tester.ensureVisible(find.text('Подробнее о занятии'));
        await settleCampus(tester);
        expect(find.text('Иванов И.И.'), findsOneWidget);
        await tester.tap(find.text('Подробнее о занятии'));
        await settleCampus(tester);
        expect(
          container
              .read(routerProvider)
              .routerDelegate
              .currentConfiguration
              .last
              .matchedLocation,
          '/lesson/l1',
        );
        expect(find.byType(Dialog), findsNothing);
        container.read(routerProvider).goNamed(Routes.map);
        await settleCampus(tester);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('map-free-filter')),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('map-free-filter')),
        );
        await settleCampus(tester);
        await tester.tap(find.byKey(const ValueKey('map-free-filter')));
        await settleCampus(tester);
        expect(find.byKey(const ValueKey('room:main:214')), findsNothing);
        expect(find.text('Свободна по расписанию'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('room dialog updates when the lesson ends without reopening', (
    tester,
  ) async {
    final times = StreamController<DateTime>();
    addTearDown(times.close);
    final container = await openMap(
      tester,
      ThemeMode.light,
      clock: times.stream,
    );
    times.add(DateTime(2026, 10, 12, 9, 30));
    await settleCampus(tester);
    container
        .read(routerProvider)
        .goNamed(
          Routes.map,
          queryParameters: {'building': 'main', 'room': '214'},
        );
    await settleCampus(tester);
    await revealRoom(tester, 'room:main:214');
    await tester.tap(find.byKey(const ValueKey('room:main:214')));
    await settleCampus(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('map-room-info')),
        matching: find.text('Сейчас идёт занятие'),
      ),
      findsOneWidget,
    );
    times.add(DateTime(2026, 10, 12, 10, 30));
    await settleCampus(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('map-room-info')),
        matching: find.text('Свободна по расписанию'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
