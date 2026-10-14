import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';

import 'room.dart';
part 'building.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Building {
  const Building({
    required this.id,
    required this.name,
    this.address,
    this.floors,
    this.description,
    this.photoUrl,
    this.x,
    this.y,
    this.rooms = const [],
  });
  final String id, name;
  final String? address, description, photoUrl;
  final int? floors;
  final double? x, y;
  final List<Room> rooms;
  factory Building.fromJson(Map<String, Object?> json) {
    jsonString(json, 'id');
    jsonString(json, 'name');
    for (final key in ['address', 'description', 'photoUrl']) {
      jsonOptionalString(json, key);
    }
    jsonOptionalInt(json, 'floors', 1, 100);
    jsonOptionalNumber(json, 'x', 0, 1);
    jsonOptionalNumber(json, 'y', 0, 1);
    for (final data in jsonOptionalObjects(json, 'rooms')) {
      final room = Room.fromJson(data);
      if (room.floor != null &&
          json['floors'] is int &&
          room.floor! > (json['floors'] as int)) {
        throw const FormatException('Этаж аудитории выше этажности корпуса');
      }
    }
    return _$BuildingFromJson(json);
  }
  Map<String, Object?> toJson() => _$BuildingToJson(this);
}
