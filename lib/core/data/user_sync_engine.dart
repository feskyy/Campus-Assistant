import 'dart:convert';

import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:campus_assistant/core/domain/user_sync_repository.dart';

class UserSyncEngine {
  UserSyncEngine({
    required this.uid,
    required this.repository,
    required this.store,
    required this.apply,
  });
  final String uid;
  final UserSyncRepository repository;
  final LocalStore store;
  final Future<void> Function(UserSnapshot) apply;
  bool _busy = false;
  String get _key => 'sync_pending:$uid';
  String get _localKey => 'sync_local:$uid';
  Future<void> enqueue(UserSnapshot snapshot) async {
    final raw = jsonEncode(snapshot.toJson());
    await store.write(_localKey, raw);
    await store.write(_key, raw);
  }

  Future<void> restore() async {
    final raw = store.read(_localKey) as String?;
    final snapshot = raw == null
        ? UserSnapshot(
            group: 'CS-221',
            favorites: {},
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          )
        : UserSnapshot.fromJson(
            (jsonDecode(raw) as Map).cast<String, Object?>(),
          );
    await apply(snapshot);
  }

  Future<bool> flush() async {
    if (_busy) {
      return false;
    }
    _busy = true;
    try {
      final raw = store.read(_key) as String?;
      final pending = raw == null || raw.isEmpty
          ? null
          : UserSnapshot.fromJson(
              (jsonDecode(raw) as Map).cast<String, Object?>(),
            );
      final snapshot = pending == null
          ? await repository.read(uid)
          : await repository.saveIfNewer(uid, pending);
      // Do not apply an older response over a newer local edit.
      if (store.read(_key) != raw) {
        return false;
      }
      if (snapshot != null) {
        await store.write(_localKey, jsonEncode(snapshot.toJson()));
        await apply(snapshot);
      }
      if (store.read(_key) != raw) {
        return false;
      }
      if (pending != null) {
        await store.write(_key, '');
      }
      return true;
    } catch (_) {
      // The durable pending snapshot is retained for the next attempt.
      return false;
    } finally {
      _busy = false;
    }
  }
}
