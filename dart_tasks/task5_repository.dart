// ignore_for_file: avoid_print

/// Задача 5. Интерфейс, реализация, Future, nullable-результат.
class Lesson {
  const Lesson(this.subject, this.startHour);

  final String subject;
  final int startHour;
}

abstract interface class LessonRepository {
  Future<List<Lesson>> lessonsForDay(int weekday);
}

class InMemoryLessonRepository implements LessonRepository {
  final Map<int, List<Lesson>> _data = {
    1: [const Lesson('Математика', 9), const Lesson('Физика', 11)],
    2: [const Lesson('Программирование', 10)],
  };

  @override
  Future<List<Lesson>> lessonsForDay(int weekday) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _data[weekday] ?? const [];
  }
}

Lesson? nextLesson(List<Lesson> lessons, int currentHour) {
  for (final Lesson lesson in lessons) {
    if (lesson.startHour > currentHour) {
      return lesson;
    }
  }
  return null;
}

Future<void> main() async {
  final LessonRepository repo = InMemoryLessonRepository();

  final List<Lesson> monday = await repo.lessonsForDay(1);
  final Lesson? next = nextLesson(monday, 10);
  if (next == null) {
    print('Пар больше нет');
  } else {
    print(
      'Следующая: ${next.subject} в ${next.startHour}:00',
    ); // Физика в 11:00
  }

  final List<Lesson> sunday = await repo.lessonsForDay(7);
  print(sunday.isEmpty ? 'Воскресенье: свободный день' : 'Есть пары');
}
