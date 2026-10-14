import 'dart:convert';
import 'dart:io';

import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_block.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/features/schedule/domain/entities/subject.dart';
import 'package:campus_assistant/features/profile/domain/entities/teacher.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';
import 'package:campus_assistant/features/map/domain/entities/room.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases =
      <
        ({
          String name,
          Object Function(Map<String, Object?>) decode,
          Map<String, Object?> full,
          Map<String, Object?> minimal,
          Map<String, Object?> malformed,
        })
      >[
        (
          name: 'NewsItem',
          decode: NewsItem.fromJson,
          full: StaticData.news.first.toJson(),
          minimal: {
            'id': 'old',
            'title': 'Заголовок',
            'summary': 'Описание',
            'category': 'Учёба',
            'publishedAt': '2026-10-14',
          },
          malformed: {'readMinutes': 0},
        ),
        (
          name: 'CampusEvent',
          decode: CampusEvent.fromJson,
          full: StaticData.events.first.toJson(),
          minimal: {
            'id': 'old',
            'title': 'Встреча',
            'description': 'Описание',
            'location': 'Главный корпус',
            'startAt': '2026-10-17',
          },
          malformed: {'price': -1},
        ),
        (
          name: 'Lesson',
          decode: Lesson.fromJson,
          full: StaticData.lessons.first.toJson(),
          minimal: {
            'id': 'old',
            'subject': 'Алгебра',
            'teacher': 'Преподаватель',
            'building': 'Корпус',
            'room': '101',
            'weekday': 1,
            'startMinutes': 540,
            'endMinutes': 630,
            'type': 'lecture',
            'group': 'CS-221',
          },
          malformed: {'teacherId': []},
        ),
        (
          name: 'Subject',
          decode: Subject.fromJson,
          full: StaticData.subjects.first.toJson(),
          minimal: {'id': 's', 'title': 'Дисциплина'},
          malformed: {'credits': -1},
        ),
        (
          name: 'Teacher',
          decode: Teacher.fromJson,
          full: StaticData.teachers.first.toJson(),
          minimal: {'id': 't', 'name': 'Преподаватель'},
          malformed: {'email': 'broken'},
        ),
        (
          name: 'Building',
          decode: Building.fromJson,
          full: StaticData.buildings.first.toJson(),
          minimal: {'id': 'b', 'name': 'Корпус'},
          malformed: {'x': 1.01},
        ),
        (
          name: 'Room',
          decode: Room.fromJson,
          full: StaticData.buildings.first.rooms.first.toJson(),
          minimal: {'number': '101'},
          malformed: {'floor': -1},
        ),
        (
          name: 'NewsBlock',
          decode: NewsBlock.fromJson,
          full: StaticData.news.first.blocks.first.toJson(),
          minimal: {'type': 'heading', 'text': 'Заголовок'},
          malformed: {'type': 'unknown'},
        ),
      ];
  for (final item in cases) {
    test('${item.name}: full JSON', () {
      expect(item.decode(item.full), isNotNull);
    });
    test('${item.name}: omitted optional fields', () {
      expect(item.decode(item.minimal), isNotNull);
    });
    test('${item.name}: malformed and missing required fields', () {
      expect(
        () => item.decode({...item.full, ...item.malformed}),
        throwsFormatException,
      );
      expect(() => item.decode({}), throwsFormatException);
    });
  }
  test('every news block kind is typed and nested lists are strict', () {
    final news = NewsItem.fromJson(StaticData.news.first.toJson());
    expect(
      news.blocks.map((block) => block.type).toSet(),
      NewsBlockType.values.toSet(),
    );
    expect(
      () => NewsItem.fromJson({
        ...news.toJson(),
        'blocks': [42],
      }),
      throwsFormatException,
    );
    expect(
      () => NewsBlock.fromJson({
        'type': 'keyFacts',
        'items': [42],
      }),
      throwsFormatException,
    );
    expect(() => NewsBlock.fromJson({'type': 'image'}), throwsFormatException);
    expect(
      () => CampusEvent.fromJson({
        ...StaticData.events.first.toJson(),
        'tags': 'bad',
      }),
      throwsFormatException,
    );
    expect(
      () => Building.fromJson({
        ...StaticData.buildings.first.toJson(),
        'rooms': [
          {'number': '901', 'floor': 9},
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => Building.fromJson({
        ...StaticData.buildings.first.toJson(),
        'x': double.nan,
      }),
      throwsFormatException,
    );
    expect(
      () => Teacher.fromJson({
        ...StaticData.teachers.first.toJson(),
        'photoUrl': 42,
      }),
      throwsFormatException,
    );
    expect(
      () => Subject.fromJson({
        ...StaticData.subjects.first.toJson(),
        'syllabus': [null],
      }),
      throwsFormatException,
    );
    expect(
      NewsItem.fromJson({...news.toJson(), 'content': null}).body,
      contains(news.blocks[1].text!),
    );
    expect(StaticData.events.first.isFree, isTrue);
    expect(StaticData.events.last.isFree, isFalse);
  });
  test(
    'new catalog lists round-trip through cache; old cache remains valid',
    () {
      final original = CampusData(
        lessons: StaticData.lessons,
        news: StaticData.news,
        events: StaticData.events,
        subjects: StaticData.subjects,
        teachers: StaticData.teachers,
        buildings: StaticData.buildings,
        source: 'demo',
      );
      final decoded = CampusData.fromJson(
        (jsonDecode(jsonEncode(original.toJson())) as Map)
            .cast<String, Object?>(),
        'cache',
      );
      expect(decoded.toJson(), original.toJson());
      final old = CampusData.fromJson({
        'lessons': [],
        'news': [],
        'events': [],
      }, 'old cache');
      expect(old.subjects, isEmpty);
      expect(old.teachers, isEmpty);
      expect(old.buildings, isEmpty);
    },
  );
  test('demo content meets counts, image files and all cross references', () {
    expect(StaticData.news.length, greaterThanOrEqualTo(8));
    expect(StaticData.events.length, greaterThanOrEqualTo(6));
    expect(StaticData.subjects.length, greaterThanOrEqualTo(5));
    expect(StaticData.teachers.length, greaterThanOrEqualTo(5));
    expect(StaticData.buildings.length, 4);
    final subjects = {for (final item in StaticData.subjects) item.id: item};
    final teachers = {for (final item in StaticData.teachers) item.id: item};
    final buildings = {for (final item in StaticData.buildings) item.id: item};
    for (final item in StaticData.news) {
      expect(item.blocks.length, inInclusiveRange(4, 6));
      expect(item.body.length, greaterThan(500));
      expect(buildings, contains(item.relatedBuildingId));
      expect(File(item.imageUrl!).existsSync(), isTrue);
      for (final block in item.blocks.where(
        (block) => block.type == NewsBlockType.image,
      )) {
        expect(File(block.imageUrl!).existsSync(), isTrue);
      }
    }
    for (final item in StaticData.events) {
      expect(buildings, contains(item.buildingId));
      expect(
        buildings[item.buildingId]!.rooms.map((room) => room.number),
        contains(item.room),
      );
      expect(File(item.coverUrl!).existsSync(), isTrue);
      expect(item.organizer, isNotEmpty);
      expect(item.tags, isNotEmpty);
    }
    for (final item in StaticData.subjects) {
      expect(teachers, contains(item.teacherId));
      expect(item.syllabus.length, greaterThanOrEqualTo(4));
      expect(item.materials, isNotEmpty);
      expect(File(item.coverUrl!).existsSync(), isTrue);
    }
    for (final item in StaticData.teachers) {
      expect(buildings, contains(item.officeBuildingId));
      expect(
        buildings[item.officeBuildingId]!.rooms.map((room) => room.number),
        contains(item.office),
      );
      expect(File(item.photoUrl!).existsSync(), isTrue);
    }
    for (final item in StaticData.buildings) {
      expect(item.rooms.length, greaterThanOrEqualTo(6));
      expect(item.x, inInclusiveRange(0, 1));
      expect(item.y, inInclusiveRange(0, 1));
      expect(File(item.photoUrl!).existsSync(), isTrue);
    }
    for (final item in StaticData.lessons) {
      expect(subjects, contains(item.subjectId));
      expect(teachers, contains(item.teacherId));
      expect(buildings, contains(item.buildingId));
      expect(
        buildings[item.buildingId]!.rooms.map((room) => room.number),
        contains(item.room),
      );
    }
    expect(StaticData.lessons.map((lesson) => lesson.weekday).toSet(), {
      1,
      2,
      3,
      4,
      5,
    });
  });
}
