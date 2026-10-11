// ignore_for_file: avoid_print

/// Задача 1. Null safety: безопасная работа с необязательными значениями.
String describeRoom(String? building, int? floor, String number) {
  final String place = building ?? 'Корпус не указан';
  final String floorText = floor == null ? 'этаж не указан' : 'этаж $floor';
  return '$place, $floorText, ауд. $number';
}

int? parseFloor(String? raw) {
  if (raw == null) return null;
  return int.tryParse(raw.trim());
}

String? findTeacher(bool exists) => exists ? 'Иванов И.И.' : null;

void main() {
  print(describeRoom('Главный корпус', 2, '214'));
  print(describeRoom(null, null, '101'));

  print(parseFloor(' 3 ')); // 3
  print(parseFloor('abc')); // null
  print(parseFloor(null)); // null

  final String? absent = findTeacher(false);
  print(absent?.length ?? 0); // 0

  final String? present = findTeacher(true);
  if (present != null) {
    // Внутри if компилятор знает, что present не null.
    print(present.length); // 11
  }
}
