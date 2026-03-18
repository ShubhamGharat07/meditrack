// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'app_colors.dart';

// class AppTextStyles {
//   // Headings
//   static final TextStyle heading1 = GoogleFonts.poppins(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: AppColors.textPrimary,
//   );

//   static final TextStyle heading2 = GoogleFonts.poppins(
//     fontSize: 22,
//     fontWeight: FontWeight.w700,
//     color: AppColors.textPrimary,
//   );

//   static final TextStyle heading3 = GoogleFonts.poppins(
//     fontSize: 20,
//     fontWeight: FontWeight.w600,
//     color: AppColors.textPrimary,
//   );

//   // Body Text
//   static final TextStyle bodyLarge = GoogleFonts.poppins(
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textPrimary,
//   );

//   static final TextStyle bodyMedium = GoogleFonts.poppins(
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textPrimary,
//   );

//   static final TextStyle bodySmall = GoogleFonts.poppins(
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textSecondary,
//   );

//   // Button Text
//   static final TextStyle button = GoogleFonts.poppins(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: AppColors.textWhite,
//   );

//   // Caption
//   static final TextStyle caption = GoogleFonts.poppins(
//     fontSize: 11,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textSecondary,
//   );

//   // Label
//   static final TextStyle label = GoogleFonts.poppins(
//     fontSize: 13,
//     fontWeight: FontWeight.w600,
//     color: AppColors.textPrimary,
//   );
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTextStyles — NO hardcoded colors.
///
/// Colors inherit from DefaultTextStyle (set by MaterialApp/Scaffold
/// based on the current theme). This means styles work correctly in
/// both light and dark mode automatically.
///
/// To apply a specific color: AppTextStyles.heading2.copyWith(color: ...)
///
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ──
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    // No color — inherits from theme
  );

  static final TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // ── Body ──
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // bodySmall uses a muted secondary color. It's readable in both
  // light and dark mode (mid-grey works on both backgrounds).
  // If needed: .copyWith(color: AppColors.of(context).textSecondary)
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF9E9EAA), // neutral grey — works in both modes
  );

  // ── Functional ──

  // Button text is always white (on coloured button backgrounds)
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Caption / Label also inherit — readable in both modes
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF9E9EAA),
  );

  static final TextStyle label = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    // No color — inherits from theme
  );
}
