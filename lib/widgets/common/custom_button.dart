import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.mediumRadius),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.mediumRadius),
            ),
          );

    final child = isLoading
        ? SizedBox(
            width: r.wp(5),
            height: r.wp(5),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined
                  ? (color ?? AppColors.primary)
                  : AppColors.textWhite,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: r.smallIcon,
                  color: isOutlined
                      ? (color ?? AppColors.primary)
                      : (textColor ?? AppColors.textWhite),
                ),
                SizedBox(width: r.wp(2)),
              ],
              Text(
                text,
                style: AppTextStyles.button.copyWith(
                  color: isOutlined
                      ? (color ?? AppColors.primary)
                      : (textColor ?? AppColors.textWhite),
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: r.hp(7),
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
