// import 'package:flutter/material.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';

// class StatCard extends StatelessWidget {
//   final String title;
//   final int count;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap;

//   const StatCard({
//     super.key,
//     required this.title,
//     required this.count,
//     required this.icon,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: r.cardPadding,
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Icon container
//             Container(
//               padding: EdgeInsets.all(r.wp(2)),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(r.smallRadius),
//               ),
//               child: Icon(icon, color: color, size: r.smallIcon),
//             ),

//             // Count + Title
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('$count', style: AppTextStyles.heading2),
//                 Text(
//                   title,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: r.cardPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(r.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(r.wp(2)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallRadius),
              ),
              child: Icon(icon, color: color, size: r.smallIcon),
            ),

            // Count + Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: AppTextStyles.heading2),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
