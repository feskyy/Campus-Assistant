abstract interface class NotificationRepository {
  Future<void> setEnabled(String uid, bool enabled);
  Stream<String> messages(String uid);
  Stream<Map<String, Object?>> openedMessages();
}
