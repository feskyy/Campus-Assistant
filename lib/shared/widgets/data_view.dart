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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Не удалось обновить данные',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () =>
                        ref.read(campusDataProvider.notifier).refresh(),
                    child: const Text('Повторить'),
                  ),
                ],
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
  Widget build(BuildContext context) => Semantics(
    label: 'Загрузка данных',
    child: ExcludeSemantics(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (var i = 0; i < 3; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final width in [0.4, 0.8, 0.6])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FractionallySizedBox(
                          widthFactor: width,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
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
                tooltip: 'Источник данных',
                icon: const Icon(Icons.more_horiz, size: 18),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Источник данных'),
                    content: Text(data.source),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Понятно'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
