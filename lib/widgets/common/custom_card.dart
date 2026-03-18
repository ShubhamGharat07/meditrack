// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';

// class CustomCard extends StatelessWidget {
//   final Widget child;
//   final VoidCallback? onTap;
//   final Color? color;
//   final EdgeInsets? padding;
//   final double? borderRadius;
//   final bool hasShadow;

//   const CustomCard({
//     super.key,
//     required this.child,
//     this.onTap,
//     this.color,
//     this.padding,
//     this.borderRadius,
//     this.hasShadow = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: padding ?? r.cardPadding,
//         decoration: BoxDecoration(
//           color: color ?? AppColors.surface,
//           borderRadius: BorderRadius.circular(borderRadius ?? r.mediumRadius),
//           boxShadow: hasShadow
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : null,
//         ),
//         child: child,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../core/utils/responsive_helper.dart';

/// CustomCard — uses Theme.of(context).colorScheme.surface
/// so it automatically adapts to light/dark mode.
class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.borderRadius,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use provided color, or auto theme-aware surface
    final bgColor = color ?? scheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? r.cardPadding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius ?? r.mediumRadius),
          border: isDark
              ? Border.all(color: scheme.outline.withOpacity(0.15), width: 0.5)
              : null,
          boxShadow: hasShadow && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
