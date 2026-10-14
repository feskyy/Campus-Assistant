// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  credits: (json['credits'] as num?)?.toInt(),
  hoursPerWeek: (json['hoursPerWeek'] as num?)?.toInt(),
  assessment: json['assessment'] as String?,
  syllabus:
      (json['syllabus'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  materials:
      (json['materials'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  teacherId: json['teacherId'] as String?,
  coverUrl: json['coverUrl'] as String?,
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': ?instance.description,
  'assessment': ?instance.assessment,
  'teacherId': ?instance.teacherId,
  'coverUrl': ?instance.coverUrl,
  'credits': ?instance.credits,
  'hoursPerWeek': ?instance.hoursPerWeek,
  'syllabus': instance.syllabus,
  'materials': instance.materials,
};
