import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.width,
    this.onTap,
    this.trailing,
  });
  final CampusEvent event;
  final double? width;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        event.startAt.day.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                      Text(
                        formatDayMonth(event.startAt).split(' ').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatTime(event.startAt)} · ${event.location}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.chevron_right_rounded, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
