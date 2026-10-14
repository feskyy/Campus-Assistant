import 'package:campus_assistant/shared/widgets/ui/states.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_assistant/core/router/routes.dart';

class NotFoundContent extends StatelessWidget {
  const NotFoundContent({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: EmptyState(
      icon: Icons.search_off_rounded,
      title: tr(context, 'Не найдено'),
      message: tr(context, 'Страница или запись не существует'),
      action: FilledButton.icon(
        onPressed: () => context.goNamed(Routes.home),
        icon: const Icon(Icons.home_rounded),
        label: Text(tr(context, 'На главную')),
      ),
    ),
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('404')),
    body: const NotFoundContent(),
  );
}
