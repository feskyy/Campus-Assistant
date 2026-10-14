import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/features/schedule/domain/entities/subject.dart';
import 'package:campus_assistant/features/profile/domain/entities/teacher.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';

import 'demo_content.dart';

/// Fictional demonstration records. No real university integration.
class StaticData {
  const StaticData._();
  static List<Map<String, Object?>> _rows(String key) =>
      (demoContent[key]! as List<Object?>)
          .map((row) => row! as Map<String, Object?>)
          .toList();
  static final List<Lesson> lessons = _rows('schedule')
      .map(Lesson.fromJson)
      .toList();
  static final List<NewsItem> news = _rows('news')
      .map(NewsItem.fromJson)
      .toList();
  static final List<CampusEvent> events = _rows('events')
      .map(CampusEvent.fromJson)
      .toList();
  static final List<Subject> subjects = _rows('subjects')
      .map(Subject.fromJson)
      .toList();
  static final List<Teacher> teachers = _rows('teachers')
      .map(Teacher.fromJson)
      .toList();
  static final List<Building> buildings = _rows('buildings')
      .map(Building.fromJson)
      .toList();
  static List<Lesson> lessonsForWeekday(int weekday) =>
      lessons.where((lesson) => lesson.weekday == weekday).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
}
