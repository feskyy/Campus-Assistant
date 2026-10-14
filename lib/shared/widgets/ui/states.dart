import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

import 'controls.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.event_available_rounded,
  });
  final String title, message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) =>
      _StateContent(icon: icon, title: title, message: message, action: action);
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });
  final String title, message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => _StateContent(
    icon: Icons.wifi_off_rounded,
    title: title,
    message: message,
    isError: true,
    action: PillButton(
      label: tr(context, 'Повторить'),
      icon: Icons.refresh_rounded,
      onPressed: onRetry,
    ),
  );
}

class _StateContent extends StatelessWidget {
  const _StateContent({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.isError = false,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  final bool isError;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(t.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: t.categoryDiameter,
            color: isError ? t.error : t.accent,
          ),
          SizedBox(height: t.space16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: t.space8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[SizedBox(height: t.space16), action!],
        ],
      ),
    );
  }
}
