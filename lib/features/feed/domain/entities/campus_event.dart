import 'package:campus_assistant/core/utils/json_validation.dart';

class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startAt,
  });
  final String id, title, description, location;
  final DateTime startAt;
  factory CampusEvent.fromJson(Map<String, dynamic> json) => CampusEvent(
    id: jsonString(json, 'id'),
    title: jsonString(json, 'title'),
    description: jsonString(json, 'description'),
    location: jsonString(json, 'location'),
    startAt: jsonDate(json, 'startAt'),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'startAt': startAt.toIso8601String(),
  };
}
