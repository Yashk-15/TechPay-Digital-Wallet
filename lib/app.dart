// lib/app.dart
//
// Auth-aware root. Watches the Firebase Auth state stream:
//   • null   → user is signed out → show WelcomeScreen
//   • User   → user is signed in  → show HomeScreen
// All named routes are still registered for push navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/auth/auth_controller.dart';
import 'features/home/view/home_screen.dart';
import 'features/onboarding/view/welcome_screen.dart';

class TechPayApp extends ConsumerWidget {
  const TechPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'TechPay',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: AppRouter.routes,
      // Auth-aware home: stream drives the root widget
      home: authState.when(
        // While Firebase resolves the session show a branded splash
        loading: () => const _SplashScreen(),
        error: (_, __) => const WelcomeScreen(),
        data: (user) =>
            user != null ? const HomeScreen() : const WelcomeScreen(),
      ),
    );
  }
}

// ── Branded splash shown for ~1 frame while Firebase resolves auth ────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDarkGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TechPay',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
