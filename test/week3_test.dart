import 'package:campus_assistant/learning/week3/favorite_demos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in <String, Widget>{
    'setState': const SetStateFavoriteDemo(),
    'InheritedWidget': const InheritedFavoriteDemo(),
    'Provider': const ProviderFavoriteDemo(),
  }.entries) {
    testWidgets('${entry.key}: favorite can be added and removed', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: entry.value)));
      await tester.tap(find.text('Добавить в избранное'));
      await tester.pump();
      expect(find.text('В избранном'), findsOneWidget);
      await tester.tap(find.text('В избранном'));
      await tester.pump();
      expect(find.text('Добавить в избранное'), findsOneWidget);
    });
  }
}
