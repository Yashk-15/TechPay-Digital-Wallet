import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../../app_router.dart';
import '../controller/home_controller.dart';
import 'balance_overview_screen.dart';
import '../../rewards/view/rewards_screen.dart';
import '../../wallet/view/cards_screen.dart'; // Ensure this import exists or is correct

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider to rebuild when index changes
    final homeState = ref.watch(homeProvider);
    final controller = ref.read(homeProvider.notifier);

    // Define the main content views
    // Note: We are keeping the structural switching but redesigning the DashboardHomeContent
    final List<Widget> screens = [
      const DashboardHomeContent(),
      const BalanceOverviewScreen(),
      const RewardsScreen(), // Placeholder for Scanner if needed, or actual scanner
      const RewardsScreen(),
      const CardsScreen(), // Assuming CardsScreen is accessible here
    ];

    // Handle index out of bounds if switching views
    final safeIndex =
        homeState.selectedIndex < screens.length ? homeState.selectedIndex : 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Main Content
          screens[safeIndex],

          // Floating Bottom Navigation
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: FloatingNavBar(
              selectedIndex: homeState.selectedIndex,
              onItemSelected: (index) {
                controller.setTabIndex(index);
                // Optional: If you want to use the router side-effect
                // Navigator.pushNamed(context, ...);
                // But since we are using a Stack/Index here, we just update state.
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends ConsumerWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Minimal)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 20, color: AppTheme.textDark),
                    onPressed: () {
                      // Assuming this might be a sub-screen or just a placeholder back
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: AppTheme.textDark),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppTheme.textDark),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: AppTheme.textDark),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.settings),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Top Gradient Card (UPI ID)
            Container(
              height: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient:
                    AppTheme.primaryGradient, // UPDATED: TechPay Brand Gradient
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Logo Placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'UPI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI ID: ${homeState.userName.toLowerCase().replaceAll(' ', '')}@techpay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Header "UPI"
            const Text(
              'UPI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const Row(
              children: [
                Text(
                  'UPI Safety shield tips',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.help_outline, size: 12, color: AppTheme.textLight),
                Spacer(),
                Text(
                  'My QR',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.qr_code_2, size: 24, color: AppTheme.textDark),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Action Pills (Scan QR, Send, Request)
            Row(
              children: [
                _buildActionPill(context, 'Scan QR', Icons.qr_code_scanner, () {
                  Navigator.pushNamed(context, AppRouter.qrScanner);
                }),
                const SizedBox(width: 8),
                _buildActionPill(context, 'Send', Icons.arrow_upward, () {
                  Navigator.pushNamed(context, AppRouter.contactSelection);
                }),
                const SizedBox(width: 8),
                _buildActionPill(context, 'Request', Icons.arrow_downward, () {
                  Navigator.pushNamed(context, AppRouter.splitPayment);
                }),
                const SizedBox(width: 8),
                _buildActionPill(context, 'Card Pay', Icons.credit_card, () {
                  Navigator.pushNamed(context, AppRouter.cardPayment);
                }),
              ],
            ),

            const SizedBox(height: 16),

            // 5. View all transactions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.transactions);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pillBackground,
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('View all transactions'),
              ),
            ),

            const SizedBox(height: 32),

            // 6. Bill Payments (Replacing UPI Lite)
            const Text(
              'Bill Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBillIcon(Icons.phone_android, 'Mobile'),
                  _buildBillIcon(Icons.lightbulb_outline, 'Electricity'),
                  _buildBillIcon(Icons.satellite_alt, 'DTH'),
                  _buildBillIcon(Icons.directions_car, 'FastTag'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 7. Recipients
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipients',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add your favourite recipients for quick payments.',
                        style: TextStyle(
                          fontSize: 10, // Small text as per ref
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 8. My Accounts
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Text(
                    'My accounts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: AppTheme.pillBackground,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryDarkGreen, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
