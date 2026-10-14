import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

import 'campus_card.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.school_rounded,
    this.action,
  });
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: t.heroGradient,
        borderRadius: BorderRadius.circular(t.cardRadius),
        border: t.isDark ? Border.all(color: t.border) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.accent),
            SizedBox(height: t.space16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: t.text),
            ),
            SizedBox(height: t.space8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: t.text),
            ),
            if (action != null) ...[SizedBox(height: t.space16), action!],
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    this.label,
  });
  final IconData icon;
  final String value;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: t.space8,
            runSpacing: t.space4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(icon, color: t.accent),
              Text(value, style: t.sectionStyle),
            ],
          ),
          if (label != null) ...[
            SizedBox(height: t.space8),
            Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.tiles}) : assert(tiles.length == 4);
  final List<StatTile> tiles;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= t.statRowBreakpoint ? 4 : 2;
        final width =
            (constraints.maxWidth - t.space8 * (columns - 1)) / columns;
        return Wrap(
          spacing: t.space8,
          runSpacing: t.space8,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.onAll,
    this.actionLabel,
  });
  final String title;
  final VoidCallback? onAll;
  final String? actionLabel;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: t.sectionStyle)),
        SizedBox(width: t.space8),
        TextButton(
          onPressed: onAll,
          child: Text(actionLabel ?? strings(context).allItems),
        ),
      ],
    );
  }
}

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Semantics(
      label: strings(context).designSheetHandle,
      child: Center(
        child: Container(
          width: t.tapExtent,
          height: t.space4,
          margin: EdgeInsets.symmetric(vertical: t.space8),
          decoration: BoxDecoration(
            color: t.readableSecondary,
            borderRadius: BorderRadius.circular(t.pillRadius),
          ),
        ),
      ),
    );
  }
}
