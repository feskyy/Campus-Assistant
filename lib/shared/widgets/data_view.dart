import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/campus_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataView extends ConsumerWidget {
  const DataView({super.key, required this.builder});
  final Widget Function(CampusData) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref
        .watch(campusDataProvider)
        .when(
          data: builder,
          loading: () => const _LoadingSkeleton(),
          error: (error, stack) => Center(
            child: SingleChildScrollView(
              child: ui.ErrorState(
                title: tr(context, 'Не удалось обновить данные'),
                message: error.toString(),
                onRetry: () => ref.read(campusDataProvider.notifier).refresh(),
              ),
            ),
          ),
        );
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      child: child,
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Semantics(
      label: tr(context, 'Загрузка данных'),
      child: ExcludeSemantics(
        child: ListView(
          padding: EdgeInsets.all(t.space16),
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: t.space16),
                child: ui.CampusCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: ColoredBox(color: t.surface2),
                      ),
                      Padding(
                        padding: EdgeInsets.all(t.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final factor in [0.8, 0.6])
                              Padding(
                                padding: EdgeInsets.only(bottom: t.space8),
                                child: FractionallySizedBox(
                                  widthFactor: factor,
                                  child: ColoredBox(
                                    color: t.surface2,
                                    child: SizedBox(height: t.space16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SourceNotice extends StatelessWidget {
  const SourceNotice({super.key, required this.data});
  final CampusData data;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final demo = data.source.toLowerCase().contains('демонстрацион');
    final cached = data.source.contains('Сохранённые');
    final label = demo
        ? 'Демо-данные · ${cached ? 'сохранены на устройстве' : 'учебный пример'}'
        : data.source;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                cached
                    ? Icons.offline_bolt_outlined
                    : Icons.info_outline_rounded,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                tooltip: tr(context, 'Источник данных'),
                icon: const Icon(Icons.more_horiz, size: 18),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(tr(context, 'Источник данных')),
                    content: Text(data.source),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(tr(context, 'Понятно')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (cached)
            Text(
              (AppLocalizations.of(context)?.offline(
                    data.cachedAt?.toLocal().toString().split('.').first ??
                        (AppLocalizations.of(context)?.unknownDate ??
                            'неизвестной даты'),
                  )) ??
                  'Нет сети · данные от неизвестной даты',
            ),
          if (data.warning != null)
            Text(
              data.warning!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.error),
            ),
        ],
      ),
    );
  }
}

Future<void> toggleFavorite(
  BuildContext context,
  WidgetRef ref,
  String kind,
  String id,
) async {
  try {
    await ref.read(favoritesProvider.notifier).toggle(kind, id);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

Future<void> saveSetting(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
