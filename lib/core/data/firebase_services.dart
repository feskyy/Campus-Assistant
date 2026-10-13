import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);
final firebaseErrorProvider = Provider<String?>((ref) => null);
Future<String?> initializeFirebase() async {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  if ([apiKey, appId, projectId, senderId].any((e) => e.isEmpty)) {
    return 'Firebase не настроен: укажите параметры проекта.';
  }
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        projectId: projectId,
        messagingSenderId: senderId,
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      ),
    );
    return null;
  } catch (_) {
    return 'Не удалось инициализировать Firebase. Проверьте конфигурацию платформы.';
  }
}

final authRepositoryProvider = Provider((ref) => FirebaseAuthRepository());

class FirebaseAuthRepository {
  FirebaseAuth get auth => FirebaseAuth.instance;
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String name, String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user!.updateDisplayName(name.trim());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(result.user!.uid)
        .set({'name': name.trim()}, SetOptions(merge: true));
  }

  Future<void>? _googleInitialization;
  Future<void> google() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await auth.signInWithPopup(provider);
    } else {
      _googleInitialization ??= GoogleSignIn.instance.initialize(
        clientId: const String.fromEnvironment('GOOGLE_CLIENT_ID').isEmpty
            ? null
            : const String.fromEnvironment('GOOGLE_CLIENT_ID'),
        serverClientId:
            const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID').isEmpty
            ? null
            : const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
      );
      await _googleInitialization;
      final account = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await auth.signInWithCredential(credential);
    }
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => auth.signOut();
}

String authError(Object error) {
  if (error is StateError) return error.message;
  if (error is FormatException) return error.message;
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Неверный email или пароль',
      'email-already-in-use' => 'Этот email уже зарегистрирован',
      'invalid-email' => 'Введите корректный email',
      'weak-password' => 'Пароль слишком слабый',
      'network-request-failed' => 'Нет соединения с сервером',
      'too-many-requests' => 'Слишком много попыток. Попробуйте позже',
      'operation-not-allowed' => 'Провайдер входа не включён в Firebase',
      _ => 'Не удалось выполнить действие: ${error.code}',
    };
  }
  return 'Не удалось выполнить действие. Проверьте соединение и настройки Firebase.';
}

final firebaseUserProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return Stream.value(null);
  return FirebaseAuth.instance.userChanges();
});
