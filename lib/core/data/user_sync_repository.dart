import 'package:campus_assistant/core/domain/user_sync_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserSyncRepository implements UserSyncRepository {
  FirestoreUserSyncRepository({this.firestoreOverride});
  final FirebaseFirestore? firestoreOverride;
  FirebaseFirestore get firestore =>
      firestoreOverride ?? FirebaseFirestore.instance;
  @override
  Future<UserSnapshot?> read(String uid) async {
    final user = await firestore.collection('users').doc(uid).get();
    final data = user.data();
    if (data == null ||
        data['group'] == null ||
        data['updatedAt'] is! Timestamp) {
      return null;
    }
    final favorites = await user.reference.collection('favorites').get();
    final verified = await user.reference.get();
    if (verified.data()?['updatedAt'] != data['updatedAt']) {
      throw StateError('Профиль изменился: требуется повтор чтения');
    }
    return UserSnapshot(
      group: data['group'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      favorites: favorites.docs
          .map((doc) => '${doc.data()['kind']}:${doc.data()['itemId']}')
          .toSet(),
    );
  }

  @override
  Future<UserSnapshot> saveIfNewer(String uid, UserSnapshot snapshot) async {
    final user = firestore.collection('users').doc(uid);
    final baseline = await user.get();
    final baselineTimestamp = baseline.data()?['updatedAt'];
    final existing = await user.collection('favorites').get();
    final createdAtByKey = {
      for (final doc in existing.docs)
        '${doc.data()['kind']}:${doc.data()['itemId']}': doc
            .data()['createdAt'],
    };
    final saved = await firestore.runTransaction<bool>((transaction) async {
      final document = await transaction.get(user);
      final updatedAt = document.data()?['updatedAt'];
      if (updatedAt != baselineTimestamp) {
        throw StateError('Профиль изменился: требуется повтор синхронизации');
      }
      if (updatedAt is Timestamp &&
          !snapshot.updatedAt.isAfter(updatedAt.toDate())) {
        return false;
      }
      transaction.set(user, {
        'group': snapshot.group,
        'updatedAt': Timestamp.fromDate(snapshot.updatedAt),
      }, SetOptions(merge: true));
      for (final favorite in existing.docs) {
        final key = '${favorite.data()['kind']}:${favorite.data()['itemId']}';
        if (!snapshot.favorites.contains(key)) {
          transaction.delete(favorite.reference);
        }
      }
      for (final key in snapshot.favorites) {
        final separator = key.indexOf(':');
        final kind = key.substring(0, separator),
            id = key.substring(separator + 1);
        final documentId = '${kind}_${Uri.encodeComponent(id)}';
        transaction.set(user.collection('favorites').doc(documentId), {
          'kind': kind,
          'itemId': id,
          'createdAt':
              createdAtByKey[key] ?? Timestamp.fromDate(snapshot.updatedAt),
        });
      }
      return true;
    });
    return saved ? snapshot : (await read(uid) ?? snapshot);
  }
}
