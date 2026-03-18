import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_string.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo — fade + scale
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // App name — slide up + fade
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Tagline — fade (delayed)
  late Animation<double> _taglineFadeAnimation;

  // Loader — fade (last)
  late Animation<double> _loaderFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo animations — 0% to 50%
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // App name — 35% to 70%
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
          ),
        );

    // Tagline — 55% to 80%
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
      ),
    );

    // Loader — 75% to 100%
    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate after 3s — animations finish hone do
    Future.delayed(const Duration(milliseconds: 3000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    final isFirstTime = await authProvider.isFirstTime();
    if (isFirstTime) {
      if (!mounted) return;
      context.go(AppRoutes.onboarding);
      return;
    }

    final isLoggedIn = await authProvider.checkIfLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Logo ka background color match kiya — deep navy
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── LOGO ──
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/meditacklogo.png',
                  width: size.width * 0.38,
                  height: size.width * 0.38,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: size.height * 0.035),

            // ── APP NAME ──
            FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Text(
                  AppStrings.appName,
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.010),

            // ── TAGLINE ──
            FadeTransition(
              opacity: _taglineFadeAnimation,
              child: Text(
                AppStrings.tagline,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            SizedBox(height: size.height * 0.07),

            // ── LOADER ──
            FadeTransition(
              opacity: _loaderFadeAnimation,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.75),
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
