import 'entities/building.dart';
import 'entities/room.dart';

import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';

/// Timetable availability only: does not infer bookings or physical occupancy.
class RoomSchedule {
  RoomSchedule({
    required Building building,
    required Room room,
    required List<Lesson> lessons,
    required DateTime now,
  }) : today =
           lessons
               .where(
                 (lesson) =>
                     lesson.room == room.number &&
                     (lesson.buildingId == building.id ||
                         (lesson.buildingId == null &&
                             lesson.building == building.name)) &&
                     lesson.weekday == now.weekday,
               )
               .toList()
             ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes)),
       minutes = now.hour * 60 + now.minute;

  final List<Lesson> today;
  final int minutes;
  List<Lesson> get current => today
      .where(
        (lesson) =>
            lesson.startMinutes <= minutes && minutes < lesson.endMinutes,
      )
      .toList();
  bool get isFree => current.isEmpty;
  Lesson? get next =>
      today.where((lesson) => lesson.startMinutes > minutes).firstOrNull;
}
