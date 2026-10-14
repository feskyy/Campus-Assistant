// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CampusEvent _$CampusEventFromJson(Map<String, dynamic> json) => CampusEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  location: json['location'] as String,
  startAt: DateTime.parse(json['startAt'] as String),
  coverUrl: json['coverUrl'] as String?,
  organizer: json['organizer'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
  buildingId: json['buildingId'] as String?,
  room: json['room'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$CampusEventToJson(CampusEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'startAt': instance.startAt.toIso8601String(),
      'coverUrl': ?instance.coverUrl,
      'organizer': ?instance.organizer,
      'buildingId': ?instance.buildingId,
      'room': ?instance.room,
      'capacity': ?instance.capacity,
      'price': ?instance.price,
      'tags': instance.tags,
    };
