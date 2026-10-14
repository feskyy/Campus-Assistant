import 'package:campus_assistant/features/schedule/domain/entities/subject.dart';
import 'package:campus_assistant/features/profile/domain/entities/teacher.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';
import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';

class CampusData {
  const CampusData({
    required this.lessons,
    required this.news,
    required this.events,
    required this.source,
    this.subjects = const [],
    this.teachers = const [],
    this.buildings = const [],
    this.warning,
    this.cachedAt,
  });
  final List<Lesson> lessons;
  final List<NewsItem> news;
  final List<CampusEvent> events;
  final List<Subject> subjects;
  final List<Teacher> teachers;
  final List<Building> buildings;
  final String source;
  final String? warning;
  final DateTime? cachedAt;
  Map<String, dynamic> toJson() => {
    'lessons': lessons.map((e) => e.toJson()).toList(),
    'news': news.map((e) => e.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
    'subjects': subjects.map((e) => e.toJson()).toList(),
    'teachers': teachers.map((e) => e.toJson()).toList(),
    'buildings': buildings.map((e) => e.toJson()).toList(),
  };
  factory CampusData.fromJson(
    Map<String, dynamic> json,
    String source, {
    String? warning,
    DateTime? cachedAt,
  }) => CampusData(
    lessons: _list(json['lessons']).map(Lesson.fromJson).toList(),
    news: _list(json['news']).map(NewsItem.fromJson).toList(),
    events: _list(json['events']).map(CampusEvent.fromJson).toList(),
    subjects: json['subjects'] == null
        ? []
        : _list(json['subjects']).map(Subject.fromJson).toList(),
    teachers: json['teachers'] == null
        ? []
        : _list(json['teachers']).map(Teacher.fromJson).toList(),
    buildings: json['buildings'] == null
        ? []
        : _list(json['buildings']).map(Building.fromJson).toList(),
    source: source,
    warning: warning,
    cachedAt: cachedAt,
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
