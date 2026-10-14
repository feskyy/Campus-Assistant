import 'package:campus_assistant/core/data/user_repository.dart';
import 'package:campus_assistant/core/data/notification_repository.dart';
import 'package:campus_assistant/core/domain/user_repository.dart';
import 'package:campus_assistant/core/domain/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => FirebaseUserRepository(),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirebaseNotificationRepository(),
);
