// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_style.dart';
// import '../../providers/auth_provider.dart';
// import '../../routes/app_routes.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isLoading = false;
//   bool _emailSent = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendResetEmail() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final success = await context.read<AuthProvider>().forgotPassword(
//       _emailController.text.trim(),
//     );

//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (success) {
//       setState(() => _emailSent = true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(context.read<AuthProvider>().errorMessage),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => context.go(AppRoutes.login),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: _emailSent ? _buildSuccessState() : _buildFormState(),
//         ),
//       ),
//     );
//   }

//   // ── Email Input Form ──
//   Widget _buildFormState() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 32),

//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.lock_reset_rounded,
//                 size: 56,
//                 color: AppColors.primary,
//               ),
//             ),
//           ),

//           const SizedBox(height: 32),

//           Text('Forgot Password?', style: AppTextStyles.heading1),
//           const SizedBox(height: 8),
//           Text(
//             'Apna registered email daalo.\nHum aapko password reset link bhejenge.',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//               height: 1.5,
//             ),
//           ),

//           const SizedBox(height: 32),

//           TextFormField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             textInputAction: TextInputAction.done,
//             onFieldSubmitted: (_) => _sendResetEmail(),
//             decoration: InputDecoration(
//               labelText: 'Email',
//               hintText: 'yourname@email.com',
//               prefixIcon: const Icon(Icons.email_outlined),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Email daalna zaroori hai!';
//               }
//               if (!value.contains('@') || !value.contains('.')) {
//                 return 'Valid email address daalo!';
//               }
//               return null;
//             },
//           ),

//           const SizedBox(height: 32),

//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _sendResetEmail,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                   : Text('Send Reset Link', style: AppTextStyles.button),
//             ),
//           ),

//           const SizedBox(height: 20),

//           Center(
//             child: TextButton(
//               onPressed: () => context.go(AppRoutes.login),
//               child: Text(
//                 'Back to Login',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Success Screen ──
//   Widget _buildSuccessState() {
//     return Column(
//       children: [
//         const SizedBox(height: 48),

//         Container(
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: AppColors.success.withOpacity(0.12),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.mark_email_read_outlined,
//             size: 64,
//             color: AppColors.success,
//           ),
//         ),

//         const SizedBox(height: 32),

//         Text(
//           'Email Bhej Diya!',
//           style: AppTextStyles.heading2,
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: 12),

//         Text(
//           'Password reset link bheja gaya:',
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: Theme.of(context).colorScheme.onSurfaceVariant,
//           ),
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: 6),

//         Text(
//           _emailController.text.trim(),
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: AppColors.primary,
//             fontWeight: FontWeight.w700,
//           ),
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: 24),

//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColors.info.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.info.withOpacity(0.25)),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.info_outline, color: AppColors.info, size: 18),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Link 10 minutes tak valid hai. Spam/Junk folder bhi zaroor check karo!',
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.info,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 36),

//         SizedBox(
//           width: double.infinity,
//           height: 52,
//           child: ElevatedButton(
//             onPressed: () => context.go(AppRoutes.login),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text('Back to Login', style: AppTextStyles.button),
//           ),
//         ),

//         const SizedBox(height: 16),

//         TextButton(
//           onPressed: () => setState(() {
//             _emailSent = false;
//             _emailController.clear();
//           }),
//           child: Text(
//             'Dobaara bhejo?',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  // ── Email Input Form ──
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Text('Forgot Password?', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          Text(
            'Enter your registered email address.\nWe will send you a password reset link.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'yourname@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required!';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email address!';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text('Send Reset Link', style: AppTextStyles.button),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(
                'Back to Login',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Success Screen ──
  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 48),

        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Email Sent!',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Password reset link has been sent to:',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          _emailController.text.trim(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The link is valid for 10 minutes. Please also check your Spam/Junk folder!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Back to Login', style: AppTextStyles.button),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => setState(() {
            _emailSent = false;
            _emailController.clear();
          }),
          child: Text(
            'Resend email?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
