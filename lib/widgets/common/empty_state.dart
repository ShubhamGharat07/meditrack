// import 'package:flutter/material.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';

// class EmptyState extends StatelessWidget {
//   final String message;
//   final IconData icon;
//   final String? buttonText;
//   final VoidCallback? onButtonTap;

//   const EmptyState({
//     super.key,
//     required this.message,
//     required this.icon,
//     this.buttonText,
//     this.onButtonTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(r.wp(8)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon
//             Container(
//               width: r.wp(25),
//               height: r.wp(25),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: r.wp(12),
//                 color: AppColors.primary.withOpacity(0.5),
//               ),
//             ),

//             SizedBox(height: r.mediumSpace),

//             // Message
//             Text(
//               message,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),

//             // Optional button
//             if (buttonText != null && onButtonTap != null) ...[
//               SizedBox(height: r.mediumSpace),
//               ElevatedButton(
//                 onPressed: onButtonTap,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(r.mediumRadius),
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: r.wp(8),
//                     vertical: r.hp(1.5),
//                   ),
//                 ),
//                 child: Text(buttonText!, style: AppTextStyles.button),
//               ),
//             ],
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

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.wp(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: r.wp(25),
              height: r.wp(25),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: r.wp(12),
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),

            SizedBox(height: r.mediumSpace),

            // Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional button
            if (buttonText != null && onButtonTap != null) ...[
              SizedBox(height: r.mediumSpace),
              ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.mediumRadius),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(8),
                    vertical: r.hp(1.5),
                  ),
                ),
                child: Text(buttonText!, style: AppTextStyles.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
