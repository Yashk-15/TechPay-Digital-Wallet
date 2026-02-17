import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app_router.dart';

class PostLoginWelcomeScreen extends StatefulWidget {
  const PostLoginWelcomeScreen({super.key});

  @override
  State<PostLoginWelcomeScreen> createState() => _PostLoginWelcomeScreenState();
}

class _PostLoginWelcomeScreenState extends State<PostLoginWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Auto-navigate after delay? User might prefer manual "Continue".
    // Plan says "Continue" button, so we'll stick to that.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppTheme.success,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Animated Text
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Welcome to TechPay!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your account has been set up successfully.\nYou are ready to start making secure payments.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Continue Button
              FadeTransition(
                opacity: _opacityAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.home,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
