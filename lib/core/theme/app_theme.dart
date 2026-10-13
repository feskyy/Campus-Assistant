import 'package:flutter/material.dart';

/// Campus Everyday: daylight blue and independently composed midnight navy surfaces.
class AppTheme {
  const AppTheme._();
  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);
  static ThemeData _build(bool dark) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF2463D4),
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: Color(dark ? 0xFF91BCFF : 0xFF2463D4),
          onPrimary: Color(dark ? 0xFF092449 : 0xFFFFFFFF),
          primaryContainer: Color(dark ? 0xFF19385F : 0xFFE5F0FF),
          onPrimaryContainer: Color(dark ? 0xFFE5F1FF : 0xFF174578),
          secondary: Color(dark ? 0xFF95D2EE : 0xFF356989),
          secondaryContainer: Color(dark ? 0xFF16384A : 0xFFE4F4FA),
          surface: Color(dark ? 0xFF12243B : 0xFFFFFFFF),
          onSurface: Color(dark ? 0xFFEDF5FF : 0xFF172E48),
          onSurfaceVariant: Color(dark ? 0xFFA7BBD2 : 0xFF536B82),
          surfaceContainerLowest: Color(dark ? 0xFF091525 : 0xFFF3F8FD),
          surfaceContainerLow: Color(dark ? 0xFF162B45 : 0xFFEBF3FC),
          surfaceContainer: Color(dark ? 0xFF1C334E : 0xFFE4EEF9),
          surfaceContainerHighest: Color(dark ? 0xFF29445F : 0xFFDAE8F6),
          outline: Color(dark ? 0xFF718BA6 : 0xFF8299B0),
          outlineVariant: Color(dark ? 0xFF2A4058 : 0xFFDCE8F3),
          error: Color(dark ? 0xFFF3A4A4 : 0xFFB54040),
        );
    final text =
        TextTheme(
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.0,
            height: 1.15,
          ),
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            height: 1.2,
          ),
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            height: 1.25,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            height: 1.4,
          ),
          titleSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.55),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
          bodySmall: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: scheme.onSurfaceVariant,
          ),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ).apply(
          fontFamily: 'Inter',
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: text,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: dark ? 0 : 1,
        shadowColor: scheme.primary.withValues(alpha: 0.08),
        margin: const EdgeInsets.only(bottom: 12),
        shape: shape.copyWith(
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: shape,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        height: 80,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: scheme.onSurfaceVariant,
        shape: shape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }
}
