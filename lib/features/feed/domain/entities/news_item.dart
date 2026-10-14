import 'news_block.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';

part 'news_item.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.publishedAt,
    this.content,
    this.imageUrl,
    this.author,
    this.readMinutes,
    this.relatedBuildingId,
    this.blocks = const [],
  });
  final String id, title, summary, category;
  final String? content, imageUrl, author, relatedBuildingId;
  final int? readMinutes;
  final List<NewsBlock> blocks;
  final DateTime publishedAt;
  String get body =>
      content ??
      (blocks.isEmpty
          ? summary
          : blocks
                .map((block) => block.text ?? block.items.join('\n'))
                .where((text) => text.isNotEmpty)
                .join('\n\n'));
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    for (final key in ['id', 'title', 'summary', 'category']) {
      jsonString(json, key);
    }
    jsonDate(json, 'publishedAt');
    if (json['content'] != null) {
      jsonString(json, 'content');
    }
    for (final key in ['imageUrl', 'author', 'relatedBuildingId']) {
      jsonOptionalString(json, key);
    }
    jsonOptionalInt(json, 'readMinutes', 1, 240);
    for (final block in jsonOptionalObjects(json, 'blocks')) {
      NewsBlock.fromJson(block);
    }
    return _$NewsItemFromJson(json);
  }
  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
}
