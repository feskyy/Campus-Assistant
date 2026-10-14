import 'package:json_annotation/json_annotation.dart';
import 'package:campus_assistant/core/utils/json_validation.dart';
part 'news_block.g.dart';

enum NewsBlockType { heading, paragraph, quote, keyFacts, image }

@JsonSerializable(includeIfNull: false)
class NewsBlock {
  const NewsBlock({
    required this.type,
    this.text,
    this.items = const [],
    this.imageUrl,
    this.caption,
  });
  final NewsBlockType type;
  final String? text, imageUrl, caption;
  final List<String> items;
  factory NewsBlock.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    if (type is! String ||
        !NewsBlockType.values.any((item) => item.name == type)) {
      throw const FormatException('Некорректный тип блока');
    }
    for (final key in ['text', 'imageUrl', 'caption']) {
      jsonOptionalString(json, key);
    }
    final items = jsonOptionalStrings(json, 'items');
    if (['heading', 'paragraph', 'quote'].contains(type)) {
      jsonString(json, 'text');
    }
    if (type == 'keyFacts' && items.isEmpty) {
      throw const FormatException('Факты не могут быть пустыми');
    }
    if (type == 'image') {
      jsonString(json, 'imageUrl');
    }
    return _$NewsBlockFromJson(json);
  }
  Map<String, Object?> toJson() => _$NewsBlockToJson(this);
}
