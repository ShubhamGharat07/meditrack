// // import 'package:flutter/material.dart';

// // class ResponsiveHelper {
// //   final BuildContext context;
// //   ResponsiveHelper(this.context);

// //   // Screen dimensions
// //   double get width => MediaQuery.of(context).size.width;
// //   double get height => MediaQuery.of(context).size.height;

// //   // Device type
// //   bool get isMobile => width < 600;
// //   bool get isTablet => width >= 600;

// //   // Width & Height percentage
// //   double wp(double percent) => width * percent / 100;
// //   double hp(double percent) => height * percent / 100;

// //   // Responsive font size
// //   double sp(double size) => size * width / 375;

// //   // Common padding
// //   EdgeInsets get pagePadding =>
// //       EdgeInsets.symmetric(horizontal: wp(6), vertical: hp(2));

// //   // Common spacing
// //   double get smallSpace => hp(1);
// //   double get mediumSpace => hp(2);
// //   double get largeSpace => hp(4);

// //   // Common radius
// //   double get smallRadius => wp(2);
// //   double get mediumRadius => wp(4);
// //   double get largeRadius => wp(6);

// //   // Icon sizes
// //   double get smallIcon => wp(5);
// //   double get mediumIcon => wp(8);
// //   double get largeIcon => wp(15);

// //   // Grid columns
// //   int get gridColumns => isMobile ? 2 : 3;
// // }

// import 'package:flutter/material.dart';

// class ResponsiveHelper {
//   final BuildContext context;
//   ResponsiveHelper(this.context);

//   // Screen dimensions
//   double get width => MediaQuery.of(context).size.width;
//   double get height => MediaQuery.of(context).size.height;

//   // Device type
//   bool get isMobile => width < 600;
//   bool get isTablet => width >= 600;

//   // Width & Height percentage
//   double wp(double percent) => width * percent / 100;
//   double hp(double percent) => height * percent / 100;

//   // Responsive font size
//   double sp(double size) => size * width / 375;

//   // Common padding
//   EdgeInsets get pagePadding =>
//       EdgeInsets.symmetric(horizontal: wp(6), vertical: hp(2));
//   EdgeInsets get cardPadding => EdgeInsets.all(wp(4));

//   // Common spacing
//   double get smallSpace => hp(1);
//   double get mediumSpace => hp(2);
//   double get largeSpace => hp(4);

//   // Common radius
//   double get smallRadius => wp(2);
//   double get mediumRadius => wp(4);
//   double get largeRadius => wp(6);

//   // Icon sizes
//   double get smallIcon => wp(5);
//   double get mediumIcon => wp(8);
//   double get largeIcon => wp(15);

//   // Grid columns
//   int get gridColumns => isMobile ? 2 : 3;
// }

import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  ResponsiveHelper(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isLargeTablet => width >= 900;

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;

  // ── FIX 1: sp() — tablet pe text giant nahi hoga ──
  // Clamp: minimum 375px base, maximum 600px base
  double sp(double size) {
    final clampedWidth = width.clamp(375, 600).toDouble();
    return size * clampedWidth / 375;
  }

  // ── FIX 2: Icon sizes — fixed max caps ──
  double get smallIcon => wp(5).clamp(18, 24).toDouble();
  double get mediumIcon => wp(8).clamp(28, 36).toDouble();
  double get largeIcon => wp(15).clamp(50, 72).toDouble();

  // ── FIX 3: Padding — tablet pe zyada nahi ──
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: wp(6).clamp(16, 48).toDouble(),
    vertical: hp(2).clamp(12, 28).toDouble(),
  );
  EdgeInsets get cardPadding => EdgeInsets.all(wp(4).clamp(12, 20).toDouble());

  // Spacing — mostly fine, small caps added
  double get smallSpace => hp(1).clamp(8, 14).toDouble();
  double get mediumSpace => hp(2).clamp(14, 24).toDouble();
  double get largeSpace => hp(4).clamp(24, 40).toDouble();

  // Radius — fine as is
  double get smallRadius => wp(2).clamp(6, 12).toDouble();
  double get mediumRadius => wp(4).clamp(10, 16).toDouble();
  double get largeRadius => wp(6).clamp(16, 24).toDouble();

  // Grid — 3 tiers
  int get gridColumns => isMobile
      ? 2
      : isTablet
      ? 3
      : 4;
}
