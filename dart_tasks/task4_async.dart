// ignore_for_file: avoid_print

import 'dart:async';

/// Задача 4. Future, async/await, обработка ошибок, Stream.
Future<List<String>> fetchNews() async {
  await Future<void>.delayed(const Duration(seconds: 1));
  return ['Открытие нового корпуса', 'День открытых дверей'];
}

Future<List<String>> fetchEvents({bool fail = false}) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  if (fail) {
    throw Exception('Сервер событий недоступен');
  }
  return ['Хакатон', 'Гостевая лекция'];
}

Stream<int> countdown(int from) async* {
  for (var i = from; i > 0; i--) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

Future<void> main() async {
  final Stopwatch stopwatch = Stopwatch()..start();

  // Два запроса одновременно: общее время ≈ самому долгому (1 с), а не сумме.
  final List<List<String>> results = await Future.wait([
    fetchNews(),
    fetchEvents(),
  ]);
  print('Новости: ${results[0]}');
  print('События: ${results[1]}');
  print('Заняло: ${stopwatch.elapsedMilliseconds} мс');

  // Ошибка запроса.
  try {
    await fetchEvents(fail: true);
  } on Exception catch (e) {
    print('Ошибка: $e');
  } finally {
    print('Запрос завершён');
  }

  // Тайм-аут.
  try {
    await fetchNews().timeout(const Duration(milliseconds: 200));
  } on TimeoutException {
    print('Тайм-аут при загрузке новостей');
  }

  // Поток значений во времени.
  await for (final int n in countdown(3)) {
    print('До начала пары: $n');
  }
}
