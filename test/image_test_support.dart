import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_assistant/core/data/static_data.dart';

Future<void> settleCampus(WidgetTester tester) async {
  if (PaintingBinding.instance.imageCache.maximumSizeBytes <
      256 * 1024 * 1024) {
    final previous = PaintingBinding.instance.imageCache.maximumSizeBytes;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 256 * 1024 * 1024;
    addTearDown(
      () => PaintingBinding.instance.imageCache.maximumSizeBytes = previous,
    );
  }
  final elements = find.byType(Scaffold).evaluate();
  if (elements.isNotEmpty) {
    final context = elements.first;
    final paths = {
      ...StaticData.news.map((n) => n.imageUrl),
      ...StaticData.events.map((e) => e.coverUrl),
      ...StaticData.teachers.map((t) => t.photoUrl),
      ...StaticData.subjects.map((s) => s.coverUrl),
      ...StaticData.buildings.map((b) => b.photoUrl),
    }.whereType<String>();
    await tester.runAsync(() async {
      for (final path in paths) {
        await precacheImage(AssetImage(path), context);
      }
    });
  }
  await tester.pumpAndSettle();
}
