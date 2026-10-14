import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

enum CampusImageKind { news, event, building, teacher, subject }

/// Resolves bundled asset paths or HTTP(S) URLs; a missing optional source is
/// an intentional illustration fallback. Hero tags are owned by the caller.
class CampusImage extends StatelessWidget {
  const CampusImage({
    super.key,
    required this.source,
    this.kind = CampusImageKind.news,
    this.heroTag,
    this.semanticLabel,
    this.fit = BoxFit.cover,
    this.aspectRatio,
    this.cacheManager,
  });
  final String? source;
  final CampusImageKind kind;
  final Object? heroTag;
  final String? semanticLabel;
  final BoxFit fit;
  final double? aspectRatio;
  final BaseCacheManager? cacheManager;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    final value = source?.trim();
    final label = semanticLabel ?? _label(context, kind);
    Widget fallback() => _ImageFallback(kind: kind, label: label);
    Widget content;
    if (value != null && value.startsWith('assets/')) {
      content = Image.asset(
        value,
        fit: fit,
        excludeFromSemantics: true,
        frameBuilder: (_, child, frame, synchronous) =>
            synchronous || frame != null ? child : const _ImageShimmer(),
        errorBuilder: (_, _, _) => fallback(),
      );
    } else {
      final uri = value == null ? null : Uri.tryParse(value);
      if (uri != null &&
          ['https', 'http'].contains(uri.scheme) &&
          uri.host.isNotEmpty) {
        content = CachedNetworkImage(
          imageUrl: value!,
          cacheManager: cacheManager,
          fit: fit,
          fadeInDuration: t.motionDuration(context),
          placeholder: (_, _) => const _ImageShimmer(),
          errorWidget: (_, _, _) => fallback(),
          imageBuilder: (_, provider) =>
              Image(image: provider, fit: fit, excludeFromSemantics: true),
        );
      } else {
        content = fallback();
      }
    }
    final image = Semantics(
      label: label,
      image: true,
      child: AspectRatio(
        aspectRatio:
            aspectRatio ?? (kind == CampusImageKind.teacher ? 1 : 16 / 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(t.fieldRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              IgnorePointer(
                child: ColoredBox(
                  key: const ValueKey('campus-image-dim'),
                  color: t.photoOverlay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}

String _label(BuildContext context, CampusImageKind kind) {
  final l10n = strings(context);
  return switch (kind) {
    CampusImageKind.news => l10n.imageNews,
    CampusImageKind.event => l10n.imageEvent,
    CampusImageKind.building => l10n.imageBuilding,
    CampusImageKind.teacher => l10n.imageTeacher,
    CampusImageKind.subject => l10n.imageSubject,
  };
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.kind, required this.label});
  final CampusImageKind kind;
  final String label;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    final icon = switch (kind) {
      CampusImageKind.news => Icons.article_rounded,
      CampusImageKind.event => Icons.event_rounded,
      CampusImageKind.building => Icons.apartment_rounded,
      CampusImageKind.teacher => Icons.person_rounded,
      CampusImageKind.subject => Icons.menu_book_rounded,
    };
    return DecoratedBox(
      key: const ValueKey('campus-image-error'),
      decoration: BoxDecoration(gradient: t.heroGradient),
      child: Center(
        child: Icon(icon, size: t.categoryDiameter, color: t.accent),
      ),
    );
  }
}

class _ImageShimmer extends StatefulWidget {
  const _ImageShimmer();
  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      animation.stop();
    } else if (!animation.isAnimating) {
      animation.repeat();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Semantics(
      label: strings(context).imageLoading,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, _) => DecoratedBox(
          key: const ValueKey('campus-image-loading'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-3 + animation.value * 6, 0),
              end: Alignment(-1 + animation.value * 6, 0),
              colors: [t.surface2, t.surface, t.surface2],
            ),
          ),
        ),
      ),
    );
  }
}
