import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';

class CampusData {
  const CampusData({
    required this.lessons,
    required this.news,
    required this.events,
    required this.source,
    this.warning,
  });
  final List<Lesson> lessons;
  final List<NewsItem> news;
  final List<CampusEvent> events;
  final String source;
  final String? warning;
  Map<String, dynamic> toJson() => {
    'lessons': lessons.map((e) => e.toJson()).toList(),
    'news': news.map((e) => e.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
  };
  factory CampusData.fromJson(
    Map<String, dynamic> json,
    String source, {
    String? warning,
  }) => CampusData(
    lessons: _list(json['lessons']).map(Lesson.fromJson).toList(),
    news: _list(json['news']).map(NewsItem.fromJson).toList(),
    events: _list(json['events']).map(CampusEvent.fromJson).toList(),
    source: source,
    warning: warning,
  );
  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) throw const FormatException('Ожидался JSON-массив');
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

abstract interface class CampusDataSource {
  CampusData? cached();
  Future<CampusData> load();
}
