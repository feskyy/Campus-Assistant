import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/learning/design/design_showcase_screen.dart';
import 'package:campus_assistant/main.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets(
      '${theme.brightness}: every component fits 320dp at 1.5 text scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: DesignComponentGallery(),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/images/design_campus.jpg'),
            tester.element(find.byType(DesignComponentGallery)),
          ),
        );
        await tester.pumpAndSettle();
        for (final type in [
          ui.CampusCard,
          ui.CategoryChip,
          ui.SegmentedPill<bool>,
          ui.PillButton,
          ui.RoundIconButton,
          ui.PhotoBadge,
          ui.FloatingMapPill,
          ui.HeroBanner,
          ui.StatTile,
          ui.StatRow,
          ui.SectionHeader,
          ui.ListingCard,
          ui.BottomSheetHandle,
          ui.EmptyState,
          ui.ErrorState,
          ui.CampusPhoto,
        ]) {
          expect(
            find.byType(type),
            findsWidgets,
            reason: '$type was not built',
          );
        }
        expect(find.byType(ui.StatRow), findsOneWidget);
        expect(
          tester.widget<ui.StatRow>(find.byType(ui.StatRow)).tiles.length,
          4,
        );
        final category = find.byType(ui.CategoryChip).first;
        final circularMaterial = find.descendant(
          of: category,
          matching: find.byType(Material),
        );
        expect(tester.getSize(circularMaterial), const Size(64, 64));
        final firstCard = find.byType(ui.CampusCard).first;
        final cardDecoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: firstCard,
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        final cardMaterial = tester.widget<Material>(
          find.descendant(of: firstCard, matching: find.byType(Material)).first,
        );
        final shape = cardMaterial.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(24));
        expect(
          cardDecoration.boxShadow!.isEmpty,
          theme.brightness == Brightness.dark,
        );
        expect(shape.side.width, theme.brightness == Brightness.dark ? 1 : 0);
        final overlays = tester.widgetList<ColoredBox>(
          find.byKey(const ValueKey('campus-photo-overlay')),
        );
        expect(overlays.length, 2);
        for (final overlay in overlays) {
          expect(
            overlay.color.a,
            closeTo(theme.brightness == Brightness.dark ? 0.10 : 0, 0.001),
          );
        }
        expect(find.byType(Image), findsNWidgets(2));
        final photos = tester.widgetList<RawImage>(find.byType(RawImage));
        expect(photos.length, 2);
        expect(
          photos.every((photo) => photo.image != null),
          isTrue,
          reason:
              'Local photograph must decode, not fall back to a placeholder',
        );
        for (final photo in find.byType(ui.CampusPhoto).evaluate()) {
          final size = tester.getSize(find.byWidget(photo.widget));
          expect(size.width / size.height, closeTo(16 / 10, 0.001));
        }
        expect(tester.takeException(), isNull);
        // Scroll every section into view as well, catching paint-time overflow.
        final scroll = find.byType(SingleChildScrollView);
        for (final type in [
          ui.SegmentedPill<bool>,
          ui.StatRow,
          ui.ListingCard,
          ui.ErrorState,
        ]) {
          await tester.scrollUntilVisible(
            find.byType(type),
            300,
            scrollable: find.descendant(
              of: scroll,
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$type at ${theme.brightness}',
          );
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('gallery controls change selected segment and favorite', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: DesignComponentGallery()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final categories = find.byType(ui.CategoryChip);
    await tester.tap(
      find.descendant(of: categories.at(1), matching: find.byType(InkWell)),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<ui.CategoryChip>(categories.at(1)).selected, isTrue);
    expect(tester.widget<ui.CategoryChip>(categories.first).selected, isFalse);
    final segment = find.byType(ui.SegmentedPill<bool>);
    await tester.ensureVisible(segment);
    await tester.tap(
      find.descendant(of: segment, matching: find.text('События')),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<ui.SegmentedPill<bool>>(segment).value, isTrue);
    final listing = find.byType(ui.ListingCard);
    final favorite = find.descendant(
      of: listing,
      matching: find.byType(ui.RoundIconButton),
    );
    await tester.ensureVisible(favorite);
    await tester.tap(favorite);
    await tester.pumpAndSettle();
    expect(tester.widget<ui.ListingCard>(listing).favorite, isTrue);
    await tester.tap(favorite);
    await tester.pumpAndSettle();
    expect(tester.widget<ui.ListingCard>(listing).favorite, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'settings information opens named design route with both themes',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authControllerProvider.notifier).enterDemo();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CampusAssistantApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).goNamed(Routes.profile);
      await tester.pumpAndSettle();
      final link = find.text('Витрина компонентов');
      await tester.scrollUntilVisible(
        link,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(DesignShowcaseScreen), findsOneWidget);
      expect(find.text('Светлая тема'), findsOneWidget);
      expect(find.text('Тёмная тема'), findsOneWidget);
      final galleries = find.byType(DesignComponentGallery);
      expect(galleries, findsNWidgets(2));
      expect(
        Theme.of(tester.element(galleries.first)).extension<CampusTokens>(),
        CampusTokens.light,
      );
      expect(
        Theme.of(tester.element(galleries.last)).extension<CampusTokens>(),
        CampusTokens.dark,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('840dp gallery compares both themes side by side', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(840, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DesignShowcaseScreen()),
    );
    await tester.pumpAndSettle();
    final galleries = find.byType(DesignComponentGallery);
    expect(galleries, findsNWidgets(2));
    expect(
      tester.getTopLeft(galleries.first).dy,
      tester.getTopLeft(galleries.last).dy,
    );
    expect(
      tester.getTopLeft(galleries.first).dx,
      lessThan(tester.getTopLeft(galleries.last).dx),
    );
    expect(tester.takeException(), isNull);
  });
}
