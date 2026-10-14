import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/data/notifications.dart';
import 'package:campus_assistant/core/di/firebase_providers.dart';
import 'package:campus_assistant/core/domain/user_repository.dart';
import 'package:campus_assistant/core/domain/notification_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserRepository implements UserRepository {
  String name = 'Студент';
  @override
  UserProfile? get currentUser =>
      UserProfile(uid: 'alice', displayName: name, email: 'alice@example.test');
  @override
  Stream<String?> watchName(String uid) => Stream.value(name);
  @override
  Future<void> updateName(String uid, String value) async {
    name = value;
  }
}

class FakeNotificationRepository implements NotificationRepository {
  final controller = StreamController<String>.broadcast();
  final List<String> owners = [];
  bool enabled = false;
  @override
  Future<void> setEnabled(String uid, bool value) async {
    owners.add(uid);
    enabled = value;
  }

  @override
  Stream<String> messages(String uid) {
    owners.add(uid);
    return controller.stream;
  }

  @override
  Stream<Map<String, Object?>> openedMessages() =>
      Stream.value({'route': 'news', 'id': 'n1'});
}

class SignedInController extends AuthController {
  @override
  SessionMode build() => SessionMode.authenticated;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('fake user repository updates profile without Firebase', () async {
    final repository = FakeUserRepository();
    await repository.updateName('alice', 'Новое имя');
    expect(repository.currentUser!.displayName, 'Новое имя');
    expect(await repository.watchName('alice').first, 'Новое имя');
  });
  test('notification providers use fakes and enforce owner setting', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': true,
      'notifications_owner': 'alice',
    });
    final prefs = await SharedPreferences.getInstance();
    final repository = FakeNotificationRepository();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseReadyProvider.overrideWithValue(true),
        authUserIdProvider.overrideWithValue('alice'),
        authControllerProvider.overrideWith(SignedInController.new),
        userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final subscription = container.listen(
      notificationMessagesProvider,
      (_, _) {},
    );
    await Future<void>.delayed(Duration.zero);
    repository.controller.add('Тестовое уведомление');
    expect(
      await container.read(notificationMessagesProvider.future),
      'Тестовое уведомление',
    );
    final routeSubscription = container.listen(
      notificationRoutesProvider,
      (_, _) {},
    );
    expect(
      (await container.read(notificationRoutesProvider.future)).pathParameters,
      {'id': 'n1'},
    );
    await container
        .read(notificationServiceProvider)
        .setEnabled('alice', false);
    expect(repository.enabled, isFalse);
    expect(repository.owners.toSet(), {'alice'});
    routeSubscription.close();
    subscription.close();
    container.dispose();
    await repository.controller.close();
  });
}
