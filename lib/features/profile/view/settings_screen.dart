// lib/features/profile/view/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../controller/settings_controller.dart';
import '../../../app_router.dart';
import '../../auth/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final settingsState = ref.watch(settingsProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Live user profile from Firebase
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            profileAsync.when(
              loading: () => _ProfileCardShimmer(),
              error: (_, __) => _ProfileCardFallback(),
              data: (profile) => _ProfileCard(
                name: profile?.fullName ?? 'TechPay User',
                email: profile?.email ?? '',
                phone: profile?.phone ?? '',
              ),
            ),

            const SizedBox(height: 32),

            // ── Security ──────────────────────────────────────────────────
            const _SectionHeader('Security'),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Biometric Login',
              'Use fingerprint or face ID',
              Icons.fingerprint,
              trailing: Switch(
                value: settingsState.biometricEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleBiometric(value),
                activeColor: AppTheme.primaryDarkGreen,
              ),
            ),
            _buildSettingItem(
                'Change PIN', 'Update your security PIN', Icons.lock_outline),
            _buildSettingItem('Two-Factor Authentication',
                'Add extra security layer', Icons.security),

            const SizedBox(height: 32),

            // ── Preferences ───────────────────────────────────────────────
            const _SectionHeader('Preferences'),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Notifications',
              'Manage notification settings',
              Icons.notifications_outlined,
              trailing: Switch(
                value: settingsState.notificationsEnabled,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .toggleNotifications(value),
                activeColor: AppTheme.primaryDarkGreen,
              ),
            ),
            _buildSettingItem(
              'Dark Mode',
              'Switch to dark theme',
              Icons.dark_mode_outlined,
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) =>
                    ref.read(themeProvider.notifier).toggleTheme(value),
                activeColor: AppTheme.primaryDarkGreen,
              ),
            ),
            _buildSettingItem('Language', 'English (IN)', Icons.language),

            const SizedBox(height: 32),

            // ── Payment ───────────────────────────────────────────────────
            const _SectionHeader('Payment'),
            const SizedBox(height: 16),
            _buildSettingItem('Payment Methods', 'Manage cards and accounts',
                Icons.credit_card),
            _buildSettingItem('Transaction Limits', 'Set spending limits',
                Icons.account_balance_wallet_outlined),

            const SizedBox(height: 32),

            // ── Support ───────────────────────────────────────────────────
            const _SectionHeader('Support'),
            const SizedBox(height: 16),
            _buildSettingItem(
                'Help Center', 'Get help and support', Icons.help_outline),
            _buildSettingItem('Terms & Privacy', 'Legal information',
                Icons.description_outlined),
            _buildSettingItem('About', 'Version 1.0.0', Icons.info_outline),

            const SizedBox(height: 32),

            // ── Sign Out ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.error.withOpacity(0.4), width: 1.5),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _confirmSignOut(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppTheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.welcome, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryDarkGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryDarkGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight)),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textLight),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  const _ProfileCard(
      {required this.name, required this.email, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.floatingShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(email,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white70)),
                if (phone.isNotEmpty)
                  Text(phone,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon'))),
            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ProfileCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}

class _ProfileCardFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _ProfileCard(name: 'TechPay User', email: '', phone: '');
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
    );
  }
}
