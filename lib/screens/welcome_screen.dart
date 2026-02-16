import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'phone_verification_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDarkTeal,
              AppTheme.primaryTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Spacer(),
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentMintGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: AppTheme.primaryDarkTeal,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'TechPay',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Digital Wallet, Reimagined',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.accentLightMint.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Features
                _buildFeature(Icons.contactless, 'Contactless Payments'),
                const SizedBox(height: 16),
                _buildFeature(Icons.security, 'Bank-Level Security'),
                const SizedBox(height: 16),
                _buildFeature(Icons.card_giftcard, 'Instant Cashback'),
                const Spacer(),
                // Get Started Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accentMintGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentMintGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneVerificationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentMintGreen,
                      foregroundColor: AppTheme.primaryDarkTeal,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentLightMint.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentMintGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentMintGreen, size: 28),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
