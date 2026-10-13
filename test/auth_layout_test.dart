import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/features/profile/presentation/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    for (final registration in [false, true]) {
      testWidgets('auth layout: dark=$dark registration=$registration', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [firebaseReadyProvider.overrideWithValue(true)],
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: const LoginScreen(),
            ),
          ),
        );
        if (registration) {
          final toggle = find.widgetWithText(TextButton, 'Регистрация');
          await tester.ensureVisible(toggle);
          await tester.pumpAndSettle();
          await tester.tap(toggle);
          await tester.pumpAndSettle();
        }
        final submit = find.widgetWithText(
          FilledButton,
          registration ? 'Создать аккаунт' : 'Войти',
        );
        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();
        // Invalid fields stop submission before any Firebase request.
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(find.text('Введите корректный email'), findsOneWidget);
        expect(find.text('Минимум 6 символов'), findsOneWidget);
        final fields = find.byType(TextFormField);
        for (var index = 1; index < fields.evaluate().length; index++) {
          expect(
            tester.getRect(fields.at(index)).top -
                tester.getRect(fields.at(index - 1)).bottom,
            greaterThanOrEqualTo(20),
          );
        }
        expect(find.text('Открыть демонстрацию'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
