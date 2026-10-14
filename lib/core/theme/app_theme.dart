import 'package:flutter/material.dart';

import 'campus_tokens.dart';

class AppTheme {
  const AppTheme._();
  static ThemeData get light => _build(CampusTokens.light);
  static ThemeData get dark => _build(CampusTokens.dark);
  static ThemeData _build(CampusTokens tokens) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: tokens.accent,
          brightness: tokens.isDark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: tokens.accent,
          onPrimary: tokens.onAccent,
          primaryContainer: tokens.surface2,
          onPrimaryContainer: tokens.text,
          secondary: tokens.supportive,
          onSecondary: tokens.onSupportive,
          secondaryContainer: tokens.surface2,
          onSecondaryContainer: tokens.text,
          tertiary: tokens.accent,
          onTertiary: tokens.onAccent,
          tertiaryContainer: tokens.surface2,
          onTertiaryContainer: tokens.text,
          surface: tokens.surface,
          onSurface: tokens.text,
          onSurfaceVariant: tokens.readableSecondary,
          surfaceContainerLowest: tokens.background,
          surfaceContainerLow: tokens.surface,
          surfaceContainer: tokens.surface2,
          surfaceContainerHigh: tokens.surface2,
          surfaceContainerHighest: tokens.surface2,
          outline: tokens.readableSecondary,
          outlineVariant: tokens.border,
          error: tokens.error,
          onError: tokens.onStatus,
          errorContainer: tokens.surface2,
          onErrorContainer: tokens.text,
          surfaceTint: tokens.transparent,
        );
    final text =
        TextTheme(
              headlineLarge: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              headlineMedium: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              headlineSmall: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
              // Legacy DropdownButton uses titleMedium. Keep its compatible
              // size; new section headings use CampusTokens.sectionStyle.
              titleMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              titleSmall: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              bodyLarge: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              bodyMedium: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              bodySmall: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: tokens.readableSecondary,
              ),
              labelLarge: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              labelMedium: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: tokens.readableSecondary,
              ),
              labelSmall: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            )
            .apply(
              fontFamily: 'Inter',
              bodyColor: tokens.text,
              displayColor: tokens.text,
            )
            .copyWith(
              bodySmall: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: tokens.readableSecondary,
              ),
              labelMedium: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: tokens.readableSecondary,
              ),
            );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.cardRadius),
      side: tokens.cardBorder,
    );
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.pillRadius),
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.fieldRadius),
      borderSide: BorderSide(color: tokens.border),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [tokens],
      fontFamily: 'Inter',
      textTheme: text,
      scaffoldBackgroundColor: tokens.background,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.text,
        surfaceTintColor: tokens.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        toolbarHeight: tokens.categoryDiameter,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        surfaceTintColor: tokens.transparent,
        elevation: tokens.isDark ? 0 : 1,
        shadowColor: tokens.photoInk.withValues(alpha: 0.06),
        margin: EdgeInsets.only(bottom: tokens.space16),
        shape: cardShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        contentPadding: EdgeInsets.all(tokens.space16),
        hintStyle: text.bodyMedium?.copyWith(color: tokens.readableSecondary),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: tokens.accent),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(tokens.tapExtent, tokens.tapExtent),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space16,
            vertical: tokens.space8,
          ),
          shape: pillShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.surface,
          minimumSize: Size(tokens.tapExtent, tokens.tapExtent),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space16,
            vertical: tokens.space8,
          ),
          shape: pillShape,
          side: BorderSide(color: tokens.accent),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(tokens.tapExtent, tokens.tapExtent),
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surface,
        selectedColor: tokens.accent,
        side: BorderSide(color: tokens.border),
        shape: pillShape,
        labelStyle: WidgetStateTextStyle.resolveWith(
          (states) => text.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? tokens.onAccent
                : tokens.readableSecondary,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space4,
          vertical: tokens.space8,
        ),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(text.labelMedium)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: tokens.transparent,
        height: tokens.categoryDiameter + tokens.space16,
        indicatorColor: tokens.accent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? tokens.onAccent
                : tokens.secondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? tokens.accent
                : tokens.secondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: tokens.accent,
        selectedIconTheme: IconThemeData(color: tokens.onAccent),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: tokens.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.cardRadius),
          ),
          side: tokens.cardBorder,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.accent,
        linearTrackColor: tokens.surface2,
        circularTrackColor: tokens.surface2,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: tokens.transparent,
        shape: cardShape,
        headerBackgroundColor: tokens.surface2,
        headerForegroundColor: tokens.text,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: tokens.hairline,
        space: tokens.hairline,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space4,
        ),
        iconColor: tokens.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: tokens.transparent,
        shape: cardShape,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: cardShape,
      ),
    );
  }
}
