import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/shared/widgets/ui/campus_card.dart';
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
    final t = CampusTokens.of(context), text = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: CampusCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.event_rounded, color: t.accent),
                SizedBox(width: t.space8),
                Expanded(
                  child: Text(
                    '${formatDayMonth(event.startAt)} · ${formatTime(event.startAt)}',
                    style: text.labelMedium?.copyWith(color: t.accent),
                  ),
                ),
                ?trailing,
              ],
            ),
            SizedBox(height: t.space16),
            Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: t.space8),
            Text(event.location, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
