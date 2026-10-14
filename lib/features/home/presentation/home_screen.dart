import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/shared/widgets/news_tile.dart';
import 'package:campus_assistant/shared/widgets/event_card.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/features/tasks/presentation/tasks_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CampusTokens.of(context), l = strings(context);
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final group = ref.watch(appSettingsProvider).selectedGroup;
    final user = ref.watch(firebaseUserProvider).asData?.value;
    final result = ref.watch(campusDataProvider), data = result.asData?.value;
    final next = data == null ? null : nextLesson(data.lessons, group, now);
    final today = data == null
        ? null
        : lessonsForDay(data.lessons, now.weekday, group);
    final news = data?.news.toList() ?? [];
    news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final events =
        data?.events.where((event) => !event.startAt.isBefore(now)).toList() ??
        [];
    events.sort((a, b) => a.startAt.compareTo(b.startAt));
    String starts(DateTime start) {
      if (!start.isAfter(now)) return l.currentClass;
      final gap = start.difference(now);
      if (DateUtils.isSameDay(start, now)) {
        return gap.inMinutes < 60
            ? l.startsIn('${gap.inMinutes}')
            : l.homeStartsInHours('${gap.inHours}', '${gap.inMinutes % 60}');
      }
      if (DateUtils.isSameDay(start, now.add(const Duration(days: 1)))) {
        return l.homeTomorrowAt(
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
        );
      }
      return MaterialLocalizations.of(context).formatCompactDate(start);
    }

    return Scaffold(
      body: SafeArea(
        child: PageBody(
          child: RefreshIndicator(
            onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(t.space24),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: t.surface2,
                      child: Icon(Icons.person_rounded, color: t.accent),
                    ),
                    SizedBox(width: t.space16),
                    Expanded(
                      child: Text(
                        l.welcome(user?.displayName ?? user?.email ?? l.guest),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l.notificationsTitle,
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(l.notificationsTitle),
                          content: Text(l.noNotifications),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: Text(tr(c, 'Понятно')),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                SizedBox(height: t.space24),
                if (next != null) ...[
                  ui.HeroBanner(
                    title: l.nextClass,
                    subtitle:
                        '${next.lesson.subject}\n${next.lesson.startTime}–${next.lesson.endTime} · ${starts(next.start)}\n${next.lesson.building}, ${l.roomLabel(next.lesson.room)}',
                    action: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: t.supportive,
                        foregroundColor: t.onSupportive,
                      ),
                      onPressed: () => context.goNamed(
                        Routes.map,
                        queryParameters: {
                          'building': next.lesson.buildingId ?? '',
                          'room': next.lesson.room,
                        },
                      ),
                      icon: const Icon(Icons.near_me_rounded),
                      label: Text(l.routeRoom),
                    ),
                  ),
                  SizedBox(height: t.space24),
                ],
                if (data == null) ...[
                  if (result.hasError)
                    ui.ErrorState(
                      title: tr(context, 'Не удалось обновить данные'),
                      message: result.error.toString(),
                      onRetry: () =>
                          ref.read(campusDataProvider.notifier).refresh(),
                    )
                  else
                    const LinearProgressIndicator(),
                  SizedBox(height: t.space24),
                ],
                if (today != null) ...[
                  ui.SectionHeader(
                    title: l.todayClasses,
                    onAll: () => context.goNamed(Routes.schedule),
                  ),
                  SizedBox(height: t.space16),
                  if (today.isEmpty)
                    ui.EmptyState(
                      title: tr(context, 'Свободный день'),
                      message: tr(context, 'В этот день занятий нет'),
                    ),
                  for (final lesson in today)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.space16),
                      child: LessonCard(
                        lesson: lesson,
                        isCurrent: isCurrentLesson(lesson, now),
                        isPast: lesson.endMinutes <= now.hour * 60 + now.minute,
                        coverUrl: data!.subjects
                            .where((subject) => subject.id == lesson.subjectId)
                            .firstOrNull
                            ?.coverUrl,
                        teacherPhoto: data.teachers
                            .where((teacher) => teacher.id == lesson.teacherId)
                            .firstOrNull
                            ?.photoUrl,
                        onTap: () => context.pushNamed(
                          Routes.lesson,
                          pathParameters: {'id': lesson.id},
                        ),
                      ),
                    ),
                  SizedBox(height: t.space8),
                ],
                const TasksSection(),
                SizedBox(height: t.space24),
                if (data != null) ...[
                  ui.SectionHeader(
                    title: l.homeCampusNews,
                    onAll: () => context.goNamed(Routes.feed),
                  ),
                  SizedBox(height: t.space16),
                  for (final item in news.take(2))
                    NewsTile(
                      item: item,
                      onTap: () => context.pushNamed(
                        Routes.news,
                        pathParameters: {'id': item.id},
                      ),
                    ),
                  SourceNotice(data: data),
                  SizedBox(height: t.space16),
                  ui.SectionHeader(
                    title: tr(context, 'Ближайшие события'),
                    onAll: () => context.goNamed(
                      Routes.feed,
                      queryParameters: {'tab': 'events'},
                    ),
                  ),
                  SizedBox(height: t.space16),
                  if (events.isEmpty)
                    ui.EmptyState(
                      title: l.noUpcomingEvents,
                      message: l.noUpcomingEventsHint,
                    ),
                  for (final event in events.take(2))
                    Padding(
                      padding: EdgeInsets.only(bottom: t.space16),
                      child: EventCard(
                        event: event,
                        onTap: () => context.pushNamed(
                          Routes.event,
                          pathParameters: {'id': event.id},
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
