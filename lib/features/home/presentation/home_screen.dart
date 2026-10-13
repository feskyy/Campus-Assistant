import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/event_card.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/shared/widgets/news_tile.dart';
import 'package:campus_assistant/shared/widgets/section_header.dart';
import 'package:campus_assistant/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final group = ref.watch(appSettingsProvider).selectedGroup;
    final user = ref.watch(firebaseUserProvider).asData?.value;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Assistant', style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: 'Профиль',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageBody(
        child: DataView(
          builder: (data) {
            final next = nextLesson(data.lessons, group, now);
            final events =
                data.events.where((e) => !e.startAt.isBefore(now)).toList()
                  ..sort((a, b) => a.startAt.compareTo(b.startAt));
            final news = [...data.news]
              ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  PageIntro(
                    eyebrow:
                        '${formatDayMonth(now)} ${now.year} · Группа $group',
                    title:
                        'Добро пожаловать, ${user?.displayName ?? user?.email ?? 'гость'}!',
                  ),
                  SectionHeader(
                    'Ближайшее занятие',
                    action: 'Расписание',
                    onAction: () => context.go('/schedule'),
                  ),
                  if (next == null)
                    const EmptyState(
                      icon: Icons.calendar_today_outlined,
                      message: 'Для выбранной группы занятий нет',
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        formatDayMonth(next.start),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    LessonCard(
                      lesson: next.lesson,
                      featured: true,
                      isCurrent: isCurrentLesson(next.lesson, now),
                      onTap: () => context.push(
                        '/lesson/${Uri.encodeComponent(next.lesson.id)}',
                      ),
                    ),
                  ],
                  SourceNotice(data: data),
                  const SizedBox(height: 24),
                  const SectionHeader('Быстрый доступ'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.calendar_today_outlined,
                          label: 'Пары',
                          onTap: () => context.go('/schedule'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.bookmark_border_rounded,
                          label: 'Лента',
                          onTap: () => context.go('/feed'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.near_me_outlined,
                          label: 'Кампус',
                          onTap: () => context.go('/map'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    'Ближайшие события',
                    action: 'Все',
                    onAction: () => context.go('/feed?tab=events'),
                  ),
                  if (events.isEmpty)
                    const EmptyState(
                      icon: Icons.event_outlined,
                      message: 'Ближайших событий нет',
                    ),
                  for (final event in events.take(2))
                    EventCard(
                      event: event,
                      onTap: () => context.push(
                        '/event/${Uri.encodeComponent(event.id)}',
                      ),
                    ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    'Новости',
                    action: 'Все',
                    onAction: () => context.go('/feed'),
                  ),
                  if (news.isEmpty)
                    const EmptyState(
                      icon: Icons.article_outlined,
                      message: 'Новостей нет',
                    ),
                  for (final item in news.take(2))
                    NewsTile(
                      item: item,
                      onTap: () =>
                          context.push('/news/${Uri.encodeComponent(item.id)}'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
