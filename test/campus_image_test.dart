import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/shared/widgets/ui/campus_image.dart';

class ControlledImageCache extends BaseCacheManager {
  final response = Completer<FileResponse>();
  int requests = 0;
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    requests++;
    return response.future.asStream();
  }

  @override
  Future<void> removeFile(String key) async {}
  // A strict fake: unexpected cache API calls fail instead of silently passing.
  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected cache operation: ${invocation.memberName}');
}

Widget host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);
void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final state in ['loading', 'error', 'loaded']) {
      testWidgets('CampusImage cached ${theme.brightness} $state', (
        tester,
      ) async {
        final cache = ControlledImageCache();
        final url =
            'https://images.example.invalid/${theme.brightness.name}-$state.png';
        await tester.pumpWidget(
          host(
            theme,
            CampusImage(
              source: url,
              kind: CampusImageKind.news,
              cacheManager: cache,
              heroTag: 'news:preview',
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(CachedNetworkImage), findsOneWidget);
        expect(
          find.byKey(const ValueKey('campus-image-loading')),
          findsOneWidget,
        );
        expect(cache.requests, 1);
        if (state == 'error') {
          cache.response.completeError(StateError('offline'));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('campus-image-error')),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.article_rounded), findsOneWidget);
          expect(
            find.byKey(const ValueKey('campus-image-loading')),
            findsNothing,
          );
        } else if (state == 'loaded') {
          final bytes = await tester.runAsync(
            () => rootBundle.load('assets/images/news/clubs.png'),
          );
          final file = MemoryFileSystem().file('/cover.png')
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
          cache.response.complete(
            FileInfo(file, FileSource.Cache, DateTime(2030), url),
          );
          await tester.pump();
          await tester.runAsync(
            () => precacheImage(
              CachedNetworkImageProvider(url, cacheManager: cache),
              tester.element(find.byType(CampusImage)),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('campus-image-loading')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('campus-image-error')),
            findsNothing,
          );
          expect(
            tester.widget<RawImage>(find.byType(RawImage)).image,
            isNotNull,
          );
        } else {
          await tester.pump(const Duration(milliseconds: 700));
          expect(
            find.byKey(const ValueKey('campus-image-loading')),
            findsOneWidget,
          );
        }
        expect(tester.widget<Hero>(find.byType(Hero)).tag, 'news:preview');
        expect(
          tester
              .widget<ColoredBox>(
                find.byKey(const ValueKey('campus-image-dim')),
              )
              .color
              .a,
          closeTo(theme.brightness == Brightness.dark ? .10 : 0, .001),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets(
    'CampusImage loads bundled asset and resolves all missing-source types',
    (tester) async {
      await tester.pumpWidget(
        host(
          AppTheme.light,
          const CampusImage(
            source: 'assets/images/teachers/ivanov.png',
            kind: CampusImageKind.teacher,
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/teachers/ivanov.png'),
          tester.element(find.byType(CampusImage)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
      expect(
        tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
        1,
      );
      final icons = [
        Icons.article_rounded,
        Icons.event_rounded,
        Icons.apartment_rounded,
        Icons.person_rounded,
        Icons.menu_book_rounded,
      ];
      for (var i = 0; i < CampusImageKind.values.length; i++) {
        await tester.pumpWidget(
          host(
            AppTheme.dark,
            CampusImage(source: null, kind: CampusImageKind.values[i]),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(icons[i]), findsOneWidget);
        expect(
          find.byKey(const ValueKey('campus-image-error')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('broken asset becomes an illustration without an exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppTheme.light,
        const CampusImage(
          source: 'assets/images/missing.png',
          kind: CampusImageKind.building,
        ),
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/missing.png'),
        tester.element(find.byType(CampusImage)),
        onError: (_, _) {},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
