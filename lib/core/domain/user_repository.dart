class UserProfile {
  const UserProfile({required this.uid, this.displayName, this.email});
  final String uid;
  final String? displayName, email;
}

abstract interface class UserRepository {
  UserProfile? get currentUser;
  Stream<String?> watchName(String uid);
  Future<void> updateName(String uid, String name);
}
