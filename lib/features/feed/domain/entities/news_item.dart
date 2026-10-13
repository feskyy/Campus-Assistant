import 'package:campus_assistant/core/utils/json_validation.dart';

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.publishedAt,
    this.content,
  });
  final String id, title, summary, category;
  final String? content;
  final DateTime publishedAt;
  String get body => content ?? summary;
  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
    id: jsonString(json, 'id'),
    title: jsonString(json, 'title'),
    summary: jsonString(json, 'summary'),
    category: jsonString(json, 'category'),
    publishedAt: jsonDate(json, 'publishedAt'),
    content: json['content'] == null ? null : jsonString(json, 'content'),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'category': category,
    'publishedAt': publishedAt.toIso8601String(),
    if (content != null) 'content': content,
  };
}
