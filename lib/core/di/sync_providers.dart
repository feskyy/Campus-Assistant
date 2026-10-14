import 'auth_providers.dart';

import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/user_sync_engine.dart';
import 'package:campus_assistant/core/data/user_sync_repository.dart';
import 'package:campus_assistant/core/domain/user_sync_repository.dart';

import 'package:campus_assistant/core/di/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSyncRepositoryProvider = Provider<UserSyncRepository>(
  (ref) => FirestoreUserSyncRepository(),
);
final userSyncCoordinatorProvider = Provider<void>((ref) {
  if (ref.watch(authControllerProvider) != SessionMode.authenticated) {
    return;
  }
  final uid = ref.watch(authUserIdProvider);
  if (uid == null) {
    return;
  }
  var applying = false, disposed = false;
  final engine = UserSyncEngine(
    uid: uid,
    repository: ref.watch(userSyncRepositoryProvider),
    store: ref.watch(localStoreProvider),
    apply: (snapshot) async {
      if (disposed) {
        return;
      }
      applying = true;
      try {
        await ref.read(favoritesProvider.notifier).replace(snapshot.favorites);
        await ref
            .read(appSettingsProvider.notifier)
            .setSelectedGroup(snapshot.group);
      } finally {
        applying = false;
      }
    },
  );
  Future<void> queue() async {
    if (applying || disposed) {
      return;
    }
    final snapshot = UserSnapshot(
      group: ref.read(appSettingsProvider).selectedGroup,
      favorites: {...ref.read(favoritesProvider)},
      updatedAt: DateTime.now().toUtc(),
    );
    await engine.enqueue(snapshot);
    if (!disposed) {
      await engine.flush();
    }
  }

  ref.listen(favoritesProvider, (_, _) {
    unawaited(queue());
  });
  ref.listen(appSettingsProvider.select((value) => value.selectedGroup), (
    _,
    _,
  ) {
    unawaited(queue());
  });
  unawaited(engine.restore().then((_) => engine.flush()));
  final retry = Timer.periodic(const Duration(seconds: 10), (_) {
    unawaited(engine.restore().then((_) => engine.flush()));
  });
  ref.onDispose(() {
    disposed = true;
    retry.cancel();
  });
});
