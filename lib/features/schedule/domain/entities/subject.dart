import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';
part 'subject.g.dart';

@JsonSerializable(includeIfNull: false)
class Subject {
  const Subject({
    required this.id,
    required this.title,
    this.description,
    this.credits,
    this.hoursPerWeek,
    this.assessment,
    this.syllabus = const [],
    this.materials = const [],
    this.teacherId,
    this.coverUrl,
  });
  final String id, title;
  final String? description, assessment, teacherId, coverUrl;
  final int? credits, hoursPerWeek;
  final List<String> syllabus, materials;
  factory Subject.fromJson(Map<String, Object?> json) {
    jsonString(json, 'id');
    jsonString(json, 'title');
    for (final key in ['description', 'assessment', 'teacherId', 'coverUrl']) {
      jsonOptionalString(json, key);
    }
    jsonOptionalInt(json, 'credits', 1, 60);
    jsonOptionalInt(json, 'hoursPerWeek', 1, 40);
    jsonOptionalStrings(json, 'syllabus');
    jsonOptionalStrings(json, 'materials');
    return _$SubjectFromJson(json);
  }
  Map<String, Object?> toJson() => _$SubjectToJson(this);
}
