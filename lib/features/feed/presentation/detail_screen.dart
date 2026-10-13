import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.kind, required this.id});
  final String kind, id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Подробности')),
      body: PageBody(
        maxWidth: 680,
        child: DataView(
          builder: (data) {
            final fields = <String>[];
            String? title;
            String? body;
            var eyebrow = '';
            if (kind == 'news') {
              for (final item in data.news.where((e) => e.id == id)) {
                title = item.title;
                eyebrow = item.category;
                fields.add(formatDayMonth(item.publishedAt));
                body = item.body;
              }
            } else if (kind == 'event') {
              for (final item in data.events.where((e) => e.id == id)) {
                title = item.title;
                eyebrow = 'МЕРОПРИЯТИЕ';
                fields.addAll([
                  '${formatDayMonth(item.startAt)} ${formatTime(item.startAt)}',
                  item.location,
                ]);
                body = item.description;
              }
            } else {
              for (final item in data.lessons.where((e) => e.id == id)) {
                title = item.subject;
                eyebrow = item.typeLabel;
                fields.addAll([
                  '${item.startTime}–${item.endTime}',
                  item.teacher,
                  '${item.building}, ауд. ${item.room}',
                  'Группа ${item.group}',
                  'День недели: ${item.weekday}',
                ]);
              }
            }
            if (title == null) {
              return const EmptyState(
                icon: Icons.article_outlined,
                message: 'Запись не найдена',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                PageIntro(eyebrow: eyebrow, title: title),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final field in fields)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              field,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (body != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SelectableText(
                      body,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                SourceNotice(data: data),
                if (kind != 'lesson')
                  OutlinedButton.icon(
                    onPressed: () => toggleFavorite(context, ref, kind, id),
                    icon: Icon(
                      favorites.contains('$kind:$id')
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    label: Text(
                      favorites.contains('$kind:$id')
                          ? 'Удалить из избранного'
                          : 'В избранное',
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
