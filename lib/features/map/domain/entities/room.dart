import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';
part 'room.g.dart';

@JsonSerializable(includeIfNull: false)
class Room {
  const Room({
    required this.number,
    this.floor,
    this.hint,
    this.capacity,
    this.equipment = const [],
  });
  final String number;
  final String? hint;
  final int? floor, capacity;
  final List<String> equipment;
  factory Room.fromJson(Map<String, Object?> json) {
    jsonString(json, 'number');
    jsonOptionalString(json, 'hint');
    jsonOptionalInt(json, 'floor', 0, 100);
    jsonOptionalInt(json, 'capacity', 1, 50000);
    jsonOptionalStrings(json, 'equipment');
    return _$RoomFromJson(json);
  }
  Map<String, Object?> toJson() => _$RoomToJson(this);
}
