import 'package:campus_assistant/features/schedule/presentation/entity_detail_screen.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_block.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/core/presentation/not_found_screen.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/shared/widgets/ui/entity_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.kind, required this.id});
  final String kind, id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kind == Routes.lesson) return EntityDetailScreen(kind: kind, id: id);
    final t = CampusTokens.of(context), l = strings(context);
    final text = Theme.of(context).textTheme;
    final favorite = ref.watch(favoritesProvider).contains('$kind:$id');
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'Подробности'))),
      body: PageBody(
        maxWidth: 800,
        child: DataView(
          builder: (data) {
            final news = kind == Routes.news
                ? data.news.where((e) => e.id == id).firstOrNull
                : null;
            final event = kind == Routes.event
                ? data.events.where((e) => e.id == id).firstOrNull
                : null;
            if (news == null && event == null) return const NotFoundContent();
            final title = news?.title ?? event!.title;
            final buildingId = news?.relatedBuildingId ?? event?.buildingId;
            final building = data.buildings
                .where((b) => b.id == buildingId)
                .firstOrNull;
            Widget metadata(IconData icon, String value) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: t.accent),
                SizedBox(width: t.space8),
                Expanded(child: Text(value)),
              ],
            );
            return ListView(
              padding: EdgeInsets.all(t.space24),
              children: [
                ui.CampusImage(
                  source: news?.imageUrl ?? event?.coverUrl,
                  kind: news != null
                      ? ui.CampusImageKind.news
                      : ui.CampusImageKind.event,
                  semanticLabel: title,
                ),
                SizedBox(height: t.space24),
                Text(
                  news?.category ?? tr(context, 'События'),
                  style: text.labelLarge?.copyWith(color: t.accent),
                ),
                SizedBox(height: t.space8),
                SelectableText(title, style: text.headlineLarge),
                SizedBox(height: t.space16),
                Wrap(
                  spacing: t.space8,
                  runSpacing: t.space8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => toggleFavorite(context, ref, kind, id),
                      icon: Icon(
                        favorite
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                      ),
                      label: Text(
                        tr(
                          context,
                          favorite ? 'Удалить из избранного' : 'В избранное',
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => copyEntityText(
                        context,
                        '$title\n${GoRouter.of(context).namedLocation(kind, pathParameters: {'id': id})}',
                      ),
                      icon: const Icon(Icons.link_rounded),
                      label: Text(l.detailShare),
                    ),
                  ],
                ),
                SizedBox(height: t.space24),
                ui.CampusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      metadata(
                        Icons.calendar_today_rounded,
                        news != null
                            ? formatDayMonth(news.publishedAt)
                            : '${formatDayMonth(event!.startAt)} · ${formatTime(event.startAt)}',
                      ),
                      if (news?.author != null) ...[
                        SizedBox(height: t.space16),
                        metadata(Icons.person_rounded, news!.author!),
                      ],
                      if (news?.readMinutes != null) ...[
                        SizedBox(height: t.space16),
                        metadata(
                          Icons.schedule_rounded,
                          l.readDuration('${news!.readMinutes}'),
                        ),
                      ],
                      if (event != null) ...[
                        SizedBox(height: t.space16),
                        metadata(Icons.place_rounded, event.location),
                        if (event.organizer != null) ...[
                          SizedBox(height: t.space16),
                          metadata(
                            Icons.groups_rounded,
                            '${l.articleOrganizer}: ${event.organizer}',
                          ),
                        ],
                        if (event.capacity != null) ...[
                          SizedBox(height: t.space16),
                          metadata(
                            Icons.people_rounded,
                            '${l.detailCapacity}: ${event.capacity}',
                          ),
                        ],
                        if (event.price != null) ...[
                          SizedBox(height: t.space16),
                          metadata(
                            Icons.payments_rounded,
                            '${l.articlePrice}: ${event.isFree ? l.articleFree : event.price.toString()}',
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                SizedBox(height: t.space24),
                if (news != null) ...[
                  SelectableText(news.summary, style: text.titleMedium),
                  SizedBox(height: t.space24),
                  if (news.blocks.isNotEmpty)
                    for (final block in news.blocks) _ArticleBlock(block: block)
                  else if (news.content != null && news.content != news.summary)
                    SelectableText(news.content!, style: text.bodyLarge),
                ],
                if (event != null) ...[
                  Text(l.articleAbout, style: t.sectionStyle),
                  SizedBox(height: t.space16),
                  SelectableText(event.description, style: text.bodyLarge),
                  SizedBox(height: t.space16),
                  Wrap(
                    spacing: t.space8,
                    runSpacing: t.space8,
                    children: [
                      for (final tag in event.tags)
                        Chip(
                          labelStyle: text.labelMedium?.copyWith(color: t.text),
                          label: Text(tag),
                        ),
                    ],
                  ),
                ],
                if (building != null) ...[
                  SizedBox(height: t.space24),
                  Text(l.detailWhere, style: t.sectionStyle),
                  SizedBox(height: t.space8),
                  Text(building.name),
                  if (building.address != null)
                    Text(building.address!, style: text.bodySmall),
                  SizedBox(height: t.space16),
                  ui.PillButton(
                    label: l.detailMap,
                    icon: Icons.near_me_rounded,
                    onPressed: () => context.goNamed(
                      Routes.map,
                      queryParameters: {
                        'building': building.id,
                        if (event?.room != null) 'room': event!.room!,
                      },
                    ),
                  ),
                ],
                SizedBox(height: t.space24),
                SourceNotice(data: data),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArticleBlock extends StatelessWidget {
  const _ArticleBlock({required this.block});
  final NewsBlock block;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), text = Theme.of(context).textTheme;
    final Widget content = switch (block.type) {
      NewsBlockType.heading => SelectableText(
        block.text ?? '',
        style: t.sectionStyle,
      ),
      NewsBlockType.paragraph => SelectableText(
        block.text ?? '',
        style: text.bodyLarge,
      ),
      NewsBlockType.quote => Container(
        padding: EdgeInsets.all(t.space16),
        decoration: BoxDecoration(
          color: t.surface2,
          border: Border(
            left: BorderSide(color: t.accent, width: t.space4),
          ),
        ),
        child: SelectableText(block.text ?? '', style: text.titleMedium),
      ),
      NewsBlockType.keyFacts => ui.CampusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings(context).articleFacts, style: t.sectionStyle),
            for (final fact in block.items)
              Padding(
                padding: EdgeInsets.only(top: t.space8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: t.readableSupportive,
                    ),
                    SizedBox(width: t.space8),
                    Expanded(child: SelectableText(fact)),
                  ],
                ),
              ),
          ],
        ),
      ),
      NewsBlockType.image => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ui.CampusImage(source: block.imageUrl, semanticLabel: block.caption),
          if (block.caption != null) ...[
            SizedBox(height: t.space8),
            Text(block.caption!, style: text.bodySmall),
          ],
        ],
      ),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: t.space24),
      child: content,
    );
  }
}
