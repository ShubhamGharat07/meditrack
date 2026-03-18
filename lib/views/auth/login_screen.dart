// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:meditrack/core/constants/app_string.dart';
// // import 'package:meditrack/core/constants/app_text_style.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/utils/responsive_helper.dart';
// // import '../../providers/auth_provider.dart';
// // import '../../routes/app_routes.dart';

// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }

// // class _LoginScreenState extends State<LoginScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   bool _obscurePassword = true;

// //   // Local loading — AuthProvider ke isLoading pe depend nahi karte
// //   // Kyunki AuthProvider.notifyListeners() router ko trigger karta tha
// //   bool _isLoading = false;

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _login() async {
// //     if (!_formKey.currentState!.validate()) return;

// //     // Local state se loading — provider ke notifyListeners() se
// //     // router disturb nahi hoga
// //     setState(() => _isLoading = true);

// //     final success = await context.read<AuthProvider>().loginWithEmail(
// //       _emailController.text.trim(),
// //       _passwordController.text.trim(),
// //     );

// //     if (!mounted) return;
// //     setState(() => _isLoading = false);

// //     if (success) {
// //       // Direct dashboard — koi router redirect nahi, koi splash nahi
// //       context.go(AppRoutes.dashboard);
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(context.read<AuthProvider>().errorMessage),
// //           backgroundColor: AppColors.error,
// //         ),
// //       );
// //     }
// //   }

// //   Future<void> _loginWithGoogle() async {
// //     setState(() => _isLoading = true);

// //     final success = await context.read<AuthProvider>().loginWithGoogle();

// //     if (!mounted) return;
// //     setState(() => _isLoading = false);

// //     if (success) {
// //       context.go(AppRoutes.dashboard);
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(context.read<AuthProvider>().errorMessage),
// //           backgroundColor: AppColors.error,
// //         ),
// //       );
// //     }
// //   }

// //   Future<void> _forgotPassword() async {
// //     if (_emailController.text.trim().isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please enter your email first!'),
// //           backgroundColor: AppColors.warning,
// //         ),
// //       );
// //       return;
// //     }

// //     final success = await context.read<AuthProvider>().forgotPassword(
// //       _emailController.text.trim(),
// //     );

// //     if (!mounted) return;

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           success
// //               ? 'Password reset email sent!'
// //               : context.read<AuthProvider>().errorMessage,
// //         ),
// //         backgroundColor: success ? AppColors.success : AppColors.error,
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final r = ResponsiveHelper(context);

// //     // context.watch hata diya — ab sirf local _isLoading use ho raha hai
// //     // AuthProvider watch karne se notifyListeners → rebuild → potential flicker

// //     return Scaffold(
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: r.pagePadding,
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 SizedBox(height: r.hp(6)),

// //                 // ── LOGO + APP NAME ──
// //                 Center(
// //                   child: Column(
// //                     children: [
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.circular(24),
// //                         child: Image.asset(
// //                           'assets/meditacklogo.png',
// //                           width: r.wp(22),
// //                           height: r.wp(22),
// //                           fit: BoxFit.contain,
// //                         ),
// //                       ),
// //                       SizedBox(height: r.mediumSpace),
// //                       Text(AppStrings.appName, style: AppTextStyles.heading2),
// //                     ],
// //                   ),
// //                 ),

// //                 SizedBox(height: r.hp(5)),

// //                 Text(AppStrings.welcomeBack, style: AppTextStyles.heading1),
// //                 SizedBox(height: r.smallSpace),
// //                 Text(
// //                   'Sign in to continue',
// //                   style: AppTextStyles.bodyMedium.copyWith(
// //                     color: Theme.of(context).colorScheme.onSurfaceVariant,
// //                   ),
// //                 ),

// //                 SizedBox(height: r.largeSpace),

// //                 // Email field
// //                 TextFormField(
// //                   controller: _emailController,
// //                   keyboardType: TextInputType.emailAddress,
// //                   decoration: InputDecoration(
// //                     labelText: AppStrings.email,
// //                     prefixIcon: const Icon(Icons.email_outlined),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(r.mediumRadius),
// //                     ),
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty)
// //                       return 'Email is required!';
// //                     if (!value.contains('@')) return 'Enter a valid email!';
// //                     return null;
// //                   },
// //                 ),

// //                 SizedBox(height: r.mediumSpace),

// //                 // Password field
// //                 TextFormField(
// //                   controller: _passwordController,
// //                   obscureText: _obscurePassword,
// //                   decoration: InputDecoration(
// //                     labelText: AppStrings.password,
// //                     prefixIcon: const Icon(Icons.lock_outlined),
// //                     suffixIcon: IconButton(
// //                       icon: Icon(
// //                         _obscurePassword
// //                             ? Icons.visibility_outlined
// //                             : Icons.visibility_off_outlined,
// //                       ),
// //                       onPressed: () =>
// //                           setState(() => _obscurePassword = !_obscurePassword),
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(r.mediumRadius),
// //                     ),
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty)
// //                       return 'Password is required!';
// //                     if (value.length < 6)
// //                       return 'Password must be at least 6 characters!';
// //                     return null;
// //                   },
// //                 ),

// //                 SizedBox(height: r.smallSpace),

// //                 Align(
// //                   alignment: Alignment.centerRight,
// //                   child: TextButton(
// //                     onPressed: _forgotPassword,
// //                     child: Text(
// //                       AppStrings.forgotPassword,
// //                       style: AppTextStyles.bodyMedium.copyWith(
// //                         color: AppColors.primary,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 SizedBox(height: r.mediumSpace),

// //                 // Login button — local _isLoading use karta hai
// //                 SizedBox(
// //                   width: double.infinity,
// //                   height: r.hp(7),
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading ? null : _login,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: AppColors.primary,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(r.mediumRadius),
// //                       ),
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(
// //                             width: 22,
// //                             height: 22,
// //                             child: CircularProgressIndicator(
// //                               color: AppColors.textWhite,
// //                               strokeWidth: 2.5,
// //                             ),
// //                           )
// //                         : Text(AppStrings.login, style: AppTextStyles.button),
// //                   ),
// //                 ),

// //                 SizedBox(height: r.mediumSpace),

// //                 Row(
// //                   children: [
// //                     const Expanded(child: Divider()),
// //                     Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: r.wp(3)),
// //                       child: Text('OR', style: AppTextStyles.bodySmall),
// //                     ),
// //                     const Expanded(child: Divider()),
// //                   ],
// //                 ),

// //                 SizedBox(height: r.mediumSpace),

// //                 // Google button
// //                 SizedBox(
// //                   width: double.infinity,
// //                   height: r.hp(7),
// //                   child: OutlinedButton.icon(
// //                     onPressed: _isLoading ? null : _loginWithGoogle,
// //                     icon: Icon(
// //                       Icons.g_mobiledata,
// //                       size: r.mediumIcon,
// //                       color: AppColors.primary,
// //                     ),
// //                     label: Text(
// //                       AppStrings.continueGoogle,
// //                       style: AppTextStyles.bodyMedium.copyWith(
// //                         color: Theme.of(context).colorScheme.onSurface,
// //                       ),
// //                     ),
// //                     style: OutlinedButton.styleFrom(
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(r.mediumRadius),
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 SizedBox(height: r.largeSpace),

// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
// //                     GestureDetector(
// //                       onTap: () => context.go(AppRoutes.register),
// //                       child: Text(
// //                         AppStrings.register,
// //                         style: AppTextStyles.bodyMedium.copyWith(
// //                           color: AppColors.primary,
// //                           fontWeight: FontWeight.w700,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 SizedBox(height: r.mediumSpace),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:meditrack/core/constants/app_string.dart';
// import 'package:meditrack/core/constants/app_text_style.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/responsive_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../routes/app_routes.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final success = await context.read<AuthProvider>().loginWithEmail(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (success) {
//       context.go(AppRoutes.dashboard);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(context.read<AuthProvider>().errorMessage),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   Future<void> _loginWithGoogle() async {
//     setState(() => _isLoading = true);

//     final success = await context.read<AuthProvider>().loginWithGoogle();

//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (success) {
//       context.go(AppRoutes.dashboard);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(context.read<AuthProvider>().errorMessage),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   // Forgot Password → dedicated screen pe navigate karo
//   void _forgotPassword() {
//     context.push(AppRoutes.forgotPassword);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = ResponsiveHelper(context);

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: r.pagePadding,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: r.hp(6)),

//                 // ── LOGO + APP NAME ──
//                 Center(
//                   child: Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(24),
//                         child: Image.asset(
//                           'assets/meditacklogo.png',
//                           width: r.wp(22),
//                           height: r.wp(22),
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       SizedBox(height: r.mediumSpace),
//                       Text(AppStrings.appName, style: AppTextStyles.heading2),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: r.hp(5)),

//                 Text(AppStrings.welcomeBack, style: AppTextStyles.heading1),
//                 SizedBox(height: r.smallSpace),
//                 Text(
//                   'Sign in to continue',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//                 ),

//                 SizedBox(height: r.largeSpace),

//                 // ── Email Field ──
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: AppStrings.email,
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(r.mediumRadius),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'Email is required!';
//                     if (!value.contains('@')) return 'Enter a valid email!';
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: r.mediumSpace),

//                 // ── Password Field ──
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: AppStrings.password,
//                     prefixIcon: const Icon(Icons.lock_outlined),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                       onPressed: () =>
//                           setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(r.mediumRadius),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'Password is required!';
//                     if (value.length < 6)
//                       return 'Password must be at least 6 characters!';
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: r.smallSpace),

//                 // ── Forgot Password ──
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: _forgotPassword,
//                     child: Text(
//                       AppStrings.forgotPassword,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: r.mediumSpace),

//                 // ── Login Button ──
//                 SizedBox(
//                   width: double.infinity,
//                   height: r.hp(7),
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(r.mediumRadius),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(
//                               color: AppColors.textWhite,
//                               strokeWidth: 2.5,
//                             ),
//                           )
//                         : Text(AppStrings.login, style: AppTextStyles.button),
//                   ),
//                 ),

//                 SizedBox(height: r.mediumSpace),

//                 // ── OR Divider ──
//                 Row(
//                   children: [
//                     const Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: r.wp(3)),
//                       child: Text('OR', style: AppTextStyles.bodySmall),
//                     ),
//                     const Expanded(child: Divider()),
//                   ],
//                 ),

//                 SizedBox(height: r.mediumSpace),

//                 // ── Google Button ──
//                 SizedBox(
//                   width: double.infinity,
//                   height: r.hp(7),
//                   child: OutlinedButton.icon(
//                     onPressed: _isLoading ? null : _loginWithGoogle,
//                     icon: Icon(
//                       Icons.g_mobiledata,
//                       size: r.mediumIcon,
//                       color: AppColors.primary,
//                     ),
//                     label: Text(
//                       AppStrings.continueGoogle,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(r.mediumRadius),
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: r.largeSpace),

//                 // ── Register Link ──
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
//                     GestureDetector(
//                       onTap: () => context.go(AppRoutes.register),
//                       child: Text(
//                         AppStrings.register,
//                         style: AppTextStyles.bodyMedium.copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: r.mediumSpace),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_string.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Forgot Password → navigate to dedicated screen
  void _forgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.hp(6)),

                // ── LOGO + APP NAME ──
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/meditacklogo.png',
                          width: r.wp(22),
                          height: r.wp(22),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: r.mediumSpace),
                      Text(AppStrings.appName, style: AppTextStyles.heading2),
                    ],
                  ),
                ),

                SizedBox(height: r.hp(5)),

                Text(AppStrings.welcomeBack, style: AppTextStyles.heading1),
                SizedBox(height: r.smallSpace),
                Text(
                  'Sign in to continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // ── Email Field ──
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email is required!';
                    if (!value.contains('@')) return 'Enter a valid email!';
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // ── Password Field ──
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password is required!';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters!';
                    return null;
                  },
                ),

                SizedBox(height: r.smallSpace),

                // ── Forgot Password ──
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: r.mediumSpace),

                // ── Login Button ──
                SizedBox(
                  width: double.infinity,
                  height: r.hp(7),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(AppStrings.login, style: AppTextStyles.button),
                  ),
                ),

                SizedBox(height: r.mediumSpace),

                // ── OR Divider ──
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.wp(3)),
                      child: Text('OR', style: AppTextStyles.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: r.mediumSpace),

                // ── Google Button ──
                SizedBox(
                  width: double.infinity,
                  height: r.hp(7),
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: Icon(
                      Icons.g_mobiledata,
                      size: r.mediumIcon,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      AppStrings.continueGoogle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // ── Register Link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.register),
                      child: Text(
                        AppStrings.register,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: r.mediumSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
