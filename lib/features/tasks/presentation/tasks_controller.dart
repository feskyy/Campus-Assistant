import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/core/di/task_providers.dart';

import '../domain/personal_task.dart';

class PersonalTasksController extends AsyncNotifier<List<PersonalTask>> {
  Future<void> _pending = Future.value();
  @override
  Future<List<PersonalTask>> build() async =>
      ref.watch(taskRepositoryProvider)?.read() ?? [];

  Future<void> _change(List<PersonalTask> Function(List<PersonalTask>) change) {
    final repository = ref.read(taskRepositoryProvider),
        owner = ref.read(tasksOwnerProvider);
    if (repository == null) {
      return Future.error(StateError('Task owner unavailable'));
    }
    final operation = _pending.then((_) async {
      if (!ref.mounted || ref.read(tasksOwnerProvider) != owner) {
        throw StateError('Task owner changed');
      }
      final current = state;
      if (current.hasError) {
        Error.throwWithStackTrace(
          current.error!,
          current.stackTrace ?? StackTrace.current,
        );
      }
      final previous = current.isLoading ? await future : current.requireValue;
      if (!ref.mounted || ref.read(tasksOwnerProvider) != owner) {
        throw StateError('Task owner changed');
      }
      final next = change(previous);
      await repository.save(next);
      if (ref.mounted && ref.read(tasksOwnerProvider) == owner) {
        state = AsyncData(next);
      }
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> saveTask({
    String? id,
    required String title,
    String notes = '',
    DateTime? dueDate,
  }) {
    final name = title.trim(), description = notes.trim();
    if (name.isEmpty || name.length > 120 || description.length > 1000) {
      return Future.error(ArgumentError('Invalid task'));
    }
    final taskId = id ?? ref.read(taskIdProvider)();
    return _change((tasks) {
      if (id == null) {
        return [
          ...tasks,
          PersonalTask(
            id: taskId,
            title: name,
            notes: description,
            dueDate: dueDate,
          ),
        ];
      }
      if (!tasks.any((task) => task.id == id)) {
        throw StateError('Task no longer exists');
      }
      return [
        for (final task in tasks)
          if (task.id == id)
            task.copyWith(
              title: name,
              notes: description,
              dueDate: dueDate,
              clearDueDate: dueDate == null,
            )
          else
            task,
      ];
    });
  }

  Future<void> setCompleted(String id, bool completed) => _change(
    (tasks) => [
      for (final task in tasks)
        task.id == id ? task.copyWith(completed: completed) : task,
    ],
  );
  Future<void> delete(String id) =>
      _change((tasks) => tasks.where((task) => task.id != id).toList());
}
