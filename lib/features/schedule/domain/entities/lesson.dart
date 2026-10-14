import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';
import 'package:campus_assistant/core/utils/date_format.dart';

part 'lesson.g.dart';

enum LessonType { lecture, practice, lab }

@JsonSerializable(includeIfNull: false)
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
    this.subjectId,
    this.subjectTitle,
    this.buildingId,
    this.teacherId,
    this.topic,
    this.notes,
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
  final String? subjectId, subjectTitle, buildingId, teacherId, topic, notes;

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
    for (final key in [
      'id',
      'subject',
      'teacher',
      'building',
      'room',
      'group',
    ]) {
      jsonString(json, key);
    }
    jsonInt(json, 'weekday', 1, 7);
    for (final key in [
      'subjectId',
      'subjectTitle',
      'buildingId',
      'teacherId',
      'topic',
      'notes',
    ]) {
      jsonOptionalString(json, key);
    }
    return _$LessonFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
