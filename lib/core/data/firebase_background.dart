import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initializeFirebase(registerMessagingHandler: false);
  // Notification payloads are displayed by Android. Navigation is performed
  // only by the foreground isolate when the user opens the notification.
}
