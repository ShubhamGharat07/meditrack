import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
