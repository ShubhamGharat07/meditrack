import 'package:flutter/material.dart';

/// AppColors — Two-layer design:
///
/// 1. Static brand colors (primary, secondary, error, etc.)
///    → Same in both modes. Access directly: AppColors.primary
///
/// 2. Semantic colors (background, surface, text)
///    → Theme-aware. Access via: AppColors.of(context).background
///
class AppColors {
  AppColors._();

  // ── Brand colors — static, same in both modes ──
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);

  static const Color secondary = Color(0xFF26C6DA);
  static const Color secondaryLight = Color(0xFF80DEEA);
  static const Color secondaryDark = Color(0xFF00ACC1);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF1E88E5);

  // Priority
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Always-white (for text on colored backgrounds, icons on primary, etc.)
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Legacy static access — kept for backward compat ──
  // These are LIGHT-MODE values. Prefer AppColors.of(context) in new code.
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color offline = Color(0xFFE53935);

  // ── Theme-aware semantic colors ──
  static _AppSemanticColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _AppSemanticColors._dark() : _AppSemanticColors._light();
  }
}

class _AppSemanticColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant; // slightly elevated surface (e.g. bottom sheets)
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color cardShadow;

  _AppSemanticColors._light()
    : background = const Color(0xFFF5F7FA),
      surface = const Color(0xFFFFFFFF),
      surfaceVariant = const Color(0xFFF0F4FF),
      textPrimary = const Color(0xFF212121),
      textSecondary = const Color(0xFF757575),
      divider = const Color(0xFFE0E0E0),
      cardShadow = const Color(0x0D000000);

  _AppSemanticColors._dark()
    : background = const Color(0xFF121212),
      surface = const Color(0xFF1E1E2E),
      surfaceVariant = const Color(0xFF252535),
      textPrimary = const Color(0xFFE8E8F0),
      textSecondary = const Color(0xFF9E9EAA),
      divider = const Color(0xFF2C2C3E),
      cardShadow = const Color(0x33000000);
}
