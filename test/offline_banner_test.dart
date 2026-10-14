import 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cached data banner contains saved date', (tester) async {
    final data = CampusData(
      lessons: [],
      news: [],
      events: [],
      source: 'Сохранённые данные API',
      cachedAt: DateTime(2026, 10, 14, 10, 30),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SourceNotice(data: data)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Нет сети · данные от 2026-10-14'),
      findsOneWidget,
    );
  });
}
