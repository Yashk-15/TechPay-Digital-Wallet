// lib/features/home/view/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../../app_router.dart';
import '../controller/home_controller.dart';
import 'balance_overview_screen.dart';
import '../../rewards/view/rewards_screen.dart';
import '../../transactions/view/transactions_screen.dart';
import '../../wallet/controller/cards_controller.dart';
import '../../wallet/view/bank_card_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final controller = ref.read(homeProvider.notifier);

    final List<Widget> screens = [
      const DashboardHomeContent(),
      const BalanceOverviewScreen(isTab: true),
      const RewardsScreen(),
      const TransactionsScreen(),
    ];

    final safeIndex =
        homeState.selectedIndex < screens.length ? homeState.selectedIndex : 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          screens[safeIndex],
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: FloatingNavBar(
              selectedIndex: homeState.selectedIndex,
              onItemSelected: (index) => controller.setTabIndex(index),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRouter.qrScanner),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryDarkGreen.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR Bottom Sheet ───────────────────────────────────────────────────────────

void _showMyQRCode(BuildContext context, String userName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'My QR Code',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share or scan to receive payments',
            style: TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_2,
                  size: 160, color: AppTheme.textDark),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${userName.toLowerCase().replaceAll(' ', '')}@techpay',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan to pay via TechPay',
            style: TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share QR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryDarkGreen,
                side: const BorderSide(color: AppTheme.primaryDarkGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Dashboard Home Content ────────────────────────────────────────────────────

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
            // ── 1. Header — TechPay brand + Add Card + Popup Menu ────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand title
                  const Text(
                    'TechPay',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDarkGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      // Add Card button
                      IconButton(
                        icon: const Icon(Icons.add, color: AppTheme.textDark),
                        tooltip: 'Add Card',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.cards),
                      ),
                      // 3-dot dropdown menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: AppTheme.textDark),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        onSelected: (value) {
                          switch (value) {
                            case 'settings':
                              Navigator.pushNamed(context, AppRouter.settings);
                              break;
                            case 'mandates':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Mandates & AutoPay coming soon')),
                              );
                              break;
                            case 'complaint':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Complaint & Support coming soon')),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'settings',
                            child: ListTile(
                              leading: Icon(Icons.settings_outlined, size: 22),
                              title: Text('Settings'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'mandates',
                            child: ListTile(
                              leading: Icon(Icons.autorenew_outlined, size: 22),
                              title: Text('Mandates & AutoPay'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'complaint',
                            child: ListTile(
                              leading:
                                  Icon(Icons.support_agent_outlined, size: 22),
                              title: Text('Complaint & Support'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 2. Bank Cards Carousel ────────────────────────────────────
            // ── 1.5. Balance Display ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Balance',
                          style: TextStyle(
                              fontSize: 14, color: AppTheme.textLight)),
                      SizedBox(height: 4),
                      Text('Available in Wallet',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryDarkGreen,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(homeState.balance),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final cardsState = ref.watch(cardsProvider);
                if (cardsState.cards.isEmpty) {
                  return Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                letterSpacing: 1),
                          ),
                        ),
                        Text(
                          'UPI ID: ${homeState.userName.toLowerCase().replaceAll(' ', '')}@techpay',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: cardsState.cards.length + 1,
                    itemBuilder: (context, index) {
                      if (index == cardsState.cards.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('UPI',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1)),
                                ),
                                Text(
                                  'UPI ID: ${homeState.userName.toLowerCase().replaceAll(' ', '')}@techpay',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: BankCardWidget(card: cardsState.cards[index]),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── 3. Tagline + My QR ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Money,',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Zero Limits.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showMyQRCode(context, homeState.userName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.pillBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'My QR',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.qr_code_2,
                            size: 22, color: AppTheme.primaryDarkGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 4. Action Pills ───────────────────────────────────────────
            Row(
              children: [
                _buildActionPill(context, 'NFC Pay', Icons.nfc, () {
                  Navigator.pushNamed(context, AppRouter.nfcPayment);
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

            // ── 5. View All Transactions ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.transactions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pillBackground,
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('View all transactions'),
              ),
            ),

            const SizedBox(height: 32),

            // ── 6. Bill Payments ──────────────────────────────────────────
            const Text(
              'Bill Payments',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBillIcon(context, Icons.phone_android, 'Mobile'),
                  _buildBillIcon(
                      context, Icons.lightbulb_outline, 'Electricity'),
                  _buildBillIcon(context, Icons.satellite_alt, 'DTH'),
                  _buildBillIcon(context, Icons.directions_car, 'FastTag'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 7. Recipients ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recipients',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      SizedBox(height: 4),
                      Text(
                        'Add your favourite recipients for quick payments.',
                        style:
                            TextStyle(fontSize: 10, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 8. My Accounts ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Row(
                children: [
                  Text('My accounts',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                ],
              ),
            ),

            const SizedBox(height: 120),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.primaryDarkGreen, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillIcon(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label payment coming soon')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppTheme.backgroundLight, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryDarkGreen, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
