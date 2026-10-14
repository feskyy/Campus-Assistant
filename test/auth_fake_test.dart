import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/domain/auth_repository.dart';
import 'package:campus_assistant/features/profile/presentation/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  final List<List<String>> calls = [];
  bool fail = false;
  @override
  Future<void> signIn(String email, String password) async {
    calls.add(['login', email, password]);
    if (fail) {
      throw StateError('Ошибка тестового входа');
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    calls.add(['register', name, email, password]);
  }

  @override
  Future<void> google() async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async {}
}

void main() {
  for (final registration in [false, true]) {
    testWidgets('auth fake submission registration=$registration', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseReadyProvider.overrideWithValue(true),
            authRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      if (registration) {
        await tester.tap(find.widgetWithText(TextButton, 'Регистрация'));
        await tester.pumpAndSettle();
      }
      final fields = find.byType(TextFormField);
      final submit = find.widgetWithText(
        FilledButton,
        registration ? 'Создать аккаунт' : 'Войти',
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(repository.calls, isEmpty);
      if (registration) {
        await tester.enterText(fields.at(0), 'Студент');
      }
      await tester.enterText(
        fields.at(registration ? 1 : 0),
        'student@example.test',
      );
      await tester.enterText(fields.at(registration ? 2 : 1), 'secret1');
      if (registration) {
        await tester.enterText(fields.at(3), 'different');
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(find.text('Пароли не совпадают'), findsOneWidget);
        expect(repository.calls, isEmpty);
        await tester.enterText(fields.at(3), 'secret1');
      }
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(repository.calls, [
        registration
            ? ['register', 'Студент', 'student@example.test', 'secret1']
            : ['login', 'student@example.test', 'secret1'],
      ]);
      if (!registration) {
        repository.fail = true;
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(find.text('Ошибка тестового входа'), findsOneWidget);
        expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
      }
    });
  }
}
