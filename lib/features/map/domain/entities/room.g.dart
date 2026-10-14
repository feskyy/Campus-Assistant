// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  number: json['number'] as String,
  floor: (json['floor'] as num?)?.toInt(),
  hint: json['hint'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'number': instance.number,
  'hint': ?instance.hint,
  'floor': ?instance.floor,
  'capacity': ?instance.capacity,
  'equipment': instance.equipment,
};
