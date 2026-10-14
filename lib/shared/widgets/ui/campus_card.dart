import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';

class CampusCard extends StatelessWidget {
  const CampusCard({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final tokens = CampusTokens.of(context);
    final radius = BorderRadius.circular(tokens.cardRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tokens.shadows,
      ),
      child: Material(
        color: tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: tokens.cardBorder,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.all(tokens.space16),
            child: child,
          ),
        ),
      ),
    );
  }
}
