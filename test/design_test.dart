import 'image_test_support.dart';

import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/shared/widgets/ui/content.dart';
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
      final tokens = theme.extension<CampusTokens>()!;
      expect(theme.useMaterial3, isTrue);
      expect(
        [
          tokens.background,
          tokens.surface,
          tokens.surface2,
          tokens.border,
          tokens.text,
          tokens.secondary,
          tokens.accent,
          tokens.onAccent,
        ].map((color) => color.toARGB32()).toList(),
        theme.brightness == Brightness.light
            ? [
                0xFFF7F8FC,
                0xFFFFFFFF,
                0xFFEEF0F7,
                0xFFE5EAF2,
                0xFF172033,
                0xFF63738A,
                0xFF635BDB,
                0xFFFFFFFF,
              ]
            : [
                0xFF0B1020,
                0xFF141B2D,
                0xFF1B253A,
                0xFF2A3448,
                0xFFF8FAFC,
                0xFF94A3B8,
                0xFF8B7CFF,
                0xFF08142E,
              ],
      );

      expect(scheme.primary, tokens.accent);
      expect(scheme.surface, tokens.surface);
      expect(theme.scaffoldBackgroundColor, tokens.background);
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
      for (final pair in [
        (tokens.text, tokens.background),
        (tokens.text, tokens.surface2),
        (tokens.secondary, tokens.background),
        (tokens.secondary, tokens.surface),
        (scheme.onSurfaceVariant, tokens.surface2),
        (scheme.onSecondary, scheme.secondary),
        (tokens.readableSupportive, tokens.surface),
        (scheme.onError, scheme.error),
        (tokens.text, tokens.heroStart),
        (tokens.text, tokens.heroEnd),
        (tokens.accent, tokens.surface),
        (
          tokens.photoText,
          Color.alphaBlend(tokens.photoControl, tokens.photoText),
        ),
      ]) {
        expect(
          contrast(pair.$1, pair.$2),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.brightness}: ${pair.$1} on ${pair.$2}',
        );
      }
      final selectedChipText = WidgetStateProperty.resolveAs<TextStyle>(
        theme.chipTheme.labelStyle!,
        {WidgetState.selected},
      );
      expect(
        contrast(selectedChipText.color!, tokens.accent),
        greaterThanOrEqualTo(4.5),
      );
      expect(tokens.cardRadius, 24);
      expect(tokens.fieldRadius, 16);
      expect(tokens.pillRadius, 999);
      expect(
        [tokens.space4, tokens.space8, tokens.space16, tokens.space24],
        [4, 8, 16, 24],
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
      await settleCampus(tester);
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(authControllerProvider.notifier)
          .enterDemo();
      await settleCampus(tester);
      expect(tester.takeException(), isNull);
      for (final label in ['Расписание', 'Лента', 'Карта', 'Профиль']) {
        final destination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );
        await tester.tap(destination);
        await settleCampus(tester);
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
    await settleCampus(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Расписание'),
      ),
    );
    await settleCampus(tester);
    expect(find.text('Группа CS-221'), findsOneWidget);
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
    await settleCampus(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Профиль'),
      ),
    );
    await settleCampus(tester);
    await tester.scrollUntilVisible(
      find.text('Система'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Система'));
    await settleCampus(tester);
    await tester.tap(find.text('Тёмная').last);
    await settleCampus(tester);
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
    await settleCampus(tester);
    await tester.scrollUntilVisible(
      find.byTooltip('Источник данных'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byTooltip('Источник данных'));
    await settleCampus(tester);
    await tester.tap(find.byTooltip('Источник данных'));
    await settleCampus(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Понятно'));
    await settleCampus(tester);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Ближайшие события'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await settleCampus(tester);
    final section = find.ancestor(
      of: find.text('Ближайшие события'),
      matching: find.byType(SectionHeader),
    );
    await tester.tap(find.descendant(of: section, matching: find.text('Все')));
    await settleCampus(tester);
    final current = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(routerProvider).routeInformationProvider.value.uri;
    expect(current.path, '/feed');
    expect(current.queryParameters['tab'], 'events');
    await tester.scrollUntilVisible(
      find.text('Хакатон Mobile Dev Weekend'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settleCampus(tester);
    expect(find.text('Хакатон Mobile Dev Weekend'), findsOneWidget);
    expect(find.text('Открыта запись в студенческие клубы'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
