import 'dart:async';

import 'package:campus_assistant/core/domain/notification_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  @override
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

  @override
  Stream<String> messages(String uid) {
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
          [
            notification.title,
            notification.body,
          ].whereType<String>().join('\n'),
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

    messages.onCancel = () async {
      await tokens.cancel();
      await foreground.cancel();
    };
    return messages.stream;
  }

  @override
  Stream<Map<String, Object?>> openedMessages() async* {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      yield initial.data.cast<String, Object?>();
    }
    yield* FirebaseMessaging.onMessageOpenedApp.map(
      (message) => message.data.cast<String, Object?>(),
    );
  }
}
