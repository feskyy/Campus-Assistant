import 'package:intl/intl.dart';
import 'package:campus_assistant/features/tasks/presentation/tasks_section.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleState();
}

class _ScheduleState extends ConsumerState<ScheduleScreen> {
  int weekOffset = 0;
  int? day;
  @override
  Widget build(BuildContext context) {
    final group = ref.watch(appSettingsProvider).selectedGroup;
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1 + weekOffset * 7,
    );
    final t = CampusTokens.of(context);
    final selectedDay = day ?? now.weekday;
    final selectedDate = monday.add(Duration(days: selectedDay - 1));
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Расписание')),
        actions: [
          IconButton(
            tooltip: strings(context).tasksNew,
            onPressed: () => editPersonalTask(context, day: selectedDate),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: PageBody(
        child: DataView(
          builder: (data) {
            final groups = {group, ...data.lessons.map((e) => e.group)}.toList()
              ..sort();
            final lessons = lessonsForDay(data.lessons, selectedDay, group);
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(t.space24),
                children: [
                  ui.PillButton(
                    label: strings(context).groupLabel(group),
                    icon: Icons.people_rounded,
                    variant: ui.PillButtonVariant.outlined,
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (sheetContext) => SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const ui.BottomSheetHandle(),
                              for (final g in groups)
                                ListTile(
                                  title: Text(g),
                                  selected: g == group,
                                  onTap: () {
                                    Navigator.pop(sheetContext);
                                    saveSetting(
                                      context,
                                      () => ref
                                          .read(appSettingsProvider.notifier)
                                          .setSelectedGroup(g),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: strings(context).previousWeek,
                        onPressed: () => setState(() => weekOffset--),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          '${strings(context).weekLabel} · ${formatDayMonth(monday)}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: strings(context).nextWeek,
                        onPressed: () => setState(() => weekOffset++),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: CampusTokens.of(context).space24),
                  LayoutBuilder(
                    builder: (context, constraints) => Row(
                      key: const ValueKey('schedule-week-strip'),
                      children: List.generate(7, (i) {
                        final selected = selectedDay == i + 1;
                        final date = monday.add(Duration(days: i));
                        final raw = DateFormat(
                          'E',
                          Localizations.localeOf(context).languageCode,
                        ).format(date);
                        final label =
                            '${raw[0].toUpperCase()}${raw.substring(1)}';
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: t.space4 / 2,
                              right: t.space4 / 2,
                            ),
                            child: Semantics(
                              selected: selected,
                              button: true,
                              label: MaterialLocalizations.of(context)
                                  .formatFullDate(date),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  t.fieldRadius,
                                ),
                                onTap: () => setState(() => day = i + 1),
                                child: AnimatedContainer(
                                  duration: t.motionDuration(context),
                                  padding: EdgeInsets.symmetric(
                                    vertical: t.space16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected ? t.accent : t.surface,
                                    borderRadius: BorderRadius.circular(
                                      t.fieldRadius,
                                    ),
                                    border: Border.all(
                                      color:
                                          selected ||
                                              DateUtils.isSameDay(date, now)
                                          ? t.accent
                                          : t.border,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        label,
                                        maxLines: 1,
                                        style:
                                            (constraints.maxWidth <
                                                        t.compactBreakpoint
                                                    ? theme.textTheme.labelSmall
                                                    : theme
                                                          .textTheme
                                                          .labelMedium)
                                                ?.copyWith(
                                                  color: selected
                                                      ? t.onAccent
                                                      : t.readableSecondary,
                                                ),
                                      ),
                                      SizedBox(height: t.space8),
                                      Text(
                                        '${date.day}',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: selected
                                                  ? t.onAccent
                                                  : t.text,
                                            ),
                                      ),
                                      SizedBox(height: t.space8),
                                      Container(
                                        width: t.space4,
                                        height: t.space4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: DateUtils.isSameDay(date, now)
                                              ? (selected
                                                    ? t.onAccent
                                                    : t.accent)
                                              : t.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: CampusTokens.of(context).space24),
                  Text(
                    '${DateFormat('EEEE', Localizations.localeOf(context).languageCode).format(selectedDate)}, ${formatDayMonth(selectedDate)}',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: CampusTokens.of(context).space8),
                  Text(
                    lessons.isEmpty
                        ? tr(context, 'Свободный день')
                        : strings(context)
                              .lessonCount(lessons.length.toString()),
                    style: theme.textTheme.bodySmall,
                  ),
                  SizedBox(height: CampusTokens.of(context).space16),
                  if (lessons.isEmpty)
                    ui.EmptyState(
                      title: tr(context, 'Свободный день'),
                      message: tr(context, 'В этот день занятий нет'),
                    ),
                  for (final lesson in lessons)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.space16),
                      child: LessonCard(
                        lesson: lesson,
                        isCurrent:
                            weekOffset == 0 &&
                            selectedDay == now.weekday &&
                            isCurrentLesson(lesson, now),
                        isPast:
                            selectedDate.isBefore(
                              DateTime(now.year, now.month, now.day),
                            ) ||
                            (weekOffset == 0 &&
                                selectedDay == now.weekday &&
                                lesson.endMinutes < now.hour * 60 + now.minute),
                        coverUrl: data.subjects
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
                  TasksSection(day: selectedDate),
                  SizedBox(height: t.space24),
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
