import 'package:campus_assistant/core/utils/json_validation.dart';
import 'package:campus_assistant/core/utils/date_format.dart';

enum LessonType { lecture, practice, lab }

class Lesson {
  const Lesson({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.building,
    required this.room,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    this.type = LessonType.lecture,
    this.group = 'CS-221',
  });

  final String id;
  final String subject;
  final String teacher;
  final String building;
  final String room;

  /// 1 = понедельник ... 7 = воскресенье (как в DateTime.weekday).
  final int weekday;

  /// Время в минутах от полуночи.
  final int startMinutes;
  final int endMinutes;
  final LessonType type;
  final String group;

  String get startTime => formatMinutes(startMinutes);
  String get endTime => formatMinutes(endMinutes);

  String get typeLabel => switch (type) {
    LessonType.lecture => 'Лекция',
    LessonType.practice => 'Практика',
    LessonType.lab => 'Лабораторная',
  };

  factory Lesson.fromJson(Map<String, dynamic> json) {
    if (jsonInt(json, 'endMinutes', 1, 1440) <=
        jsonInt(json, 'startMinutes', 0, 1439)) {
      throw const FormatException('End time must follow start time');
    }
    if (!['lecture', 'practice', 'lab'].contains(json['type'])) {
      throw const FormatException('Invalid lesson type');
    }
    return Lesson(
      id: jsonString(json, 'id'),
      subject: jsonString(json, 'subject'),
      teacher: jsonString(json, 'teacher'),
      building: jsonString(json, 'building'),
      room: jsonString(json, 'room'),
      weekday: jsonInt(json, 'weekday', 1, 7),
      startMinutes: jsonInt(json, 'startMinutes', 0, 1439),
      endMinutes: jsonInt(json, 'endMinutes', 1, 1440),
      type: _lessonTypeFromString(json['type'] as String? ?? 'lecture'),
      group: jsonString(json, 'group'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'building': building,
      'room': room,
      'weekday': weekday,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'type': type.name,
      'group': group,
    };
  }

  static LessonType _lessonTypeFromString(String value) {
    switch (value) {
      case 'practice':
        return LessonType.practice;
      case 'lab':
        return LessonType.lab;
      case 'lecture':
      default:
        return LessonType.lecture;
    }
  }
}
