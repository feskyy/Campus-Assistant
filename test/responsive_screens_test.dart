import 'package:campus_assistant/core/data/static_data.dart';

import 'image_test_support.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/main.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [
      const Size(360, 640),
      const Size(411, 891),
      const Size(800, 1280),
      const Size(1280, 800),
    ]) {
      testWidgets('${mode.name} $size primary screens text 1.5', (
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
        expect(find.byType(HeroBanner), findsOneWidget);
        final homeScroll = find.byType(Scrollable).first;
        for (var i = 0; i < 5; i++) {
          await tester.drag(homeScroll, const Offset(0, -500));
          await settleCampus(tester);
          expect(tester.takeException(), isNull);
        }
        final labels = ['schedule', 'feed', 'profile'];
        final navigation = size.width >= 840
            ? find.byType(NavigationRail)
            : find.byType(NavigationBar);
        for (final index in [1, 2, 4]) {
          final destinations = size.width >= 840
              ? find.descendant(of: navigation, matching: find.byType(InkWell))
              : find.descendant(
                  of: navigation,
                  matching: find.byType(NavigationDestination),
                );
          if (size.width >= 840) {
            await tester.tap(
              find.descendant(
                of: navigation,
                matching: find.byIcon(
                  [
                    Icons.home_rounded,
                    Icons.calendar_today_rounded,
                    Icons.article_rounded,
                    Icons.near_me_rounded,
                    Icons.person_outline_rounded,
                  ][index],
                ),
              ),
            );
          } else {
            await tester.tap(destinations.at(index));
          }
          await settleCampus(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: labels[[1, 2, 4].indexOf(index)],
          );
          if (index == 2) {
            await tester.scrollUntilVisible(
              find.byWidgetPredicate(
                (widget) =>
                    widget is ListingCard &&
                    widget.title == StaticData.news.first.title,
              ),
              250,
              scrollable: find.byType(Scrollable).first,
            );
            await settleCampus(tester);
            final cards = find.byType(ListingCard);
            expect(cards, findsWidgets);
            if (size.width >= 840) {
              expect(
                tester.getTopLeft(cards.at(0)).dy,
                tester.getTopLeft(cards.at(1)).dy,
              );
              expect(
                tester.getTopLeft(cards.at(1)).dx,
                greaterThan(tester.getTopLeft(cards.at(0)).dx),
              );
            }
          }
          final scrolls = find.byType(Scrollable);
          if (scrolls.evaluate().isNotEmpty) {
            for (var i = 0; i < 8; i++) {
              await tester.drag(scrolls.first, const Offset(0, -500));
              await settleCampus(tester);
              expect(tester.takeException(), isNull);
            }
            await settleCampus(tester);
            expect(tester.takeException(), isNull);
          }
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
