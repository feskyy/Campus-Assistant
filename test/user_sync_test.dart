import 'dart:async';

import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:campus_assistant/core/domain/user_sync_repository.dart';
import 'package:campus_assistant/core/data/user_sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSyncRepository implements UserSyncRepository {
  UserSnapshot? remote;
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<UserSnapshot?> read(String uid) async => remote;
  @override
  Future<UserSnapshot> saveIfNewer(String uid, UserSnapshot snapshot) async {
    await gate?.future;
    if (fail) {
      throw StateError('offline');
    }
    if (remote == null || snapshot.updatedAt.isAfter(remote!.updatedAt)) {
      remote = snapshot;
    }
    return remote!;
  }
}

void main() {
  test('offline queue survives recreation, retries and resolves timestamp conflict', () async {
    final store = MemoryLocalStore(), repository = FakeSyncRepository();
    UserSnapshot? applied;
    final local = UserSnapshot(
      group: 'CS-221',
      favorites: {'news:n1'},
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final first = UserSyncEngine(
      uid: 'alice',
      repository: repository,
      store: store,
      apply: (value) async {
        applied = value;
      },
    );
    repository.fail = true;
    await first.enqueue(local);
    expect(await first.flush(), isFalse);
    expect(store.read('sync_pending:alice'), isNotEmpty);
    expect(store.read('sync_pending:bob'), isNull);
    repository.fail = false;
    final second = UserSyncEngine(
      uid: 'alice',
      repository: repository,
      store: store,
      apply: (value) async {
        applied = value;
      },
    );
    expect(await second.flush(), isTrue);
    expect(applied!.favorites, {'news:n1'});
    expect(repository.remote!.group, 'CS-221');
    repository.remote = UserSnapshot(
      group: 'OTHER',
      favorites: {'event:e1'},
      updatedAt: DateTime.utc(2026, 2, 1),
    );
    await second.enqueue(local);
    expect(await second.flush(), isTrue);
    expect(applied!.group, 'OTHER');
    expect(applied!.favorites, {'event:e1'});
    expect(store.read('sync_pending:alice'), '');
  });
  test('newer local edit survives an in-flight sync response and uid restore is isolated', () async {
    final store = MemoryLocalStore(), repository = FakeSyncRepository();
    UserSnapshot? applied;
    final engine = UserSyncEngine(
      uid: 'alice',
      repository: repository,
      store: store,
      apply: (value) async {
        applied = value;
      },
    );
    final first = UserSnapshot(
      group: 'FIRST',
      favorites: {'news:n1'},
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final second = UserSnapshot(
      group: 'SECOND',
      favorites: {'news:n2'},
      updatedAt: DateTime.utc(2026, 2, 1),
    );
    await engine.enqueue(first);
    repository.gate = Completer<void>();
    final inFlight = engine.flush();
    await Future<void>.delayed(Duration.zero);
    await engine.enqueue(second);
    repository.gate!.complete();
    expect(await inFlight, isFalse);
    expect(applied, isNull);
    repository.gate = null;
    expect(await engine.flush(), isTrue);
    expect(applied!.favorites, {'news:n2'});
    final bob = UserSyncEngine(
      uid: 'bob',
      repository: repository,
      store: store,
      apply: (value) async {
        applied = value;
      },
    );
    await bob.restore();
    expect(applied!.favorites, isEmpty);
    await engine.restore();
    expect(applied!.group, 'SECOND');
  });
}
