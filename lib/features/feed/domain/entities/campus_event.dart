import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';

part 'campus_event.g.dart';

@JsonSerializable(includeIfNull: false)
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startAt,
    this.coverUrl,
    this.organizer,
    this.capacity,
    this.price,
    this.buildingId,
    this.room,
    this.tags = const [],
  });
  final String id, title, description, location;
  final DateTime startAt;
  final String? coverUrl, organizer, buildingId, room;
  final int? capacity;
  final double? price;
  final List<String> tags;
  bool get isFree => price == 0;
  factory CampusEvent.fromJson(Map<String, dynamic> json) {
    for (final key in ['id', 'title', 'description', 'location']) {
      jsonString(json, key);
    }
    jsonDate(json, 'startAt');
    for (final key in ['coverUrl', 'organizer', 'buildingId', 'room']) {
      jsonOptionalString(json, key);
    }
    jsonOptionalInt(json, 'capacity', 1, 50000);
    jsonOptionalNumber(json, 'price', 0, 10000000);
    jsonOptionalStrings(json, 'tags');
    return _$CampusEventFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CampusEventToJson(this);
}
