import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/register_screen.dart';
import 'package:fitstart_mobile_app/screens/login_screen.dart';

class OnboardingItem {
  final String imagePath;
  final IconData? badge1IconData;
  final Color badge1IconColor;
  final String badge1Text;
  final IconData? badge2IconData;
  final Color badge2IconColor;
  final String badge2Text;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isSecondaryButton;

  const OnboardingItem({
    required this.imagePath,
    this.badge1IconData,
    this.badge1IconColor = Colors.amber,
    required this.badge1Text,
    this.badge2IconData,
    this.badge2IconColor = Colors.orange,
    required this.badge2Text,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.isSecondaryButton = false,
  });
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      imagePath: 'assets/images/onboarding_1.jpg',
      badge1IconData: Icons.bolt_rounded,
      badge1IconColor: Color(0xFFF59E0B),
      badge1Text: '92% Peak Readiness',
      badge2IconData: Icons.local_fire_department_rounded,
      badge2IconColor: Color(0xFFF97316),
      badge2Text: 'AI Kinetic Plan',
      title: 'Unlock Your Peak\nAthletic Potential',
      subtitle:
          'Smart AI training plans, real-time kinetic tracking, and tailored nutrition designed to keep your streak alive.',
      buttonText: 'Get Started',
      isSecondaryButton: false,
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding_2.jpg',
      badge1IconData: Icons.eco_rounded,
      badge1IconColor: Color(0xFF10B981),
      badge1Text: 'AI Meal Intelligence',
      badge2IconData: Icons.auto_graph_rounded,
      badge2IconColor: Color(0xFF0284C7),
      badge2Text: '98% Adaptive Accuracy',
      title: 'Precision Nutrition Meets\nSmart Training',
      subtitle:
          'Sync your daily macros, biometric readiness, and custom workouts seamlessly for optimal performance and faster recovery.',
      buttonText: 'Continue',
      isSecondaryButton: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToRegister();
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildGlassBadge({
    required IconData? iconData,
    required Color iconColor,
    required String text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 15,
                  color: iconColor,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + App Name (Dynamic per Figma design for Screen 1 vs Screen 2)
                  Row(
                    children: [
                      if (_currentPage == 0) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFF00E676),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ] else ...[
                        const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF0F172A),
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'FitStart',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (_currentPage == 0)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(left: 3, top: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // SKIP button
                  TextButton(
                    onPressed: _navigateToRegister,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cardHeight = (constraints.maxHeight * 0.52).clamp(180.0, 360.0);
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Hero Card
                                  Container(
                                    height: cardHeight,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(0xFFF1F5F9),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                                          blurRadius: 26,
                                          offset: const Offset(0, 12),
                                          spreadRadius: -4,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Stack(
                                        children: [
                                          // Background image
                                          Positioned.fill(
                                            child: Image.asset(
                                              page.imagePath,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Colors.grey.shade100,
                                                        Colors.blue.shade50,
                                                      ],
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.fitness_center_rounded,
                                                      size: 64,
                                                      color: Color(0xFF2563EB),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          // Badge 1 (Top Left)
                                          Positioned(
                                            top: 16,
                                            left: 16,
                                            child: _buildGlassBadge(
                                              iconData: page.badge1IconData,
                                              iconColor: page.badge1IconColor,
                                              text: page.badge1Text,
                                            ),
                                          ),

                                          // Badge 2 (Bottom Right)
                                          Positioned(
                                            bottom: 16,
                                            right: 16,
                                            child: _buildGlassBadge(
                                              iconData: page.badge2IconData,
                                              iconColor: page.badge2IconColor,
                                              text: page.badge2Text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: constraints.maxHeight < 560 ? 12 : 22),

                                  // Title
                                  Text(
                                    page.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1.22,
                                      letterSpacing: -0.6,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Subtitle
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      page.subtitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF64748B),
                                        height: 1.45,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Area: Indicators + Action Button + Login Link
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: isActive ? 24 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 22),

                  // Action Button
                  Builder(
                    builder: (context) {
                      final currentPage = _pages[_currentPage];
                      final isSecondary = currentPage.isSecondaryButton;

                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSecondary
                                ? Colors.white
                                : const Color(0xFF2563EB),
                            foregroundColor: isSecondary
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                            elevation: isSecondary ? 1 : 4,
                            shadowColor: isSecondary
                                ? Colors.black.withValues(alpha: 0.08)
                                : const Color(0xFF2563EB).withValues(alpha: 0.4),
                            side: isSecondary
                                ? const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentPage.buttonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: isSecondary
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 19,
                                color: isSecondary
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // "Already have an account? Log In"
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}