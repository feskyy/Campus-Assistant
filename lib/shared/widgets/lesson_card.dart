import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.isCurrent = false,
    this.featured = false,
    this.isPast = false,
    this.teacherPhoto,
    this.coverUrl,
    this.onTap,
  });
  final Lesson lesson;
  final bool isCurrent, featured, isPast;
  final String? teacherPhoto, coverUrl;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), text = Theme.of(context).textTheme;
    final color = lesson.type == LessonType.practice
        ? t.readableSupportive
        : t.accent;
    return ui.CampusCard(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: t.space16,
              runSpacing: t.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: t.space16 + t.space4,
                      color: color,
                    ),
                    SizedBox(width: t.space8),
                    Flexible(
                      child: Text(
                        '${lesson.startTime}–${lesson.endTime}',
                        style: text.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(tr(context, lesson.typeLabel), style: text.bodySmall),
                if (isCurrent)
                  Text(
                    strings(context).currentClass,
                    style: text.labelMedium?.copyWith(
                      color: t.readableSupportive,
                    ),
                  ),
                if (isPast)
                  Text(strings(context).pastClass, style: text.bodySmall),
              ],
            ),
            SizedBox(height: t.space16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    lesson.subject,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (coverUrl != null &&
                    constraints.maxWidth >= t.statRowBreakpoint) ...[
                  SizedBox(width: t.space16),
                  SizedBox(
                    width: t.categoryDiameter,
                    height: t.categoryDiameter,
                    child: ui.CampusImage(
                      source: coverUrl,
                      heroTag: 'lesson:${lesson.id}',
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: t.space16),
            Row(
              children: [
                SizedBox(
                  width: t.space24,
                  height: t.space24,
                  child: ClipOval(
                    child: ui.CampusImage(
                      source: teacherPhoto,
                      kind: ui.CampusImageKind.teacher,
                    ),
                  ),
                ),
                SizedBox(width: t.space8),
                Expanded(child: Text(lesson.teacher, style: text.bodySmall)),
              ],
            ),
            SizedBox(height: t.space8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_rounded,
                  size: t.space24,
                  color: t.readableSupportive,
                ),
                SizedBox(width: t.space8),
                Expanded(
                  child: Text(
                    '${lesson.building}, ${strings(context).roomLabel(lesson.room)}',
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
