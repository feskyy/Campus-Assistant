import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/presentation/not_found_screen.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/features/profile/domain/entities/teacher.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/features/schedule/domain/entities/subject.dart';
import 'package:campus_assistant/features/map/presentation/campus_map_view.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/lesson_card.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/shared/widgets/ui/entity_actions.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

class EntityDetailScreen extends ConsumerWidget {
  const EntityDetailScreen({super.key, required this.kind, required this.id});
  final String kind, id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CampusTokens.of(context), l = strings(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kind == Routes.teacher
              ? l.detailTeacher
              : kind == Routes.subject
              ? l.detailSubject
              : tr(context, 'Подробности'),
        ),
      ),
      body: PageBody(
        maxWidth: t.wideBreakpoint,
        child: DataView(
          builder: (data) {
            final lesson = data.lessons.where((e) => e.id == id).firstOrNull;
            final subject = data.subjects
                .where(
                  (e) =>
                      e.id == (kind == Routes.lesson ? lesson?.subjectId : id),
                )
                .firstOrNull;
            final teacher = data.teachers
                .where(
                  (e) =>
                      e.id ==
                      (kind == Routes.teacher
                          ? id
                          : kind == Routes.lesson
                          ? lesson?.teacherId
                          : subject?.teacherId),
                )
                .firstOrNull;
            if (kind == Routes.lesson && lesson == null ||
                kind == Routes.subject && subject == null ||
                kind == Routes.teacher && teacher == null) {
              return const NotFoundContent();
            }
            final children = <Widget>[];
            Widget heading(String text) => Padding(
              key: ValueKey('section:$text'),
              padding: EdgeInsets.only(top: t.space24, bottom: t.space8),
              child: Text(text, style: t.sectionStyle),
            );
            void lessons(List<Lesson> items) {
              if (items.isEmpty) {
                children.add(Text(l.detailNoLessons));
              }
              for (final item in items) {
                children.add(
                  Text(
                    l.weekdayLabel(item.weekday.toString()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
                children.add(
                  LessonCard(
                    lesson: item,
                    teacherPhoto: data.teachers
                        .where((e) => e.id == item.teacherId)
                        .firstOrNull
                        ?.photoUrl,
                    coverUrl: data.subjects
                        .where((e) => e.id == item.subjectId)
                        .firstOrNull
                        ?.coverUrl,
                    onTap: () => context.pushNamed(
                      Routes.lesson,
                      pathParameters: {'id': item.id},
                    ),
                  ),
                );
              }
            }

            void teacherCard(Teacher? person) {
              if (person == null) {
                children.add(Text(l.detailMissing));
                return;
              }
              children.add(
                ui.CampusCard(
                  key: ValueKey('teacher-link:${person.id}'),
                  onTap: () => context.pushNamed(
                    Routes.teacher,
                    pathParameters: {'id': person.id},
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: t.categoryDiameter,
                            height: t.categoryDiameter,
                            child: ui.CampusImage(
                              source: person.photoUrl,
                              kind: ui.CampusImageKind.teacher,
                              heroTag: 'teacher:${person.id}',
                            ),
                          ),
                          SizedBox(width: t.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(person.name, style: t.sectionStyle),
                                Text(person.position ?? l.detailMissing),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: t.space8),
                      Text(
                        '${l.detailOfficeHours}: ${person.officeHours ?? l.detailMissing}',
                      ),
                      Wrap(
                        spacing: t.space8,
                        runSpacing: t.space8,
                        children: [
                          ui.PillButton(
                            label: l.detailWrite,
                            icon: Icons.mail_rounded,
                            onPressed: person.email == null
                                ? null
                                : () => openEntityLink(
                                    context,
                                    ref,
                                    Uri(scheme: 'mailto', path: person.email),
                                    person.email!,
                                  ),
                          ),
                          ui.PillButton(
                            label: l.detailCopyEmail,
                            variant: ui.PillButtonVariant.outlined,
                            onPressed: person.email == null
                                ? null
                                : () => copyEntityText(context, person.email!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            void subjectCard(Subject item) {
              children.add(
                ui.CampusCard(
                  key: ValueKey('subject-link:${item.id}'),
                  onTap: () => context.pushNamed(
                    Routes.subject,
                    pathParameters: {'id': item.id},
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ui.CampusImage(
                        source: item.coverUrl,
                        kind: ui.CampusImageKind.subject,
                        heroTag: 'subject:${item.id}',
                      ),
                      SizedBox(height: t.space8),
                      Text(item.title, style: t.sectionStyle),
                      Text(item.description ?? l.detailMissing),
                    ],
                  ),
                ),
              );
            }

            Widget cover(
              String? source,
              String tag, {
              String? badge,
              ui.CampusImageKind imageKind = ui.CampusImageKind.subject,
            }) => Stack(
              children: [
                ui.CampusImage(source: source, kind: imageKind, heroTag: tag),
                if (badge != null)
                  Positioned(
                    top: t.space16,
                    left: t.space16,
                    child: ui.PhotoBadge(label: badge),
                  ),
                Positioned(
                  top: t.space8,
                  right: t.space8,
                  child: ui.RoundIconButton(
                    icon: Icons.share_rounded,
                    tooltip: l.detailShare,
                    onPressed: () => copyEntityText(
                      context,
                      GoRouter.of(context)
                          .namedLocation(kind, pathParameters: {'id': id}),
                    ),
                  ),
                ),
                Positioned(
                  bottom: t.space8,
                  right: t.space8,
                  child: ui.RoundIconButton(
                    icon: Icons.photo_rounded,
                    tooltip: l.detailPhoto,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (c) => Dialog(
                        child: ui.CampusImage(source: source, kind: imageKind),
                      ),
                    ),
                  ),
                ),
              ],
            );
            if (kind == Routes.lesson) {
              final item = lesson!;
              final building = data.buildings
                  .where((b) => b.id == item.buildingId)
                  .firstOrNull;
              final room = building?.rooms
                  .where((r) => r.number == item.room)
                  .firstOrNull;
              children.addAll([
                cover(
                  subject?.coverUrl ?? building?.photoUrl,
                  'lesson:${item.id}',
                  badge: tr(context, item.typeLabel),
                ),
                SizedBox(height: t.space16),
                Text(
                  item.subject,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (item.topic != null) Text(item.topic!),
                Text(l.groupLabel(item.group)),
                SizedBox(height: t.space16),
                ui.StatRow(
                  tiles: [
                    ui.StatTile(
                      icon: Icons.schedule_rounded,
                      value: '${item.startTime}–${item.endTime}',
                      label: l.detailTime,
                    ),
                    ui.StatTile(
                      icon: Icons.timer_rounded,
                      value: '${item.endMinutes - item.startMinutes}',
                      label: l.detailDuration,
                    ),
                    ui.StatTile(
                      icon: Icons.stairs_rounded,
                      value: '${room?.floor ?? 0}',
                      label: l.detailFloor,
                    ),
                    ui.StatTile(
                      icon: Icons.people_rounded,
                      value: '${room?.capacity ?? 0}',
                      label: l.detailCapacity,
                    ),
                  ],
                ),
                heading(l.detailWhere),
              ]);
              void map() => context.goNamed(
                Routes.map,
                queryParameters: {
                  'building': item.buildingId ?? '',
                  'room': item.room,
                },
              );
              children.add(
                ui.CampusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (building != null)
                        ui.CampusImage(
                          source: building.photoUrl,
                          kind: ui.CampusImageKind.building,
                          heroTag: 'building:${building.id}',
                        ),
                      Text(
                        '${item.building}, ${l.roomLabel(item.room)}',
                        style: t.sectionStyle,
                      ),
                      if (room != null)
                        Text(
                          room.hint ?? l.detailRoomHint('${room.floor ?? 0}'),
                        ),
                      SizedBox(height: t.space16),
                      SizedBox(
                        height: t.tapExtent * 3,
                        child: CustomPaint(
                          painter: CampusPlanPainter(
                            t,
                            building == null ? [] : [building],
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Wrap(
                        spacing: t.space8,
                        runSpacing: t.space8,
                        children: [
                          ui.FloatingMapPill(
                            label: l.detailMap,
                            onPressed: map,
                          ),
                          ui.PillButton(
                            label: l.routeRoom,
                            variant: ui.PillButtonVariant.outlined,
                            onPressed: () => openEntityLink(
                              context,
                              ref,
                              addressDirections(
                                building?.address ?? item.building,
                              ),
                              building?.address ?? item.building,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              children.add(heading(l.detailTeacher));
              teacherCard(teacher);
              children.add(heading(l.detailSubject));
              if (subject != null) {
                subjectCard(subject);
              } else {
                children.add(Text(l.detailMissing));
              }
              children.add(heading(l.detailNotes));
              children.add(Text(item.notes ?? l.detailNoMaterials));
              for (final material in subject?.materials ?? <String>[]) {
                children.add(
                  ListTile(
                    leading: const Icon(Icons.description_rounded),
                    title: SelectableText(material),
                  ),
                );
              }
              children.add(heading(l.detailNext));
              final items =
                  data.lessons
                      .where(
                        (e) =>
                            e.subjectId == item.subjectId &&
                            e.id != item.id &&
                            e.group == item.group,
                      )
                      .toList()
                    ..sort(
                      (a, b) => (a.weekday * 1440 + a.startMinutes).compareTo(
                        b.weekday * 1440 + b.startMinutes,
                      ),
                    );
              lessons(items);
            } else if (kind == Routes.subject) {
              final item = subject!;
              children.addAll([
                cover(item.coverUrl, 'subject:${item.id}'),
                SizedBox(height: t.space16),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(item.description ?? l.detailMissing),
                SizedBox(height: t.space16),
                ui.StatRow(
                  tiles: [
                    ui.StatTile(
                      icon: Icons.school_rounded,
                      value: '${item.credits ?? 0}',
                      label: l.detailCredits,
                    ),
                    ui.StatTile(
                      icon: Icons.schedule_rounded,
                      value: '${item.hoursPerWeek ?? 0}',
                      label: l.detailHours,
                    ),
                    ui.StatTile(
                      icon: Icons.fact_check_rounded,
                      value: item.assessment ?? l.detailMissing,
                      label: l.detailAssessment,
                    ),
                    ui.StatTile(
                      icon: Icons.list_rounded,
                      value: '${item.syllabus.length}',
                      label: l.detailSyllabus,
                    ),
                  ],
                ),
                heading(l.detailSyllabus),
                for (var i = 0; i < item.syllabus.length; i++)
                  ListTile(
                    leading: Text('${i + 1}'),
                    title: Text(item.syllabus[i]),
                  ),
                heading(l.detailTeacher),
              ]);
              teacherCard(teacher);
              children.add(heading(l.detailMaterials));
              if (item.materials.isEmpty) {
                children.add(Text(l.detailNoMaterials));
              }
              for (final material in item.materials) {
                children.add(
                  ListTile(
                    leading: const Icon(Icons.description_rounded),
                    title: SelectableText(material),
                  ),
                );
              }
              children.add(heading(l.detailWeekly));
              final group = ref.watch(appSettingsProvider).selectedGroup;
              final items =
                  data.lessons
                      .where((e) => e.subjectId == item.id && e.group == group)
                      .toList()
                    ..sort(
                      (a, b) => (a.weekday * 1440 + a.startMinutes).compareTo(
                        b.weekday * 1440 + b.startMinutes,
                      ),
                    );
              lessons(items);
            } else {
              final item = teacher!;
              children.addAll([
                cover(
                  item.photoUrl,
                  'teacher:${item.id}',
                  imageKind: ui.CampusImageKind.teacher,
                ),
                SizedBox(height: t.space16),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(item.position ?? l.detailMissing),
                heading(l.detailContact),
                SelectableText(item.email ?? l.detailMissing),
                Text(
                  '${l.detailOfficeHours}: ${item.officeHours ?? l.detailMissing}',
                ),
                Wrap(
                  spacing: t.space8,
                  runSpacing: t.space8,
                  children: [
                    ui.PillButton(
                      label: l.detailWrite,
                      onPressed: item.email == null
                          ? null
                          : () => openEntityLink(
                              context,
                              ref,
                              Uri(scheme: 'mailto', path: item.email),
                              item.email!,
                            ),
                    ),
                    ui.PillButton(
                      label: l.detailCopyEmail,
                      variant: ui.PillButtonVariant.outlined,
                      onPressed: item.email == null
                          ? null
                          : () => copyEntityText(context, item.email!),
                    ),
                  ],
                ),
                heading(l.detailOffice),
                Text(item.office ?? l.detailMissing),
                ui.FloatingMapPill(
                  label: l.detailMap,
                  onPressed: item.officeBuildingId == null
                      ? null
                      : () => context.goNamed(
                          Routes.map,
                          queryParameters: {
                            'building': item.officeBuildingId!,
                            'room': item.office ?? '',
                          },
                        ),
                ),
                heading(l.detailSubjects),
              ]);
              for (final subject in data.subjects.where(
                (e) => e.teacherId == item.id,
              )) {
                subjectCard(subject);
                children.add(SizedBox(height: t.space16));
              }
            }
            children.add(SourceNotice(data: data));
            return ListView(
              padding: EdgeInsets.all(t.space16),
              children: children,
            );
          },
        ),
      ),
    );
  }
}
