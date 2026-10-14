import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';
part 'teacher.g.dart';

@JsonSerializable(includeIfNull: false)
class Teacher {
  const Teacher({
    required this.id,
    required this.name,
    this.position,
    this.email,
    this.photoUrl,
    this.officeBuildingId,
    this.office,
    this.officeHours,
  });
  final String id, name;
  final String? position,
      email,
      photoUrl,
      officeBuildingId,
      office,
      officeHours;
  factory Teacher.fromJson(Map<String, Object?> json) {
    jsonString(json, 'id');
    jsonString(json, 'name');
    for (final key in [
      'position',
      'email',
      'photoUrl',
      'officeBuildingId',
      'office',
      'officeHours',
    ]) {
      jsonOptionalString(json, key);
    }
    final email = json['email'];
    if (email is String &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw const FormatException('Некорректный email преподавателя');
    }
    return _$TeacherFromJson(json);
  }
  Map<String, Object?> toJson() => _$TeacherToJson(this);
}
