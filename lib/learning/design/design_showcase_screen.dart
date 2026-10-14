import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;

class DesignShowcaseScreen extends StatelessWidget {
  const DesignShowcaseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    final l10n = strings(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.designTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(t.space16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = MediaQuery.sizeOf(context).width >= t.wideBreakpoint;
              final panelWidth = wide
                  ? (constraints.maxWidth - t.space16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: t.space16,
                runSpacing: t.space24,
                children: [
                  for (final theme in [AppTheme.light, AppTheme.dark])
                    SizedBox(
                      width: panelWidth,
                      child: Theme(
                        data: theme,
                        child: Builder(
                          builder: (context) {
                            final panelTokens = CampusTokens.of(context);
                            return ColoredBox(
                              color: panelTokens.background,
                              child: Padding(
                                padding: EdgeInsets.all(panelTokens.space16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      theme.brightness == Brightness.light
                                          ? l10n.designLight
                                          : l10n.designDark,
                                      style: panelTokens.sectionStyle,
                                    ),
                                    SizedBox(height: panelTokens.space16),
                                    const DesignComponentGallery(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Both the screen and the small-width tests use the complete interactive set.
class DesignComponentGallery extends StatefulWidget {
  const DesignComponentGallery({super.key});
  @override
  State<DesignComponentGallery> createState() => _DesignComponentGalleryState();
}

class _DesignComponentGalleryState extends State<DesignComponentGallery> {
  int category = 0;
  bool events = false, favorite = false;
  void feedback() => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(strings(context).designFeedback)));
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l10n = strings(context);
    const image = AssetImage('assets/images/design_campus.jpg');
    final components = <Widget>[
      ui.HeroBanner(
        title: l10n.designIntro,
        subtitle: l10n.designIntroBody,
        action: ui.PillButton(
          label: l10n.designRoute,
          onPressed: feedback,
          icon: Icons.near_me_rounded,
        ),
      ),
      ui.CampusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.designCardTitle, style: t.sectionStyle),
            SizedBox(height: t.space8),
            Text(l10n.designCardBody),
          ],
        ),
      ),
      ui.SectionHeader(title: l10n.designCategories, onAll: feedback),
      Wrap(
        spacing: t.space8,
        runSpacing: t.space16,
        children: [
          ui.CategoryChip(
            icon: Icons.school_rounded,
            label: l10n.designStudy,
            selected: category == 0,
            onTap: () => setState(() => category = 0),
          ),
          ui.CategoryChip(
            icon: Icons.event_rounded,
            label: l10n.designEvents,
            selected: category == 1,
            onTap: () => setState(() => category = 1),
          ),
          ui.CategoryChip(
            icon: Icons.apartment_rounded,
            label: l10n.designPlaces,
            selected: category == 2,
            onTap: () => setState(() => category = 2),
          ),
        ],
      ),
      ui.SectionHeader(title: l10n.designFilters, onAll: feedback),
      ui.SegmentedPill<bool>(
        options: [
          ui.SegmentOption(value: false, label: l10n.designNews),
          ui.SegmentOption(value: true, label: l10n.designEvents),
        ],
        value: events,
        onChanged: (value) => setState(() => events = value),
      ),
      Wrap(
        spacing: t.space8,
        runSpacing: t.space8,
        children: [
          ui.PillButton(
            label: l10n.designRoute,
            icon: Icons.near_me_rounded,
            onPressed: feedback,
          ),
          ui.PillButton(
            label: l10n.designSort,
            icon: Icons.sort_rounded,
            variant: ui.PillButtonVariant.outlined,
            onPressed: feedback,
          ),
        ],
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(t.cardRadius),
        child: ui.CampusPhoto(
          image: image,
          semanticLabel: l10n.designPhoto,
          overlays: [
            Positioned(
              top: t.space16,
              left: t.space16,
              right: t.tapExtent + t.space24,
              child: ui.PhotoBadge(label: l10n.designBadge),
            ),
            Positioned(
              top: t.space8,
              right: t.space8,
              child: ui.RoundIconButton(
                icon: Icons.share_rounded,
                tooltip: l10n.designShare,
                onPressed: feedback,
              ),
            ),
            Positioned(
              bottom: t.space8,
              left: t.space16,
              right: t.space16,
              child: Center(child: ui.FloatingMapPill(onPressed: feedback)),
            ),
          ],
        ),
      ),
      ui.SectionHeader(title: l10n.designStats, onAll: feedback),
      ui.StatTile(
        icon: Icons.groups_rounded,
        value: '120',
        label: l10n.designSeats,
      ),
      ui.StatRow(
        tiles: [
          ui.StatTile(
            icon: Icons.groups_rounded,
            value: '120',
            label: l10n.designSeats,
          ),
          ui.StatTile(
            icon: Icons.stairs_rounded,
            value: '2',
            label: l10n.designFloor,
          ),
          ui.StatTile(
            icon: Icons.schedule_rounded,
            value: '90',
            label: l10n.designDuration,
          ),
          ui.StatTile(
            icon: Icons.meeting_room_rounded,
            value: '214',
            label: l10n.designRoom,
          ),
        ],
      ),
      ui.ListingCard(
        image: image,
        badge: l10n.designBadge,
        title: l10n.designListing,
        location: l10n.designLocation,
        value: l10n.designTime,
        favorite: favorite,
        onFavorite: () => setState(() => favorite = !favorite),
        onMap: feedback,
        onTap: feedback,
      ),
      ui.SectionHeader(title: l10n.designStates, onAll: feedback),
      const ui.BottomSheetHandle(),
      ui.EmptyState(
        title: l10n.designEmptyTitle,
        message: l10n.designEmptyBody,
      ),
      ui.ErrorState(
        title: l10n.designErrorTitle,
        message: l10n.designErrorBody,
        onRetry: feedback,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < components.length; index++) ...[
          if (index > 0) SizedBox(height: t.space16),
          components[index],
        ],
      ],
    );
  }
}
