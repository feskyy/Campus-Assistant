// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
  id: json['id'] as String,
  name: json['name'] as String,
  position: json['position'] as String?,
  email: json['email'] as String?,
  photoUrl: json['photoUrl'] as String?,
  officeBuildingId: json['officeBuildingId'] as String?,
  office: json['office'] as String?,
  officeHours: json['officeHours'] as String?,
);

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'position': ?instance.position,
  'email': ?instance.email,
  'photoUrl': ?instance.photoUrl,
  'officeBuildingId': ?instance.officeBuildingId,
  'office': ?instance.office,
  'officeHours': ?instance.officeHours,
};
