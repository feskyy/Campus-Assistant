import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:provider/provider.dart' as local;

import 'feed_ui_state.dart';

import 'dart:async';

import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as components;
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key, this.initialEvents = false});
  final bool initialEvents;
  @override
  ConsumerState<FeedScreen> createState() => _FeedState();
}

class _FeedState extends ConsumerState<FeedScreen> {
  final search = TextEditingController();
  Timer? debounce;
  late final FeedUiState ui;
  String get query => ui.query;
  String get category => ui.category;
  bool get eventsTab => ui.eventsTab;
  bool get favoritesOnly => ui.favoritesOnly;
  @override
  void initState() {
    super.initState();
    ui = FeedUiState(initialEvents: widget.initialEvents);
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialEvents != widget.initialEvents) {
      ui.setEvents(widget.initialEvents);
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    ui.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return local.ChangeNotifierProvider<FeedUiState>.value(
      value: ui,
      child: local.Consumer<FeedUiState>(
        builder: (context, _, _) => _buildFeed(context),
      ),
    );
  }

  Widget _buildFeed(BuildContext context) {
    final t = CampusTokens.of(context);
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'Новости и события'))),
      body: PageBody(
        child: DataView(
          builder: (data) {
            final categories = {'Все', ...data.news.map((e) => e.category)};
            final news =
                data.news
                    .where(
                      (e) =>
                          (category == 'Все' || category == e.category) &&
                          ('${e.title} ${e.summary} ${e.body}')
                              .toLowerCase()
                              .contains(query) &&
                          (!favoritesOnly ||
                              favorites.contains('news:${e.id}')),
                    )
                    .toList()
                  ..sort(
                    (a, b) => ui.oldestFirst
                        ? a.publishedAt.compareTo(b.publishedAt)
                        : b.publishedAt.compareTo(a.publishedAt),
                  );
            final events =
                data.events
                    .where(
                      (e) =>
                          ('${e.title} ${e.description} ${e.location}')
                              .toLowerCase()
                              .contains(query) &&
                          (!favoritesOnly ||
                              favorites.contains('event:${e.id}')) &&
                          (ui.eventTag == 'Все' ||
                              e.tags.contains(ui.eventTag)),
                    )
                    .toList()
                  ..sort(
                    (a, b) => ui.oldestFirst
                        ? b.startAt.compareTo(a.startAt)
                        : a.startAt.compareTo(b.startAt),
                  );
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(CampusTokens.of(context).space24),
                children: [
                  components.SegmentedPill<bool>(
                    options: [
                      components.SegmentOption(
                        value: false,
                        label: tr(context, 'Новости'),
                      ),
                      components.SegmentOption(
                        value: true,
                        label: tr(context, 'События'),
                      ),
                    ],
                    value: eventsTab,
                    onChanged: ui.setEvents,
                  ),
                  SizedBox(height: CampusTokens.of(context).space16),
                  TextField(
                    controller: search,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: tr(context, 'Найти в ленте'),
                    ),
                    onChanged: (value) {
                      debounce?.cancel();
                      debounce = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ui.setQuery(value);
                        }
                      });
                    },
                  ),
                  SizedBox(
                    height:
                        CampusTokens.of(context).space8 +
                        CampusTokens.of(context).space4,
                  ),
                  Wrap(
                    spacing: CampusTokens.of(context).space8,
                    runSpacing: CampusTokens.of(context).space8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterChip(
                        labelStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: favoritesOnly
                                  ? t.onAccent
                                  : t.readableSecondary,
                            ),
                        backgroundColor: t.surface2,
                        selectedColor: t.accent,
                        label: Text(tr(context, 'Избранное')),
                        selected: favoritesOnly,
                        avatar: Icon(
                          Icons.bookmark_rounded,
                          color: favoritesOnly ? t.onAccent : t.accent,
                        ),
                        onSelected: (value) => ui.setFavoritesOnly(value),
                      ),
                      if (!eventsTab)
                        for (final c in categories)
                          FilterChip(
                            labelStyle: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: category == c
                                      ? t.onAccent
                                      : t.readableSecondary,
                                ),
                            backgroundColor: t.surface2,
                            selectedColor: t.accent,
                            avatar: Icon(
                              Icons.label_rounded,
                              color: category == c ? t.onAccent : t.accent,
                            ),
                            label: Text(tr(context, c)),
                            selected: category == c,
                            onSelected: (_) => ui.setCategory(c),
                          ),
                    ],
                  ),
                  if (eventsTab)
                    Wrap(
                      spacing: t.space8,
                      runSpacing: t.space8,
                      children: [
                        for (final tag in {
                          'Все',
                          ...data.events.expand((event) => event.tags),
                        })
                          FilterChip(
                            label: Text(tr(context, tag)),
                            selected: ui.eventTag == tag,
                            avatar: Icon(
                              Icons.event_rounded,
                              color: ui.eventTag == tag ? t.onAccent : t.accent,
                            ),
                            labelStyle: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: ui.eventTag == tag
                                      ? t.onAccent
                                      : t.readableSecondary,
                                ),
                            onSelected: (_) => ui.setEventTag(tag),
                          ),
                      ],
                    ),
                  SizedBox(height: t.space16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: ui.toggleSort,
                      icon: const Icon(Icons.sort_rounded),
                      label: Text(
                        eventsTab
                            ? (ui.oldestFirst
                                  ? strings(context).feedNewestFirst
                                  : strings(context).feedOldestFirst)
                            : (ui.oldestFirst
                                  ? strings(context).feedOldestFirst
                                  : strings(context).feedNewestFirst),
                      ),
                    ),
                  ),
                  SourceNotice(data: data),
                  SizedBox(height: CampusTokens.of(context).space8),
                  if (eventsTab && events.isEmpty || !eventsTab && news.isEmpty)
                    components.EmptyState(
                      title: tr(context, 'Ничего не найдено'),
                      message: tr(context, 'Найти в ленте'),
                    ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = <Widget>[
                        if (!eventsTab)
                          for (final item in news)
                            components.ListingCard(
                              source: item.imageUrl,
                              badge: item.category,
                              title: item.title,
                              location: item.author ?? item.category,
                              locationIcon: Icons.person_rounded,
                              value: strings(context).readDuration(
                                (item.readMinutes ?? 4).toString(),
                              ),
                              favorite: favorites.contains('news:${item.id}'),
                              onFavorite: () =>
                                  toggleFavorite(context, ref, 'news', item.id),
                              onShare: () =>
                                  _share(item.title, Routes.news, item.id),
                              onMap: () => context.goNamed(
                                Routes.map,
                                queryParameters: {
                                  'building': item.relatedBuildingId ?? '',
                                },
                              ),
                              onTap: () => context.pushNamed(
                                Routes.news,
                                pathParameters: {'id': item.id},
                              ),
                            ),
                        if (eventsTab)
                          for (final event in events)
                            components.ListingCard(
                              source: event.coverUrl,
                              badge: tr(context, 'События'),
                              title: event.title,
                              location: event.location,
                              value:
                                  '${event.startAt.day}.${event.startAt.month}',
                              favorite: favorites.contains('event:${event.id}'),
                              onFavorite: () => toggleFavorite(
                                context,
                                ref,
                                'event',
                                event.id,
                              ),
                              onShare: () =>
                                  _share(event.title, Routes.event, event.id),
                              onMap: () => context.goNamed(
                                Routes.map,
                                queryParameters: {
                                  'building': event.buildingId ?? '',
                                  'room': event.room ?? '',
                                },
                              ),
                              onTap: () => context.pushNamed(
                                Routes.event,
                                pathParameters: {'id': event.id},
                              ),
                            ),
                      ];
                      final t = CampusTokens.of(context);
                      return Wrap(
                        spacing: t.space16,
                        runSpacing: t.space16,
                        children: [
                          for (final card in cards)
                            SizedBox(
                              width: constraints.maxWidth >= t.statRowBreakpoint
                                  ? (constraints.maxWidth - t.space16) / 2
                                  : constraints.maxWidth,
                              child: card,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _share(String title, String route, String id) async {
    final location = GoRouter.of(context)
        .namedLocation(route, pathParameters: {'id': id});
    await Clipboard.setData(ClipboardData(text: '$title\n$location'));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings(context).copiedContent)));
    }
  }
}
