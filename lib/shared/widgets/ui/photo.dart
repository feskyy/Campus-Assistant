import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

import 'campus_card.dart';
import 'controls.dart';
import 'campus_image.dart';

/// Shared treatment for all photographic content. Overlays remain above the
/// scrim, so badges and controls keep their contrast in both themes.
class CampusPhoto extends StatelessWidget {
  const CampusPhoto({
    super.key,
    required this.image,
    this.semanticLabel,
    this.overlays = const [],
  });
  final ImageProvider<Object> image;
  final String? semanticLabel;
  final List<Widget> overlays;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: image,
            fit: BoxFit.cover,
            semanticLabel: semanticLabel,
            errorBuilder: (_, _, _) => ColoredBox(
              color: t.surface2,
              child: Icon(
                Icons.school_rounded,
                color: t.text,
                size: t.categoryDiameter,
              ),
            ),
          ),
          IgnorePointer(
            child: ColoredBox(
              key: const ValueKey('campus-photo-overlay'),
              color: t.photoOverlay,
            ),
          ),
          ...overlays,
        ],
      ),
    );
  }
}

class PhotoBadge extends StatelessWidget {
  const PhotoBadge({super.key, required this.label, this.accented = false});
  final String label;
  final bool accented;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accented ? t.accent : t.photoControl,
          borderRadius: BorderRadius.circular(t.pillRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.space16,
            vertical: t.space8,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: accented ? t.onAccent : t.photoText),
          ),
        ),
      ),
    );
  }
}

class FloatingMapPill extends StatelessWidget {
  const FloatingMapPill({super.key, required this.onPressed, this.label});
  final VoidCallback? onPressed;
  final String? label;
  @override
  Widget build(BuildContext context) => PillButton(
    label: label ?? strings(context).designMap,
    supportive: true,
    icon: Icons.map_rounded,
    onPressed: onPressed,
  );
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    this.image,
    this.source,
    this.onShare,
    required this.badge,
    required this.title,
    required this.location,
    required this.value,
    required this.onFavorite,
    required this.onMap,
    this.favorite = false,
    this.onTap,
    this.locationIcon = Icons.place_rounded,
  });
  final ImageProvider<Object>? image;
  final String? source;
  final VoidCallback? onShare, onFavorite, onMap, onTap;
  final String badge, title, location, value;
  final bool favorite;
  final IconData locationIcon;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), text = Theme.of(context).textTheme;
    final titleStyle = text.titleMedium!.copyWith(fontWeight: FontWeight.w600);
    final caption = text.bodySmall!;
    final scaler = MediaQuery.textScalerOf(context);
    return CampusCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (source != null || image == null)
                  CampusImage(source: source, semanticLabel: title)
                else
                  CampusPhoto(image: image!, semanticLabel: location),
                Positioned(
                  top: t.space8,
                  left: t.space8,
                  right: t.tapExtent + t.space16,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: PhotoBadge(label: badge, accented: true),
                  ),
                ),
                Positioned(
                  top: t.space8,
                  right: t.space8,
                  child: RoundIconButton(
                    accented: true,
                    icon: favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    tooltip: tr(context, 'Избранное'),
                    onPressed: onFavorite,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space16),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  scaler.scale(titleStyle.fontSize!) * titleStyle.height! * 2,
            ),
            child: Tooltip(
              message: title,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ),
          SizedBox(height: t.space8),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: scaler.scale(caption.fontSize!) * caption.height! * 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  locationIcon,
                  size: t.space16 + t.space4,
                  color: t.readableSecondary,
                ),
                SizedBox(width: t.space8),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: caption,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.space16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: t.space8,
            runSpacing: t.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                value,
                style: caption.copyWith(
                  color: t.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onMap != null) FloatingMapPill(onPressed: onMap),
              if (onShare != null)
                IconButton(
                  onPressed: onShare,
                  tooltip: strings(context).shareContent,
                  icon: Icon(Icons.ios_share_rounded, color: t.accent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
