import 'package:campus_assistant/core/domain/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({this.authOverride, this.firestoreOverride});
  final FirebaseAuth? authOverride;
  final FirebaseFirestore? firestoreOverride;
  FirebaseAuth get auth => authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get firestore =>
      firestoreOverride ?? FirebaseFirestore.instance;
  @override
  UserProfile? get currentUser {
    final user = auth.currentUser;
    return user == null
        ? null
        : UserProfile(
            uid: user.uid,
            displayName: user.displayName,
            email: user.email,
          );
  }

  @override
  Stream<String?> watchName(String uid) => firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => snapshot.data()?['name'] as String?);
  @override
  Future<void> updateName(String uid, String name) async {
    if (auth.currentUser?.uid != uid) throw StateError('Профиль недоступен');
    await firestore.collection('users').doc(uid).set({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await auth.currentUser!.updateDisplayName(name);
  }
}
