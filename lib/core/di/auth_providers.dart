import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final authUserIdProvider = Provider<String?>(
  (ref) => ref.watch(firebaseUserProvider).asData?.value?.uid,
);
