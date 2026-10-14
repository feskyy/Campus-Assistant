import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/shared/widgets/ui/controls.dart';
import 'package:campus_assistant/main.dart';

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await settleCampus(tester);
}

void main() {
  testWidgets('registration remains usable above the keyboard at 320dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseReadyProvider.overrideWithValue(true)],
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Регистрация'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Регистрация'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(4));
    final submit = find.widgetWithText(FilledButton, 'Создать аккаунт');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(tester.getRect(submit).bottom, lessThanOrEqualTo(380));
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Введите корректный email'), findsOneWidget);
    expect(find.text('Пароли не совпадают'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      '${mode.name}: rendered filter labels retain contrast in both states',
      (tester) async {
        SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const CampusAssistantApp(),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(Scaffold).first),
        );
        container.read(authControllerProvider.notifier).enterDemo();
        container.read(routerProvider).goNamed(Routes.feed);
        await settleCampus(tester);
        final university = find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Университет'),
        );
        final t = CampusTokens.of(tester.element(university));
        expect(
          DefaultTextStyle.of(tester.element(university)).style.color,
          t.readableSecondary,
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('Все'))).style.color,
          t.onAccent,
        );
        await tester.tap(university);
        await settleCampus(tester);
        expect(
          DefaultTextStyle.of(tester.element(university)).style.color,
          t.onAccent,
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('Все'))).style.color,
          t.readableSecondary,
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
    testWidgets(
      '${mode.name}: editorial details at 320dp, large text and real actions',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
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
        final container = ProviderScope.containerOf(
          tester.element(find.byType(Scaffold).first),
        );
        container.read(authControllerProvider.notifier).enterDemo();
        await settleCampus(tester);
        final news = StaticData.news.first;
        container
            .read(routerProvider)
            .pushNamed(Routes.news, pathParameters: {'id': news.id});
        await settleCampus(tester);
        await reveal(tester, find.text('В избранное'));
        await tester.tap(find.text('В избранное'));
        await settleCampus(tester);
        expect(container.read(favoritesProvider), contains('news:${news.id}'));
        await tester.tap(find.text('Удалить из избранного'));
        await settleCampus(tester);
        expect(
          container.read(favoritesProvider),
          isNot(contains('news:${news.id}')),
        );
        for (final block in news.blocks.where((b) => b.text != null)) {
          await reveal(tester, find.text(block.text!));
          expect(find.text(block.text!), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await reveal(tester, find.text('Показать на карте'));
        await tester.tap(find.text('Показать на карте'));
        await settleCampus(tester);
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .queryParameters['building'],
          news.relatedBuildingId,
        );
        final event = StaticData.events.first;
        container
            .read(routerProvider)
            .pushNamed(Routes.event, pathParameters: {'id': event.id});
        await settleCampus(tester);
        await reveal(tester, find.text('О событии'));
        expect(find.text(event.description), findsOneWidget);
        expect(tester.takeException(), isNull);
        await reveal(tester, find.text('Показать на карте'));
        await tester.tap(find.text('Показать на карте'));
        await settleCampus(tester);
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .queryParameters['building'],
          event.buildingId,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('segmented selection respects reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SegmentedPill<bool>(
              options: const [
                SegmentOption(value: false, label: 'Новости'),
                SegmentOption(value: true, label: 'События'),
              ],
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    for (final element in find.byType(AnimatedContainer).evaluate()) {
      expect((element.widget as AnimatedContainer).duration, Duration.zero);
    }
    final context = tester.element(find.byType(SegmentedPill<bool>));
    expect(CampusTokens.of(context).motionDuration(context), Duration.zero);
  });
}
