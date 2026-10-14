import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart';

class ControlledCampus extends CampusController {
  ControlledCampus(this.result);
  final Completer<CampusData> result;
  @override
  Future<CampusData> build() => result.future;
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('${theme.brightness} card skeleton and styled error', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final result = Completer<CampusData>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campusDataProvider.overrideWith(() => ControlledCampus(result)),
          ],
          child: MaterialApp(
            theme: theme,
            home: Scaffold(body: DataView(builder: (_) => const SizedBox())),
          ),
        ),
      );
      expect(find.byType(CampusCard), findsNWidgets(3));
      result.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
