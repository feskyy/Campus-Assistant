import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';

/// Временные демо-данные. На неделях 4–5 их заменят репозитории и REST API.
class StaticData {
  const StaticData._();

  static const List<Lesson> lessons = [
    Lesson(
      id: 'l1',
      subject: 'Математический анализ',
      teacher: 'Иванов И.И.',
      building: 'Главный корпус',
      room: '214',
      weekday: 1,
      startMinutes: 9 * 60,
      endMinutes: 10 * 60 + 30,
    ),
    Lesson(
      id: 'l2',
      subject: 'Программирование на Dart',
      teacher: 'Петрова А.С.',
      building: 'Корпус Б',
      room: '305',
      weekday: 1,
      startMinutes: 10 * 60 + 45,
      endMinutes: 12 * 60 + 15,
      type: LessonType.lab,
    ),
    Lesson(
      id: 'l3',
      subject: 'Английский язык',
      teacher: 'Смит Д.',
      building: 'Главный корпус',
      room: '112',
      weekday: 1,
      startMinutes: 13 * 60,
      endMinutes: 14 * 60 + 30,
      type: LessonType.practice,
    ),
    Lesson(
      id: 'l4',
      subject: 'Алгоритмы и структуры данных',
      teacher: 'Сидоров П.П.',
      building: 'Корпус Б',
      room: '301',
      weekday: 2,
      startMinutes: 9 * 60,
      endMinutes: 10 * 60 + 30,
    ),
    Lesson(
      id: 'l5',
      subject: 'Базы данных',
      teacher: 'Петрова А.С.',
      building: 'Корпус Б',
      room: '305',
      weekday: 2,
      startMinutes: 10 * 60 + 45,
      endMinutes: 12 * 60 + 15,
      type: LessonType.lab,
    ),
    Lesson(
      id: 'l6',
      subject: 'Мобильная разработка',
      teacher: 'Петрова А.С.',
      building: 'Корпус Б',
      room: '305',
      weekday: 3,
      startMinutes: 11 * 60,
      endMinutes: 12 * 60 + 30,
      type: LessonType.lab,
    ),
    Lesson(
      id: 'l7',
      subject: 'История Казахстана',
      teacher: 'Ахметов Б.К.',
      building: 'Главный корпус',
      room: '210',
      weekday: 3,
      startMinutes: 13 * 60,
      endMinutes: 14 * 60 + 30,
    ),
    Lesson(
      id: 'l8',
      subject: 'Математический анализ',
      teacher: 'Иванов И.И.',
      building: 'Главный корпус',
      room: '214',
      weekday: 4,
      startMinutes: 9 * 60,
      endMinutes: 10 * 60 + 30,
      type: LessonType.practice,
    ),
    Lesson(
      id: 'l9',
      subject: 'Менеджмент',
      teacher: 'Нурланов Е.Т.',
      building: 'Главный корпус',
      room: '118',
      weekday: 5,
      startMinutes: 10 * 60 + 45,
      endMinutes: 12 * 60 + 15,
    ),
  ];

  static final List<NewsItem> news = [
    NewsItem(
      id: 'n1',
      title: 'Открыта запись в студенческие клубы',
      summary: 'Выберите клуб по интересам и подайте заявку до конца месяца.',
      category: 'Университет',
      publishedAt: DateTime(2026, 10, 10),
    ),
    NewsItem(
      id: 'n2',
      title: 'Изменился график работы библиотеки',
      summary: 'С понедельника библиотека работает до 20:00 по будням.',
      category: 'Библиотека',
      publishedAt: DateTime(2026, 10, 9),
    ),
    NewsItem(
      id: 'n3',
      title: 'Итоги олимпиады по программированию',
      summary: 'Команды факультета заняли призовые места на городском этапе.',
      category: 'Достижения',
      publishedAt: DateTime(2026, 10, 8),
    ),
  ];

  static final List<CampusEvent> events = [
    CampusEvent(
      id: 'e1',
      title: 'Хакатон Mobile Dev Weekend',
      description: 'Два дня разработки мобильных приложений в командах.',
      location: 'Корпус Б, актовый зал',
      startAt: DateTime(2026, 10, 17, 10),
    ),
    CampusEvent(
      id: 'e2',
      title: 'День карьеры',
      description: 'Встречи с работодателями и стажировки для студентов.',
      location: 'Главный корпус, холл',
      startAt: DateTime(2026, 10, 22, 15),
    ),
    CampusEvent(
      id: 'e3',
      title: 'Гостевая лекция по Flutter',
      description: 'Практика разработки кроссплатформенных приложений.',
      location: 'Корпус Б, ауд. 305',
      startAt: DateTime(2026, 10, 28, 16, 30),
    ),
  ];

  /// Занятия на день недели (1 = понедельник), уже по порядку времени.
  static List<Lesson> lessonsForWeekday(int weekday) {
    final List<Lesson> result = lessons
        .where((Lesson l) => l.weekday == weekday)
        .toList();
    result.sort(
      (Lesson a, Lesson b) => a.startMinutes.compareTo(b.startMinutes),
    );
    return result;
  }
}
