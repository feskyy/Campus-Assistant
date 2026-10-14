import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/features/tasks/data/local_task_repository.dart';
import 'package:campus_assistant/features/tasks/domain/personal_task.dart';
import 'package:campus_assistant/features/tasks/presentation/tasks_controller.dart';

import 'auth_providers.dart';
import 'storage_providers.dart';

final tasksOwnerProvider = Provider<String?>((ref) {
  final session = ref.watch(authControllerProvider);
  if (session == SessionMode.demo) return 'demo';
  if (session != SessionMode.authenticated) return null;
  final uid = ref.watch(authUserIdProvider);
  return uid == null ? null : 'user:$uid';
});
final taskRepositoryProvider = Provider<PersonalTaskRepository?>((ref) {
  final owner = ref.watch(tasksOwnerProvider);
  return owner == null
      ? null
      : LocalTaskRepository(store: ref.watch(localStoreProvider), owner: owner);
});
final taskIdProvider = Provider<String Function()>((ref) {
  var sequence = 0;
  return () => '${DateTime.now().microsecondsSinceEpoch}-${sequence++}';
});
final personalTasksProvider =
    AsyncNotifierProvider<PersonalTasksController, List<PersonalTask>>(
      PersonalTasksController.new,
      retry: (count, error) => null,
    );
