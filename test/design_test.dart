import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/shared/widgets/section_header.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('both palettes keep readable body and secondary text', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final scheme = theme.colorScheme;
      double contrast(Color a, Color b) {
        final first = a.computeLuminance(), second = b.computeLuminance();
        return first > second
            ? (first + 0.05) / (second + 0.05)
            : (second + 0.05) / (first + 0.05);
      }

      expect(
        contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onSurfaceVariant, scheme.surfaceContainerLowest),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('${mode.name}: small screen, large text, all primary screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const CampusAssistantApp(),
        ),
      );
      await tester.pumpAndSettle();
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(authControllerProvider.notifier)
          .enterDemo();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['Расписание', 'Лента', 'Каталог', 'Настройки']) {
        final destination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );
        await tester.tap(destination);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$mode / $label');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('tablet uses rail and preserves navigation', (tester) async {
    tester.view.physicalSize = const Size(1100, 900);
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
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Расписание'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Учебная группа'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('theme selection updates and remains persisted', (tester) async {
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
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Настройки'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Системная'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Системная'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Тёмная').last);
    await tester.pumpAndSettle();
    expect(prefs.getString('theme_mode'), 'dark');
    expect(
      Theme.of(tester.element(find.text('Тема'))).brightness,
      Brightness.dark,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('source dialog closes and events shortcut opens events', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Источник данных'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byTooltip('Источник данных'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Ближайшие события'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    final section = find.ancestor(
      of: find.text('Ближайшие события'),
      matching: find.byType(SectionHeader),
    );
    await tester.tap(find.descendant(of: section, matching: find.text('Все')));
    await tester.pumpAndSettle();
    expect(find.text('Хакатон Mobile Dev Weekend'), findsOneWidget);
    expect(find.text('Открыта запись в студенческие клубы'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
