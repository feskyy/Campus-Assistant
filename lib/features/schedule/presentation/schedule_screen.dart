import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleState();
}

class _ScheduleState extends ConsumerState<ScheduleScreen> {
  int day = DateTime.now().weekday;
  final dayScroll = ScrollController(
    initialScrollOffset: ((DateTime.now().weekday - 3).clamp(0, 4) * 56)
        .toDouble(),
  );
  @override
  void dispose() {
    dayScroll.dispose();
    super.dispose();
  }

  static const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const fullDays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  @override
  Widget build(BuildContext context) {
    final group = ref.watch(appSettingsProvider).selectedGroup;
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final selectedDate = monday.add(Duration(days: day - 1));
    final theme = Theme.of(context), scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: PageBody(
        child: DataView(
          builder: (data) {
            final groups = {group, ...data.lessons.map((e) => e.group)}.toList()
              ..sort();
            final lessons = lessonsForDay(data.lessons, day, group);
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(group),
                    initialValue: group,
                    decoration: const InputDecoration(
                      labelText: 'Учебная группа',
                      prefixIcon: Icon(Icons.people_outline_rounded),
                    ),
                    items: groups
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        saveSetting(
                          context,
                          () => ref
                              .read(appSettingsProvider.notifier)
                              .setSelectedGroup(value),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: dayScroll,
                    child: Row(
                      children: List.generate(7, (i) {
                        final selected = day == i + 1;
                        final date = monday.add(Duration(days: i));
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Semantics(
                            selected: selected,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => day = i + 1),
                              child: AnimatedContainer(
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                    ? Duration.zero
                                    : const Duration(milliseconds: 180),
                                width: 48,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? scheme.primary
                                      : scheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? scheme.primary
                                        : scheme.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      days[i],
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: selected
                                                ? scheme.onPrimary
                                                : scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      date.day.toString(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: selected
                                                ? scheme.onPrimary
                                                : scheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i + 1 == now.weekday
                                            ? (selected
                                                  ? scheme.onPrimary
                                                  : scheme.primary)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${fullDays[day - 1]}, ${formatDayMonth(selectedDate)}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lessons.isEmpty
                        ? 'Свободный день'
                        : 'Занятий: ${lessons.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (lessons.isEmpty)
                    const EmptyState(
                      icon: Icons.weekend_outlined,
                      message: 'В этот день занятий нет',
                    ),
                  for (final lesson in lessons)
                    LessonCard(
                      lesson: lesson,
                      isCurrent:
                          day == now.weekday && isCurrentLesson(lesson, now),
                      onTap: () => context.push(
                        '/lesson/${Uri.encodeComponent(lesson.id)}',
                      ),
                    ),
                  SourceNotice(data: data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
