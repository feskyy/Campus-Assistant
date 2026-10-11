// ignore_for_file: avoid_print

/// Задача 3. List, Map, Set и функции высшего порядка.
typedef Entry = ({String subject, int weekday, int startHour});

void main() {
  final List<Entry> schedule = [
    (subject: 'Математика', weekday: 1, startHour: 9),
    (subject: 'Физика', weekday: 1, startHour: 11),
    (subject: 'Программирование', weekday: 2, startHour: 10),
    (subject: 'История', weekday: 3, startHour: 8),
    (subject: 'Алгоритмы', weekday: 2, startHour: 8),
  ];

  // 1. Группировка по дню недели: Map<день, список занятий>.
  final Map<int, List<Entry>> byDay = {};
  for (final Entry e in schedule) {
    byDay.putIfAbsent(e.weekday, () => []).add(e);
  }

  // 2. Сортировка занятий внутри каждого дня.
  final List<int> days = byDay.keys.toList()..sort();
  for (final int day in days) {
    final List<Entry> lessons = [...byDay[day]!]
      ..sort((a, b) => a.startHour.compareTo(b.startHour));
    final String line = lessons
        .map((e) => '${e.startHour}:00 ${e.subject}')
        .join(', ');
    print('День $day: $line');
  }

  // 3. Фильтрация и преобразование.
  final List<String> morning = schedule
      .where((e) => e.startHour < 10)
      .map((e) => e.subject)
      .toList();
  print('Утренние пары: $morning');

  // 4. Set убирает повторы.
  final Set<int> uniqueDays = schedule.map((e) => e.weekday).toSet();
  print('Учебных дней: ${uniqueDays.length}'); // 3

  // 5. Количество занятий в каждый день.
  final Map<int, int> counts = byDay.map((d, l) => MapEntry(d, l.length));
  print(counts); // {1: 2, 2: 2, 3: 1}
}
