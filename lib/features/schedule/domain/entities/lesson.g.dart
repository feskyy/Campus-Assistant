// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: json['id'] as String,
  subject: json['subject'] as String,
  teacher: json['teacher'] as String,
  building: json['building'] as String,
  room: json['room'] as String,
  weekday: (json['weekday'] as num).toInt(),
  startMinutes: (json['startMinutes'] as num).toInt(),
  endMinutes: (json['endMinutes'] as num).toInt(),
  type:
      $enumDecodeNullable(_$LessonTypeEnumMap, json['type']) ??
      LessonType.lecture,
  group: json['group'] as String? ?? 'CS-221',
  subjectId: json['subjectId'] as String?,
  subjectTitle: json['subjectTitle'] as String?,
  buildingId: json['buildingId'] as String?,
  teacherId: json['teacherId'] as String?,
  topic: json['topic'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'subject': instance.subject,
  'teacher': instance.teacher,
  'building': instance.building,
  'room': instance.room,
  'weekday': instance.weekday,
  'startMinutes': instance.startMinutes,
  'endMinutes': instance.endMinutes,
  'type': _$LessonTypeEnumMap[instance.type]!,
  'group': instance.group,
  'subjectId': ?instance.subjectId,
  'subjectTitle': ?instance.subjectTitle,
  'buildingId': ?instance.buildingId,
  'teacherId': ?instance.teacherId,
  'topic': ?instance.topic,
  'notes': ?instance.notes,
};

const _$LessonTypeEnumMap = {
  LessonType.lecture: 'lecture',
  LessonType.practice: 'practice',
  LessonType.lab: 'lab',
};
