import 'package:campus_assistant/core/theme/campus_style.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.isCurrent = false,
    this.featured = false,
    this.onTap,
  });
  final Lesson lesson;
  final bool isCurrent, featured;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = switch (lesson.type) {
      LessonType.lecture => scheme.primary,
      LessonType.practice => CampusStyle.practice(context),
      LessonType.lab => CampusStyle.laboratory(context),
    };
    final foreground = featured ? scheme.onPrimaryContainer : scheme.onSurface;
    return Card(
      color: featured || isCurrent ? scheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: featured ? CampusStyle.hero(context) : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(featured ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${lesson.startTime}–${lesson.endTime}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foreground,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            lesson.typeLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: accent,
                            ),
                          ),
                          if (isCurrent)
                            Text(
                              'Сейчас',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                        color: foreground.withValues(alpha: 0.65),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.subject,
                  style:
                      (featured
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(color: foreground),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.teacher,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    Text(
                      '${lesson.building}, ауд. ${lesson.room}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      lesson.group,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
