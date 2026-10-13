import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool get androidPushSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  Future<void> setEnabled(String uid, bool enabled) async {
    final messaging = FirebaseMessaging.instance;
    final devices = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices');
    if (enabled) {
      final permission = await messaging.requestPermission();
      if (permission.authorizationStatus != AuthorizationStatus.authorized) {
        throw StateError('Разрешение на уведомления не получено');
      }
      await messaging.setAutoInitEnabled(true);
      final token = await messaging.getToken();
      if (token == null) throw StateError('Токен уведомлений недоступен');
      await devices.doc(token).set({'token': token});
    } else {
      await messaging.setAutoInitEnabled(false);
      final token = await messaging.getToken();
      if (token != null) await devices.doc(token).delete();
      await messaging.deleteToken();
    }
  }
}

final notificationMessagesProvider = StreamProvider<String>((ref) {
  if (!ref.watch(firebaseReadyProvider) ||
      ref.watch(authControllerProvider) != SessionMode.authenticated ||
      !androidPushSupported) {
    return const Stream.empty();
  }
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final settings = ref.watch(appSettingsProvider);
  if (!settings.notificationsEnabled || settings.notificationsOwner != uid) {
    return const Stream.empty();
  }
  final messages = StreamController<String>();
  Future<void> saveToken(String token) async {
    if (FirebaseAuth.instance.currentUser?.uid != uid) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(token)
          .set({'token': token});
    } catch (_) {
      if (!messages.isClosed) {
        messages.add('Не удалось обновить регистрацию уведомлений');
      }
    }
  }

  final tokens = FirebaseMessaging.instance.onTokenRefresh.listen(
    saveToken,
    onError: (_) {
      if (!messages.isClosed) {
        messages.add('Не удалось обновить токен уведомлений');
      }
    },
  );
  final foreground = FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification != null && !messages.isClosed) {
      messages.add(
        [notification.title, notification.body].whereType<String>().join('\n'),
      );
    }
  });
  unawaited(
    FirebaseMessaging.instance
        .getToken()
        .then((token) async {
          if (token != null && !messages.isClosed) await saveToken(token);
        })
        .catchError((Object error) {
          if (!messages.isClosed) {
            messages.add('Не удалось подключить уведомления');
          }
        }),
  );
  ref.onDispose(() {
    unawaited(tokens.cancel());
    unawaited(foreground.cancel());
    unawaited(messages.close());
  });
  return messages.stream;
});
