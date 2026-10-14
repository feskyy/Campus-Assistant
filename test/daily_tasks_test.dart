import 'dart:async';

import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/di/storage_providers.dart';
import 'package:campus_assistant/core/di/task_providers.dart';
import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/features/tasks/data/local_task_repository.dart';
import 'package:campus_assistant/features/tasks/domain/personal_task.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/main.dart';

Future<ProviderContainer> app(WidgetTester tester, ThemeMode theme) async {
  SharedPreferences.setMockInitialValues({'theme_mode': theme.name});
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
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  );
  container.read(authControllerProvider.notifier).enterDemo();
  await settleCampus(tester);
  return container;
}

class FailingStore extends MemoryLocalStore {
  bool fail = false;
  @override
  Future<void> write(String key, Object value) =>
      fail ? Future.error(StateError('disk full')) : super.write(key, value);
}

void main() {
  test('tasks survive controller recreation, serialize CRUD, and stay isolated by owner', () async {
    final store = MemoryLocalStore();
    final first = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        tasksOwnerProvider.overrideWithValue('user:a'),
      ],
    );
    addTearDown(first.dispose);
    await first.read(personalTasksProvider.future);
    final controller = first.read(personalTasksProvider.notifier);
    await Future.wait([
      controller.saveTask(
        title: '  Отчёт  ',
        notes: 'Черновик',
        dueDate: DateTime(2026, 10, 15),
      ),
      controller.saveTask(title: 'Прочитать главу'),
    ]);
    final tasks = await first.read(personalTasksProvider.future);
    expect(tasks, hasLength(2));
    expect(tasks.first.title, 'Отчёт');
    final id = tasks.first.id;
    await Future.wait([
      controller.setCompleted(id, true),
      controller.saveTask(id: id, title: 'Готовый отчёт', notes: 'Проверено'),
      controller.delete(tasks.last.id),
    ]);
    final restarted = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        tasksOwnerProvider.overrideWithValue('user:a'),
      ],
    );
    addTearDown(restarted.dispose);
    final restored = await restarted.read(personalTasksProvider.future);
    expect(restored.single.title, 'Готовый отчёт');
    expect(restored.single.completed, isTrue);
    expect(restored.single.notes, 'Проверено');
    expect(restored.single.dueDate, isNull);
    expect(LocalTaskRepository(store: store, owner: 'user:b').read(), isEmpty);
    expect(LocalTaskRepository(store: store, owner: 'demo').read(), isEmpty);
  });
  test(
    'failed writes leave both current state and persisted data unchanged',
    () async {
      final store = FailingStore();
      final container = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          tasksOwnerProvider.overrideWithValue('user:a'),
        ],
      );
      addTearDown(container.dispose);
      await container.read(personalTasksProvider.future);
      final controller = container.read(personalTasksProvider.notifier);
      await controller.saveTask(title: 'Сохранённая задача');
      store.fail = true;
      await expectLater(
        controller.saveTask(title: 'Не сохранена'),
        throwsStateError,
      );
      expect(
        (await container.read(personalTasksProvider.future)).single.title,
        'Сохранённая задача',
      );
      expect(
        LocalTaskRepository(store: store, owner: 'user:a').read().single.title,
        'Сохранённая задача',
      );
      store.fail = false;
      await controller.saveTask(title: 'Повторная попытка');
      expect(await container.read(personalTasksProvider.future), hasLength(2));
    },
  );
  test('invalid task input and corrupted storage are rejected without overwriting records', () async {
    final store = MemoryLocalStore();
    await store.write('personal_tasks_v1:user:a', 'broken');
    expect(
      () => LocalTaskRepository(store: store, owner: 'user:a').read(),
      throwsFormatException,
    );
    expect(
      () => PersonalTask.fromJson({
        'id': 'id',
        'title': ' ',
        'notes': '',
        'completed': false,
      }),
      throwsFormatException,
    );
    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        tasksOwnerProvider.overrideWithValue('user:a'),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(personalTasksProvider.future),
      throwsFormatException,
    );
    await expectLater(
      container.read(personalTasksProvider.notifier).saveTask(title: 'Новая'),
      throwsFormatException,
    );
    expect(store.read('personal_tasks_v1:user:a'), 'broken');
  });
  testWidgets(
    'schedule task date picker, day filtering, and narrow keyboard layout',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = await app(tester, ThemeMode.dark);
      container.read(routerProvider).goNamed(Routes.schedule);
      await settleCampus(tester);
      final strip = find.byKey(const ValueKey('schedule-week-strip'));
      await tester.tap(find.descendant(of: strip, matching: find.text('13')));
      await settleCampus(tester);
      await tester.tap(find.byTooltip('Новая задача'));
      await settleCampus(tester);
      final date = find.byKey(const ValueKey('task-date-button'));
      await tester.ensureVisible(date);
      await tester.tap(date);
      await settleCampus(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.text('15'),
        ),
      );
      await tester.tap(find.widgetWithText(TextButton, 'ОК'));
      await settleCampus(tester);
      await tester.enterText(
        find.byKey(const ValueKey('task-title-input')),
        'Подготовить доклад',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pump();
      final save = find.byKey(const ValueKey('task-save-button'));
      await tester.ensureVisible(save);
      await settleCampus(tester);
      expect(tester.getRect(save).bottom, lessThanOrEqualTo(360));
      await tester.tap(save);
      tester.view.resetViewInsets();
      await settleCampus(tester);
      expect(
        (await container.read(personalTasksProvider.future)).single.dueDate,
        DateTime(2026, 10, 15),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('add-day-task')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await settleCampus(tester);
      expect(find.text('Подготовить доклад'), findsNothing);
      await tester.scrollUntilVisible(
        strip,
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.descendant(of: strip, matching: find.text('15')),
      );
      await settleCampus(tester);
      await tester.tap(find.descendant(of: strip, matching: find.text('15')));
      await settleCampus(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('add-day-task')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await settleCampus(tester);
      expect(find.text('Подготовить доклад'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [
      const Size(320, 640),
      const Size(360, 800),
      const Size(667, 950),
      const Size(1280, 800),
    ]) {
      testWidgets(
        '${theme.name} $size alignment: full-width lessons and seven equal weekday cells at 1.6',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 1.6;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final container = await app(tester, theme);
          await tester.scrollUntilVisible(
            find.byType(LessonCard),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await settleCampus(tester);
          final lessonRect = tester.getRect(find.byType(LessonCard).first);
          expect(
            lessonRect.width,
            greaterThan(size.width < 840 ? size.width - 80 : 600),
          );
          container.read(routerProvider).goNamed(Routes.schedule);
          await settleCampus(tester);
          final strip = find.byKey(const ValueKey('schedule-week-strip'));
          expect(strip, findsOneWidget);
          final days = find.descendant(
            of: strip,
            matching: find.byType(AnimatedContainer),
          );
          expect(days, findsNWidgets(7));
          final first = tester.getRect(days.first),
              last = tester.getRect(days.last);
          expect(
            first.left - tester.getRect(strip).left,
            closeTo(tester.getRect(strip).right - last.right, .1),
          );
          for (final cell in days.evaluate()) {
            expect(
              tester.getSize(find.byWidget(cell.widget)).width,
              closeTo(first.width, .1),
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
    testWidgets(
      '${theme.name}: create, edit, complete, delete task through the UI',
      (tester) async {
        final container = await app(tester, theme);
        final add = find.byKey(const ValueKey('add-home-task'));
        await tester.scrollUntilVisible(
          add,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(add);
        await settleCampus(tester);
        await tester.tap(add);
        await settleCampus(tester);
        final save = find.byKey(const ValueKey('task-save-button'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        await settleCampus(tester);
        expect(find.text('Введите название задачи'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('task-title-input')),
          'Личный отчёт',
        );
        await tester.enterText(
          find.byKey(const ValueKey('task-notes-input')),
          'Проверить ссылки',
        );
        await tester.ensureVisible(save);
        await settleCampus(tester);
        await tester.tap(save);
        await settleCampus(tester);
        final task = (await container.read(personalTasksProvider.future))
            .single;
        expect(task.notes, 'Проверить ссылки');
        await tester.ensureVisible(find.text('Личный отчёт'));
        await settleCampus(tester);
        await tester.tap(find.text('Личный отчёт'));
        await settleCampus(tester);
        await tester.enterText(
          find.byKey(const ValueKey('task-title-input')),
          'Личный отчёт обновлён',
        );
        await tester.ensureVisible(save);
        await settleCampus(tester);
        await tester.tap(save);
        await settleCampus(tester);
        final row = find.byKey(ValueKey('task:${task.id}'));
        await tester.ensureVisible(row);
        await settleCampus(tester);
        await tester.tap(
          find.descendant(of: row, matching: find.byType(Checkbox)),
        );
        await settleCampus(tester);
        expect(
          (await container.read(personalTasksProvider.future)).single.completed,
          isTrue,
        );
        await tester.tap(
          find.byTooltip('Действия задачи: Личный отчёт обновлён'),
        );
        await settleCampus(tester);
        await tester.tap(find.text('Удалить'));
        await settleCampus(tester);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
        await settleCampus(tester);
        expect(await container.read(personalTasksProvider.future), isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
