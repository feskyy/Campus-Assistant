import 'package:flutter/material.dart';

/// Shared composition tokens. Each palette has its own hero treatment.
abstract final class CampusStyle {
  static const double cardRadius = 20;
  static const double heroRadius = 28;
  static const double pageInset = 20;
  static const double sectionGap = 24;
  static LinearGradient hero(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const LinearGradient(
          colors: [Color(0xFF15385F), Color(0xFF102740)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFE2F0FF), Color(0xFFF1F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
  static Color practice(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8FD4B1)
      : const Color(0xFF287557);
  static Color laboratory(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFC3ACF1)
      : const Color(0xFF78569B);
}
