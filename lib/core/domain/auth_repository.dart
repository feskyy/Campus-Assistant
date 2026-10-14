abstract interface class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> google();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}
