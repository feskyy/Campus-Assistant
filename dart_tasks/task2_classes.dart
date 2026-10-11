// ignore_for_file: avoid_print

/// Задача 2. Классы, enum, getters, copyWith.
enum LessonType { lecture, practice, lab }

class Lesson {
  const Lesson({
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startMinutes,
    required this.endMinutes,
    this.type = LessonType.lecture,
  });

  final String subject;
  final String teacher;
  final String room;
  final int startMinutes; // минуты от полуночи
  final int endMinutes;
  final LessonType type;

  int get durationMinutes => endMinutes - startMinutes;

  String get timeRange => '${_format(startMinutes)}–${_format(endMinutes)}';

  bool overlapsWith(Lesson other) =>
      startMinutes < other.endMinutes && other.startMinutes < endMinutes;

  Lesson copyWith({String? room}) {
    return Lesson(
      subject: subject,
      teacher: teacher,
      room: room ?? this.room,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      type: type,
    );
  }

  static String _format(int minutes) {
    final String h = (minutes ~/ 60).toString().padLeft(2, '0');
    final String m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  String toString() =>
      '$timeRange  $subject (${type.name}) — ауд. $room, $teacher';
}

void main() {
  const math = Lesson(
    subject: 'Математика',
    teacher: 'Иванов И.И.',
    room: '214',
    startMinutes: 9 * 60,
    endMinutes: 10 * 60 + 30,
  );
  const physics = Lesson(
    subject: 'Физика',
    teacher: 'Петров П.П.',
    room: '305',
    startMinutes: 10 * 60,
    endMinutes: 11 * 60 + 30,
    type: LessonType.lab,
  );

  print(math);
  print(physics);
  print('Длительность: ${math.durationMinutes} мин'); // 90
  print('Пересекаются: ${math.overlapsWith(physics)}'); // true
  print(math.copyWith(room: '101'));
}
