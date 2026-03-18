import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_string.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().registerWithEmail(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.hp(4)),

                // Back button
                IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios),
                  padding: EdgeInsets.zero,
                ),

                SizedBox(height: r.mediumSpace),

                // Title
                Text(AppStrings.createAccount, style: AppTextStyles.heading1),
                SizedBox(height: r.smallSpace),
                Text(
                  'Fill in the details to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // Name field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required!';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters!';
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // Email field
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
                    if (value == null || value.isEmpty) {
                      return 'Email is required!';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // Password field
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
                    if (value == null || value.isEmpty) {
                      return 'Password is required!';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters!';
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.mediumSpace),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required!';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                    return null;
                  },
                ),

                SizedBox(height: r.largeSpace),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: r.hp(7),
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.mediumRadius),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.textWhite,
                          )
                        : Text(
                            AppStrings.register,
                            style: AppTextStyles.button,
                          ),
                  ),
                ),

                SizedBox(height: r.largeSpace),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text(
                        AppStrings.login,
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
