import 'package:flutter/material.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';

/// Presentation contract; implementations only report selected building IDs.
abstract class CampusMapView extends StatelessWidget {
  const CampusMapView({
    super.key,
    required this.buildings,
    required this.selectedId,
    required this.onSelected,
  });
  final List<Building> buildings;
  final String? selectedId;
  final ValueChanged<String> onSelected;
}

class CampusPlanView extends CampusMapView {
  const CampusPlanView({
    super.key,
    required super.buildings,
    required super.selectedId,
    required super.onSelected,
    this.interactive = true,
    this.compact = false,
  });
  final bool interactive, compact;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      panEnabled: interactive,
      scaleEnabled: interactive,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerWidth = compact
              ? t.tapExtent
              : ((constraints.maxWidth - t.space16 * 2) / 2)
                    .clamp(t.tapExtent, t.listingWidth / 2)
                    .toDouble();
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: CampusPlanPainter(t, buildings)),
              for (final (index, b) in buildings.indexed)
                Positioned(
                  left: ((b.x ?? .5) * constraints.maxWidth)
                      .clamp(
                        markerWidth / 2,
                        constraints.maxWidth - markerWidth / 2,
                      )
                      .toDouble(),
                  top: ((b.y ?? .5) * constraints.maxHeight)
                      .clamp(
                        markerWidth / 2,
                        constraints.maxHeight - markerWidth / 2,
                      )
                      .toDouble(),
                  child: FractionalTranslation(
                    translation: const Offset(-.5, -.5),
                    child: Semantics(
                      selected: b.id == selectedId,
                      button: true,
                      label: b.name,
                      child: compact
                          ? IconButton.filled(
                              tooltip: b.name,
                              style: IconButton.styleFrom(
                                minimumSize: Size(t.tapExtent, t.tapExtent),
                                backgroundColor: b.id == selectedId
                                    ? t.accent
                                    : t.surface,
                                foregroundColor: b.id == selectedId
                                    ? t.onAccent
                                    : t.text,
                                side: BorderSide(color: t.border),
                              ),
                              onPressed: () => onSelected(b.id),
                              icon: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: b.id == selectedId
                                          ? t.onAccent
                                          : t.text,
                                    ),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: markerWidth,
                                  ),
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: b.id == selectedId
                                          ? t.onStatus
                                          : t.surface,
                                      foregroundColor: b.id == selectedId
                                          ? t.photoText
                                          : t.text,
                                      padding: EdgeInsets.all(t.space8),
                                    ),
                                    onPressed: () => onSelected(b.id),
                                    child: Text(
                                      b.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: t.space8,
                                  height: t.space8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: b.id == selectedId
                                        ? t.onStatus
                                        : t.accent,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CampusPlanPainter extends CustomPainter {
  CampusPlanPainter(this.tokens, this.buildings);
  final CampusTokens tokens;
  final List<Building> buildings;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = tokens.surface2;
    canvas.drawRect(Offset.zero & size, p);
    p.color = tokens.success.withValues(alpha: 0.14);
    for (final rect in [
      const Rect.fromLTWH(.05, .08, .28, .25),
      const Rect.fromLTWH(.65, .6, .3, .3),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left * size.width,
            rect.top * size.height,
            rect.width * size.width,
            rect.height * size.height,
          ),
          Radius.circular(tokens.cardRadius),
        ),
        p,
      );
    }
    p
      ..color = tokens.border
      ..strokeWidth = tokens.space24
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * .5),
      Offset(size.width, size.height * .5),
      p,
    );
    canvas.drawLine(
      Offset(size.width * .5, 0),
      Offset(size.width * .5, size.height),
      p,
    );
    p
      ..style = PaintingStyle.fill
      ..color = tokens.accent.withValues(alpha: .15);
    for (final b in buildings) {
      final center = Offset(
        (b.x ?? .5) * size.width,
        (b.y ?? .5) * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: size.width * .15,
            height: size.height * .1,
          ),
          Radius.circular(tokens.space8),
        ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CampusPlanPainter old) =>
      old.tokens != tokens || old.buildings != buildings;
}
