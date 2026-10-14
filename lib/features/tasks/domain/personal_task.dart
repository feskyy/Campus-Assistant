class PersonalTask {
  const PersonalTask({
    required this.id,
    required this.title,
    this.notes = '',
    this.dueDate,
    this.completed = false,
  });
  final String id, title, notes;
  final DateTime? dueDate;
  final bool completed;
  PersonalTask copyWith({
    String? title,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? completed,
  }) => PersonalTask(
    id: id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
    completed: completed ?? this.completed,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'dueDate': dueDate?.toIso8601String(),
    'completed': completed,
  };
  factory PersonalTask.fromJson(Map<String, Object?> value) {
    final id = value['id'],
        title = value['title'],
        notes = value['notes'],
        completed = value['completed'],
        rawDate = value['dueDate'];
    if (id is! String ||
        id.isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        title.length > 120 ||
        notes is! String ||
        notes.length > 1000 ||
        completed is! bool) {
      throw const FormatException('Invalid personal task');
    }
    final date = rawDate is String ? DateTime.tryParse(rawDate) : null;
    if (rawDate != null &&
        (date == null || date.year < 1900 || date.year > 2200)) {
      throw const FormatException('Invalid task date');
    }
    return PersonalTask(
      id: id,
      title: title,
      notes: notes,
      dueDate: date,
      completed: completed,
    );
  }
}

abstract interface class PersonalTaskRepository {
  List<PersonalTask> read();
  Future<void> save(List<PersonalTask> tasks);
}
