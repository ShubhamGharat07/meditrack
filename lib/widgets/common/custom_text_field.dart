// import 'package:flutter/material.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import '../../core/constants/app_colors.dart';

// import '../../core/utils/responsive_helper.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData? prefixIcon;
//   final IconData? suffixIcon;
//   final VoidCallback? onSuffixTap;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final int maxLines;
//   final bool readOnly;
//   final VoidCallback? onTap;
//   final TextCapitalization textCapitalization;

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.onSuffixTap,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.maxLines = 1,
//     this.readOnly = false,
//     this.onTap,
//     this.textCapitalization = TextCapitalization.none,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       maxLines: maxLines,
//       readOnly: readOnly,
//       onTap: onTap,
//       textCapitalization: textCapitalization,
//       style: AppTextStyles.bodyMedium,
//       decoration: InputDecoration(
//         labelText: label,

//         hintStyle: AppTextStyles.bodySmall.copyWith(
//           color: AppColors.textSecondary.withOpacity(0.5),
//         ),
//         prefixIcon: prefixIcon != null
//             ? Icon(
//                 prefixIcon,
//                 size: r.smallIcon,
//                 color: AppColors.textSecondary,
//               )
//             : null,
//         suffixIcon: suffixIcon != null
//             ? IconButton(
//                 icon: Icon(
//                   suffixIcon,
//                   size: r.smallIcon,
//                   color: AppColors.textSecondary,
//                 ),
//                 onPressed: onSuffixTap,
//               )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           borderSide: const BorderSide(color: AppColors.textSecondary),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           borderSide: BorderSide(
//             color: AppColors.textSecondary.withOpacity(0.3),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           borderSide: const BorderSide(color: AppColors.error),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(r.mediumRadius),
//           borderSide: const BorderSide(color: AppColors.error, width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: r.wp(4),
//           vertical: r.hp(2),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

/// CustomTextField — borders and icons use Theme.of(context).colorScheme
/// so it works in both light and dark mode automatically.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final String? hintText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final scheme = Theme.of(context).colorScheme;

    // Border colors from scheme — adapts to dark/light
    final borderColor = scheme.outline.withOpacity(0.3);
    final focusBorderColor = AppColors.primary;
    final errorBorderColor = AppColors.error;
    final iconColor = scheme.onSurfaceVariant;
    final radius = r.mediumRadius;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      // Inherit text color from theme — no explicit color needed
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: AppTextStyles.bodySmall,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: r.smallIcon, color: iconColor)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, size: r.smallIcon, color: iconColor),
                onPressed: onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: errorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: errorBorderColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: r.wp(4),
          vertical: r.hp(2),
        ),
      ),
    );
  }
}
