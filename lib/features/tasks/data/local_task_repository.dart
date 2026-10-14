import 'dart:convert';

import 'package:campus_assistant/core/domain/local_store.dart';

import '../domain/personal_task.dart';

class LocalTaskRepository implements PersonalTaskRepository {
  LocalTaskRepository({required this.store, required String owner})
    : key = 'personal_tasks_v1:$owner';
  final LocalStore store;
  final String key;
  @override
  List<PersonalTask> read() {
    final raw = store.read(key);
    if (raw == null) return [];
    if (raw is! String) throw const FormatException('Invalid task storage');
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid task list');
    return decoded.map((Object? item) {
      if (item is! Map) throw const FormatException('Invalid task record');
      return PersonalTask.fromJson(item.cast<String, Object?>());
    }).toList();
  }

  @override
  Future<void> save(List<PersonalTask> tasks) =>
      store.write(key, jsonEncode(tasks.map((task) => task.toJson()).toList()));
}
