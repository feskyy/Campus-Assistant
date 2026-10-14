import 'package:flutter/material.dart';

@immutable
class CampusTokens extends ThemeExtension<CampusTokens> {
  const CampusTokens({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.secondary,
    required this.accent,
    required this.onAccent,
    required this.heroStart,
    required this.heroEnd,
    this.success = const Color(0xFF12B76A),
    this.warning = const Color(0xFFF79009),
    this.error = const Color(0xFFF04438),
    this.cardRadius = 24,
    this.fieldRadius = 16,
    this.pillRadius = 999,
    this.space4 = 4,
    this.space8 = 8,
    this.space16 = 16,
    this.space24 = 24,
  });
  final bool isDark;
  final Color background,
      surface,
      surface2,
      border,
      text,
      secondary,
      accent,
      onAccent;
  final Color success, warning, error, heroStart, heroEnd;
  final double cardRadius,
      fieldRadius,
      pillRadius,
      space4,
      space8,
      space16,
      space24;
  static const light = CampusTokens(
    isDark: false,
    background: Color(0xFFF7F8FC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEEF0F7),
    border: Color(0xFFE5EAF2),
    text: Color(0xFF172033),
    secondary: Color(0xFF63738A),
    accent: Color(0xFF635BDB),
    onAccent: Color(0xFFFFFFFF),
    heroStart: Color(0xFFEEEAFE),
    heroEnd: Color(0xFFE7E2FC),
  );
  static const dark = CampusTokens(
    isDark: true,
    background: Color(0xFF0B1020),
    surface: Color(0xFF141B2D),
    surface2: Color(0xFF1B253A),
    border: Color(0xFF2A3448),
    text: Color(0xFFF8FAFC),
    secondary: Color(0xFF94A3B8),
    accent: Color(0xFF8B7CFF),
    onAccent: Color(0xFF08142E),
    heroStart: Color(0xFF252344),
    heroEnd: Color(0xFF1B2036),
  );
  static CampusTokens of(BuildContext context) =>
      Theme.of(context).extension<CampusTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);
  Color get transparent => const Color(0x00000000);
  Color get photoInk => const Color(0xFF000000);
  Color get photoText => const Color(0xFFFFFFFF);
  Color get photoControl => photoInk.withValues(alpha: 0.72);
  Color get photoOverlay => photoInk.withValues(alpha: isDark ? 0.10 : 0);
  // Strengthen the secondary role on tinted surfaces to preserve AA contrast.
  Color get readableSecondary => isDark
      ? secondary
      : Color.alphaBlend(photoInk.withValues(alpha: 0.08), secondary);
  Color get supportive =>
      isDark ? const Color(0xFF4FD1C5) : const Color(0xFF0F9D92);
  Color get onSupportive => const Color(0xFF08142E);
  Color get readableSupportive => isDark ? supportive : const Color(0xFF08776F);
  Duration motionDuration(BuildContext context) =>
      (MediaQuery.maybeDisableAnimationsOf(context) ??
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .disableAnimations)
      ? Duration.zero
      : const Duration(milliseconds: 180);
  Color get onStatus => const Color(0xFF08142E);
  TextStyle get sectionStyle => TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: text,
  );
  double get wideBreakpoint => 840;
  double get statRowBreakpoint => 600;
  double get compactListingWidth => 280;
  double get listingWidth => 320;
  double get compactBreakpoint => 400;
  double get categoryDiameter => 64;
  double get tapExtent => 48;
  double get hairline => 1;
  List<BoxShadow> get shadows => isDark
      ? const []
      : [
          BoxShadow(
            color: photoInk.withValues(alpha: 0.06),
            blurRadius: space24,
            offset: Offset(0, space8),
          ),
        ];
  BorderSide get cardBorder =>
      isDark ? BorderSide(color: border, width: hairline) : BorderSide.none;
  LinearGradient get heroGradient => LinearGradient(
    colors: [heroStart, heroEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  @override
  CampusTokens copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? text,
    Color? secondary,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? error,
    Color? heroStart,
    Color? heroEnd,
    double? cardRadius,
    double? fieldRadius,
    double? pillRadius,
    double? space4,
    double? space8,
    double? space16,
    double? space24,
  }) => CampusTokens(
    isDark: isDark ?? this.isDark,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    border: border ?? this.border,
    text: text ?? this.text,
    secondary: secondary ?? this.secondary,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    heroStart: heroStart ?? this.heroStart,
    heroEnd: heroEnd ?? this.heroEnd,
    cardRadius: cardRadius ?? this.cardRadius,
    fieldRadius: fieldRadius ?? this.fieldRadius,
    pillRadius: pillRadius ?? this.pillRadius,
    space4: space4 ?? this.space4,
    space8: space8 ?? this.space8,
    space16: space16 ?? this.space16,
    space24: space24 ?? this.space24,
  );
  @override
  CampusTokens lerp(covariant CampusTokens? other, double t) {
    if (other == null) {
      return this;
    }
    double mix(double a, double b) => a + (b - a) * t;
    return CampusTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      cardRadius: mix(cardRadius, other.cardRadius),
      fieldRadius: mix(fieldRadius, other.fieldRadius),
      pillRadius: mix(pillRadius, other.pillRadius),
      space4: mix(space4, other.space4),
      space8: mix(space8, other.space8),
      space16: mix(space16, other.space16),
      space24: mix(space24, other.space24),
    );
  }
}
