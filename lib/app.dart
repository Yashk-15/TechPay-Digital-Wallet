import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/auth/auth_controller.dart';

class TechPayApp extends ConsumerWidget {
  const TechPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TechPay',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: AppRouter.routes,
      // Always show the branded splash first — it handles auth routing
      home: const _SplashScreen(),
    );
  }
}

// ── Branded Startup Splash ─────────────────────────────────────────────────────
// Shown EVERY time the app is opened (like GPay / PhonePe).
// Enforces a minimum 2.5 s display time regardless of Firebase speed.
// After both minimum time AND auth resolution, routes:
//   logged in  → /home
//   logged out → /welcome

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _badgesCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _badgesFade;
  late final Animation<Offset> _badgesSlide;

  bool _timerDone = false;
  bool _authResolved = false;
  bool _isLoggedIn = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _badgesCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));

    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _badgesFade = CurvedAnimation(parent: _badgesCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _badgesSlide = CurvedAnimation(parent: _badgesCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 450));
    _badgesCtrl.forward();
    _progressCtrl.forward();
    // Minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2500));
    _timerDone = true;
    _maybeNavigate();
  }

  void _onAuthResolved(bool loggedIn) {
    _authResolved = true;
    _isLoggedIn = loggedIn;
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (_timerDone && _authResolved && !_navigated && mounted) {
      _navigated = true;
      final dest = _isLoggedIn ? AppRouter.home : AppRouter.welcome;
      Navigator.pushNamedAndRemoveUntil(context, dest, (route) => false);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _badgesCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth — routes when both splash time and auth are done
    ref.listen(authStateProvider, (_, next) {
      next.whenData((user) => _onAuthResolved(user != null));
      if (next.hasError) _onAuthResolved(false);
    });

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo ──────────────────────────────────────────────────────
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.bgElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.coral.withOpacity(0.35),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.coral.withOpacity(0.25),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 52,
                          color: AppTheme.coral,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'TechPay',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text100,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Secure Digital Payments',
                        style: TextStyle(fontSize: 14, color: AppTheme.text400),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Trust Badges ──────────────────────────────────────────────
              FadeTransition(
                opacity: _badgesFade,
                child: SlideTransition(
                  position: _badgesSlide,
                  child: const Column(
                    children: [
                      Row(children: [
                        Expanded(child: Divider(color: AppTheme.bgBorder)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'SECURED BY',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.text400,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.bgBorder)),
                      ]),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TrustBadge(
                            icon: Icons.verified_user_rounded,
                            title: 'PCI DSS',
                            subtitle: 'Level 1\nCompliant',
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 14),
                          _TrustBadge(
                            icon: Icons.lock_rounded,
                            title: 'AES-256',
                            subtitle: 'Bank-Grade\nEncrypted',
                            color: AppTheme.coral,
                          ),
                          SizedBox(width: 14),
                          _TrustBadge(
                            icon: Icons.security_rounded,
                            title: 'SHA-256',
                            subtitle: 'Hash\nProtected',
                            color: Color(0xFF42A5F5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Progress bar ──────────────────────────────────────────────
              FadeTransition(
                opacity: _badgesFade,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _progressCtrl.value,
                          backgroundColor: AppTheme.bgBorder,
                          valueColor:
                              const AlwaysStoppedAnimation(AppTheme.coral),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Loading securely…',
                      style: TextStyle(fontSize: 11, color: AppTheme.text400),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trust Badge Card ───────────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _TrustBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.text400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
