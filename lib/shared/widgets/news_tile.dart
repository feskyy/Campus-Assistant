import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';

class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.item, this.onTap, this.trailing});
  final NewsItem item;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = CampusTokens.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(t.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: t.space8),
                    child: Icon(
                      Icons.article_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${item.category} · ${formatDayMonth(item.publishedAt)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    SizedBox(width: 48, height: 48, child: trailing!),
                ],
              ),
              SizedBox(height: t.space8),
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: t.space8),
              Text(
                item.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
