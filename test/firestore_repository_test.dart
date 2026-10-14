import 'package:campus_assistant/core/data/user_sync_repository.dart';
import 'package:campus_assistant/core/domain/user_sync_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Firestore repository saves group/favorites and rejects older snapshot',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = FirestoreUserSyncRepository(
        firestoreOverride: firestore,
      );
      final first = UserSnapshot(
        group: 'CS-221',
        favorites: {'news:n1', 'event:e1'},
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await repository.saveIfNewer('alice', first);
      expect((await repository.read('alice'))!.favorites, first.favorites);
      final document = await firestore
          .collection('users')
          .doc('alice')
          .collection('favorites')
          .doc('news_n1')
          .get();
      expect(document.data()!.keys.toSet(), {'kind', 'itemId', 'createdAt'});
      final second = UserSnapshot(
        group: 'OTHER',
        favorites: {'event:e1'},
        updatedAt: DateTime.utc(2026, 2, 1),
      );
      await repository.saveIfNewer('alice', second);
      expect((await repository.read('alice'))!.group, 'OTHER');
      expect((await repository.read('alice'))!.favorites, {'event:e1'});
      expect((await repository.saveIfNewer('alice', first)).group, 'OTHER');
      expect(await repository.read('bob'), isNull);
    },
  );
}
