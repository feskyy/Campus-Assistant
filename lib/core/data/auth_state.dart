import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';

enum SessionMode { signedOut, demo, authenticated }

final authControllerProvider = NotifierProvider<AuthController, SessionMode>(
  AuthController.new,
);

class AuthController extends Notifier<SessionMode> {
  @override
  SessionMode build() {
    if (!ref.watch(firebaseReadyProvider)) return SessionMode.signedOut;
    final subscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      if (user != null) {
        state = SessionMode.authenticated;
      } else if (state != SessionMode.demo) {
        state = SessionMode.signedOut;
      }
    });
    ref.onDispose(subscription.cancel);
    return FirebaseAuth.instance.currentUser == null
        ? SessionMode.signedOut
        : SessionMode.authenticated;
  }

  void enterDemo() => state = SessionMode.demo;
  Future<void> signOut() async {
    if (ref.read(firebaseReadyProvider)) {
      await ref.read(authRepositoryProvider).signOut();
    }
    state = SessionMode.signedOut;
  }
}
