import 'package:campus_assistant/core/router/push_destination.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/di/firebase_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool get androidPushSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
final notificationServiceProvider = notificationRepositoryProvider;
final notificationMessagesProvider = StreamProvider<String>((ref) {
  if (!ref.watch(firebaseReadyProvider) ||
      ref.watch(authControllerProvider) != SessionMode.authenticated ||
      !androidPushSupported) {
    return const Stream.empty();
  }
  final uid = ref.watch(authUserIdProvider);
  final settings = ref.watch(appSettingsProvider);
  if (uid == null ||
      !settings.notificationsEnabled ||
      settings.notificationsOwner != uid) {
    return const Stream.empty();
  }
  return ref.watch(notificationRepositoryProvider).messages(uid);
});

final notificationRoutesProvider = StreamProvider<PushDestination>((ref) {
  if (!ref.watch(firebaseReadyProvider) ||
      ref.watch(authControllerProvider) != SessionMode.authenticated ||
      !androidPushSupported) {
    return const Stream.empty();
  }
  return ref
      .watch(notificationRepositoryProvider)
      .openedMessages()
      .map(PushDestination.fromData)
      .where((value) => value != null)
      .cast<PushDestination>();
});
