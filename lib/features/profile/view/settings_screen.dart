import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final settingsState = ref.watch(settingsProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDarkTeal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: AppTheme.primaryDarkTeal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'john.doe@techpay.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Edit Profile coming soon')));
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Security Section
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Biometric Login',
              'Use fingerprint or face ID',
              Icons.fingerprint,
              trailing: Switch(
                value: settingsState.biometricEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).toggleBiometric(value),
                activeTrackColor: AppTheme.primaryDarkTeal,
              ),
            ),
            _buildSettingItem(
              'Change PIN',
              'Update your security PIN',
              Icons.lock_outline,
            ),
            _buildSettingItem(
              'Two-Factor Authentication',
              'Add extra security layer',
              Icons.security,
            ),
            const SizedBox(height: 32),
            // Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
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
                activeTrackColor: AppTheme.primaryDarkTeal,
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
                activeTrackColor: AppTheme.primaryDarkTeal,
              ),
            ),
            _buildSettingItem(
              'Language',
              'English (US)',
              Icons.language,
            ),
            const SizedBox(height: 32),
            // Payment Section
            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Payment Methods',
              'Manage cards and accounts',
              Icons.credit_card,
            ),
            _buildSettingItem(
              'Transaction Limits',
              'Set spending limits',
              Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 32),
            // Support Section
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Help Center',
              'Get help and support',
              Icons.help_outline,
            ),
            _buildSettingItem(
              'Terms & Privacy',
              'Legal information',
              Icons.description_outlined,
            ),
            _buildSettingItem(
              'About',
              'Version 1.0.0',
              Icons.info_outline,
            ),
            const SizedBox(height: 32),
            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.error, width: 2),
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
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
          ],
        ),
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
              color: AppTheme.primaryDarkTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryDarkTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppTheme.textLight,
              ),
        ],
      ),
    );
  }
}
