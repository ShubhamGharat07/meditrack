import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_text_style.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.medication,
      'title': 'Track Your Medicines',
      'description':
          'Never miss a dose again. Set reminders and track your medicine schedule easily.',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.folder_special,
      'title': 'Store Health Records',
      'description':
          'Keep all your health records, reports and prescriptions in one safe place.',
      'color': AppColors.secondary,
    },
    {
      'icon': Icons.smart_toy,
      'title': 'AI Health Assistant',
      'description':
          'Get 24/7 health guidance from our AI assistant. Ask anything about your health.',
      'color': AppColors.success,
    },
  ];

  Future<void> _finish() async {
    await context.read<AuthProvider>().setFirstTimeDone();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(r.wp(4)),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(r, _pages[index]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(r, index),
              ),
            ),

            SizedBox(height: r.mediumSpace),

            // Next / Get Started button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.wp(6)),
              child: SizedBox(
                width: double.infinity,
                height: r.hp(7),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _finish();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage]['color'] as Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.mediumRadius),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),

            SizedBox(height: r.largeSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(ResponsiveHelper r, Map<String, dynamic> page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.wp(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: r.wp(55),
            height: r.wp(55),
            decoration: BoxDecoration(
              color: (page['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page['icon'] as IconData,
              size: r.wp(25),
              color: page['color'] as Color,
            ),
          ),

          SizedBox(height: r.largeSpace),

          // Title
          Text(
            page['title'] as String,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: r.mediumSpace),

          // Description
          Text(
            page['description'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(ResponsiveHelper r, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: r.wp(1)),
      width: _currentPage == index ? r.wp(6) : r.wp(2),
      height: r.wp(2),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage]['color'] as Color
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(r.smallRadius),
      ),
    );
  }
}
