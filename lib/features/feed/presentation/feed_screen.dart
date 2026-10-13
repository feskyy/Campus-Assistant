import 'dart:async';

import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/empty_state.dart';
import 'package:campus_assistant/shared/widgets/event_card.dart';
import 'package:campus_assistant/shared/widgets/news_tile.dart';
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
  String query = '', category = 'Все';
  bool eventsTab = false, favoritesOnly = false;
  @override
  void initState() {
    super.initState();
    eventsTab = widget.initialEvents;
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialEvents != widget.initialEvents) {
      eventsTab = widget.initialEvents;
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Новости и события')),
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
                  ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
            final events =
                data.events
                    .where(
                      (e) =>
                          ('${e.title} ${e.description} ${e.location}')
                              .toLowerCase()
                              .contains(query) &&
                          (!favoritesOnly ||
                              favorites.contains('event:${e.id}')),
                    )
                    .toList()
                  ..sort((a, b) => a.startAt.compareTo(b.startAt));
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Новости')),
                      ButtonSegment(value: true, label: Text('События')),
                    ],
                    selected: {eventsTab},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) =>
                        setState(() => eventsTab = value.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Найти в ленте',
                    ),
                    onChanged: (value) {
                      debounce?.cancel();
                      debounce = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          setState(() => query = value.trim().toLowerCase());
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterChip(
                        label: const Text('Избранное'),
                        selected: favoritesOnly,
                        avatar: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 16,
                        ),
                        onSelected: (value) =>
                            setState(() => favoritesOnly = value),
                      ),
                      if (!eventsTab)
                        DropdownButton<String>(
                          value: categories.contains(category)
                              ? category
                              : 'Все',
                          underline: const SizedBox(),
                          items: categories
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => category = value ?? 'Все'),
                        ),
                    ],
                  ),
                  SourceNotice(data: data),
                  const SizedBox(height: 8),
                  if (eventsTab && events.isEmpty || !eventsTab && news.isEmpty)
                    const EmptyState(
                      icon: Icons.search_off_rounded,
                      message: 'Ничего не найдено',
                    ),
                  if (!eventsTab)
                    for (final item in news)
                      NewsTile(
                        item: item,
                        onTap: () => context.push(
                          '/news/${Uri.encodeComponent(item.id)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Избранное',
                          onPressed: () =>
                              toggleFavorite(context, ref, 'news', item.id),
                          icon: Icon(
                            favorites.contains('news:${item.id}')
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                        ),
                      ),
                  if (eventsTab)
                    for (final event in events)
                      EventCard(
                        event: event,
                        onTap: () => context.push(
                          '/event/${Uri.encodeComponent(event.id)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Избранное',
                          onPressed: () =>
                              toggleFavorite(context, ref, 'event', event.id),
                          icon: Icon(
                            favorites.contains('event:${event.id}')
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
