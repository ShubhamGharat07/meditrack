// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';

// class LoadingIndicator extends StatelessWidget {
//   final Color? color;
//   final bool fullScreen;

//   const LoadingIndicator({super.key, this.color, this.fullScreen = false});

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     final indicator = CircularProgressIndicator(
//       color: color ?? AppColors.primary,
//       strokeWidth: 2.5,
//     );

//     if (fullScreen) {
//       return Scaffold(
//         backgroundColor: AppColors.background,
//         body: Center(child: indicator),
//       );
//     }

//     return Center(
//       child: Padding(padding: EdgeInsets.all(r.wp(4)), child: indicator),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final bool fullScreen;

  const LoadingIndicator({super.key, this.color, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    final indicator = CircularProgressIndicator(
      color: color ?? AppColors.primary,
      strokeWidth: 2.5,
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: indicator),
      );
    }

    return Center(
      child: Padding(padding: EdgeInsets.all(r.wp(4)), child: indicator),
    );
  }
}
