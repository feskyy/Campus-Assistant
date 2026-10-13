import 'package:campus_assistant/core/theme/campus_style.dart';
import 'package:flutter/material.dart';

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 800});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    ),
  );
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });
  final String eyebrow, title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(CampusStyle.sectionGap),
        decoration: BoxDecoration(
          gradient: CampusStyle.hero(context),
          borderRadius: BorderRadius.circular(CampusStyle.heroRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
