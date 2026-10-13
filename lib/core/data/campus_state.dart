import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_repository.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campusRepositoryProvider = Provider<CampusDataSource>(
  (ref) => CampusRepository(prefs: ref.watch(sharedPreferencesProvider)),
);
final campusDataProvider = AsyncNotifierProvider<CampusController, CampusData>(
  CampusController.new,
);

class CampusController extends AsyncNotifier<CampusData> {
  @override
  Future<CampusData> build() async {
    final repository = ref.watch(campusRepositoryProvider);
    final cache = repository.cached();
    if (cache != null) {
      unawaited(
        Future<void>(() async {
          final next = await AsyncValue.guard(repository.load);
          if (ref.mounted) state = next;
        }),
      );
      return cache;
    }
    return repository.load();
  }

  Future<void> refresh() async {
    final previous = state.asData?.value;
    if (previous == null) state = const AsyncLoading();
    final result = await AsyncValue.guard(
      ref.read(campusRepositoryProvider).load,
    );
    if (ref.mounted) state = result;
  }
}

final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});
List<Lesson> lessonsForDay(List<Lesson> lessons, int weekday, String group) =>
    lessons.where((e) => e.weekday == weekday && e.group == group).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
bool isCurrentLesson(Lesson lesson, DateTime now) {
  final minutes = now.hour * 60 + now.minute;
  return lesson.weekday == now.weekday &&
      minutes >= lesson.startMinutes &&
      minutes < lesson.endMinutes;
}

({Lesson lesson, DateTime start})? nextLesson(
  List<Lesson> lessons,
  String group,
  DateTime now,
) {
  for (var offset = 0; offset <= 7; offset++) {
    final date = DateTime(now.year, now.month, now.day + offset);
    for (final lesson in lessonsForDay(lessons, date.weekday, group)) {
      final start = date.add(Duration(minutes: lesson.startMinutes));
      if (start.isAfter(now) || isCurrentLesson(lesson, now) && offset == 0) {
        return (lesson: lesson, start: start);
      }
    }
  }
  return null;
}

final favoritesProvider = NotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends Notifier<Set<String>> {
  Future<void> _pending = Future.value();
  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return {
      ...?prefs.getStringList('favorite_news_ids')?.map((e) => 'news:$e'),
      ...?prefs.getStringList('favorite_event_ids')?.map((e) => 'event:$e'),
    };
  }

  Future<void> toggle(String kind, String id) {
    final operation = _pending.then((_) => _toggle(kind, id));
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _toggle(String kind, String id) async {
    if (!ref.mounted) return;
    final key = '$kind:$id';
    final next = {...state};
    next.contains(key) ? next.remove(key) : next.add(key);
    final saved = await ref
        .read(sharedPreferencesProvider)
        .setStringList(
          kind == 'news' ? 'favorite_news_ids' : 'favorite_event_ids',
          next
              .where((e) => e.startsWith('$kind:'))
              .map((e) => e.substring(kind.length + 1))
              .toList(),
        );
    if (!saved) throw const FormatException('Не удалось сохранить избранное');
    if (ref.mounted) state = next;
  }
}
