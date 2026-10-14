// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsBlock _$NewsBlockFromJson(Map<String, dynamic> json) => NewsBlock(
  type: $enumDecode(_$NewsBlockTypeEnumMap, json['type']),
  text: json['text'] as String?,
  items:
      (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  imageUrl: json['imageUrl'] as String?,
  caption: json['caption'] as String?,
);

Map<String, dynamic> _$NewsBlockToJson(NewsBlock instance) => <String, dynamic>{
  'type': _$NewsBlockTypeEnumMap[instance.type]!,
  'text': ?instance.text,
  'imageUrl': ?instance.imageUrl,
  'caption': ?instance.caption,
  'items': instance.items,
};

const _$NewsBlockTypeEnumMap = {
  NewsBlockType.heading: 'heading',
  NewsBlockType.paragraph: 'paragraph',
  NewsBlockType.quote: 'quote',
  NewsBlockType.keyFacts: 'keyFacts',
  NewsBlockType.image: 'image',
};
