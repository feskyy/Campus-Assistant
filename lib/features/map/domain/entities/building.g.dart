// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Building _$BuildingFromJson(Map<String, dynamic> json) => Building(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  floors: (json['floors'] as num?)?.toInt(),
  description: json['description'] as String?,
  photoUrl: json['photoUrl'] as String?,
  x: (json['x'] as num?)?.toDouble(),
  y: (json['y'] as num?)?.toDouble(),
  rooms:
      (json['rooms'] as List<dynamic>?)
          ?.map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BuildingToJson(Building instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': ?instance.address,
  'description': ?instance.description,
  'photoUrl': ?instance.photoUrl,
  'floors': ?instance.floors,
  'x': ?instance.x,
  'y': ?instance.y,
  'rooms': instance.rooms.map((e) => e.toJson()).toList(),
};
