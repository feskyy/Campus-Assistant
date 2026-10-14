import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: SizedBox(
        width: t.categoryDiameter + t.space24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: selected ? t.accent : t.surface,
              shape: CircleBorder(
                side: selected ? BorderSide.none : BorderSide(color: t.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: t.categoryDiameter,
                  height: t.categoryDiameter,
                  child: Icon(icon, color: selected ? t.onAccent : t.accent),
                ),
              ),
            ),
            SizedBox(height: t.space8),
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: t.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label});
  final T value;
  final String label;
}

class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  }) : assert(options.length > 0);
  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(t.pillRadius),
        border: t.isDark ? Border.all(color: t.border) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space4),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final option in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: option.value == value,
                    child: AnimatedContainer(
                      duration: t.motionDuration(context),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(t.pillRadius),
                        color: option.value == value ? t.accent : t.transparent,
                      ),
                      child: Material(
                        color: t.transparent,
                        borderRadius: BorderRadius.circular(t.pillRadius),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => onChanged(option.value),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: t.tapExtent),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: t.space8,
                                vertical: t.space8,
                              ),
                              child: Center(
                                child: Text(
                                  option.label,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: option.value == value
                                            ? t.onAccent
                                            : t.text,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PillButtonVariant { primary, outlined }

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.supportive = false,
    this.icon,
    this.variant = PillButtonVariant.primary,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool supportive;
  final IconData? icon;
  final PillButtonVariant variant;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon), SizedBox(width: t.space8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return variant == PillButtonVariant.primary
        ? FilledButton(
            onPressed: onPressed,
            style: supportive
                ? FilledButton.styleFrom(
                    backgroundColor: t.supportive,
                    foregroundColor: t.onSupportive,
                  )
                : null,
            child: child,
          )
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accented = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool accented;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: accented ? t.accent : t.photoControl,
        foregroundColor: accented ? t.onAccent : t.photoText,
        disabledBackgroundColor: t.photoControl,
        disabledForegroundColor: t.photoText,
        minimumSize: Size(t.tapExtent, t.tapExtent),
        shape: const CircleBorder(),
      ),
    );
  }
}
