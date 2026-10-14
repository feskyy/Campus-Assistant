// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
  id: json['id'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String,
  category: json['category'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  content: json['content'] as String?,
  imageUrl: json['imageUrl'] as String?,
  author: json['author'] as String?,
  readMinutes: (json['readMinutes'] as num?)?.toInt(),
  relatedBuildingId: json['relatedBuildingId'] as String?,
  blocks:
      (json['blocks'] as List<dynamic>?)
          ?.map((e) => NewsBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'summary': instance.summary,
  'category': instance.category,
  'content': ?instance.content,
  'imageUrl': ?instance.imageUrl,
  'author': ?instance.author,
  'relatedBuildingId': ?instance.relatedBuildingId,
  'readMinutes': ?instance.readMinutes,
  'blocks': instance.blocks.map((e) => e.toJson()).toList(),
  'publishedAt': instance.publishedAt.toIso8601String(),
};
