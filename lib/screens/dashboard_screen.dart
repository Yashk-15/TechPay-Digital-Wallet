import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'balance_overview_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/custom_pill_button.dart';
import '../app_router.dart';
// import 'nfc_payment_screen.dart';
// import 'qr_scanner_screen.dart';
// import 'cards_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeContent(),
    const BalanceOverviewScreen(),
    const RewardsScreen(), // Placeholder for Pie Chart
    const SettingsScreen(), // Placeholder for Hexagon
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // Floating Bottom Navigation
          Positioned(
            bottom: 32,
            left: 50,
            right: 50,
            child: FloatingNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Elements
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.accentLime.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              // Using BackdropFilter for blur effect
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'venzer.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child:
                              const Icon(Icons.sort, color: AppTheme.textDark),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.settings);
                          },
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=12'), // Placeholder for user image
                            backgroundColor: AppTheme.accentLime,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Hi Jon Snow,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkGreen,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Here\'s your latest account overview',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main Balance Card (Exact Match)
                      _buildBalanceCard(context),

                      const SizedBox(height: 24),

                      // Bottom Grid (Expenses & Recent)
                      Row(
                        children: [
                          // Expenses Card
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.accentLime,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.attach_money,
                                          size: 14,
                                          color: AppTheme.primaryDarkGreen,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_outward,
                                        size: 18,
                                        color: AppTheme.textDark,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Expenses',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '₹4,570',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' +27%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.accentLime,
                                            backgroundColor:
                                                AppTheme.primaryDarkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'This Month',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Recent Transaction Card
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRouter.transactions),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Recent Transction',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 36),
                                    const Text(
                                      'Direct Bank',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 30,
                                          child: Stack(
                                            children: [
                                              _buildAvatar(
                                                  'https://i.pravatar.cc/150?img=1',
                                                  0),
                                              _buildAvatar(
                                                  'https://i.pravatar.cc/150?img=2',
                                                  20),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryDarkGreen,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100), // Space for floating nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top Light Green "Bill" Shape
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.accentLime,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top Row (Name & Logo)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jon Snow',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                    Text(
                      'PayPal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Number & Brand
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '**** 0849',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                    Text(
                      'VISA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Balance (Centered)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLime.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.currency_rupee, // Changed to Rupee
                        size: 16,
                        color: AppTheme.accentLime,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹4,30,957.02', // Changed to Rupee & Indian formatting
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Action Buttons (Pills)
                Row(
                  children: [
                    Expanded(
                      child: CustomPillButton(
                        text: 'Deposit',
                        icon: Icons.arrow_downward,
                        isLight: false,
                        onTap: () {
                          // Navigate to split pay for demo, or a dedicated deposit screen
                          Navigator.pushNamed(context, AppRouter.splitPayment);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomPillButton(
                        text: 'Send',
                        icon: Icons.arrow_upward,
                        isLight: true,
                        onTap: () {
                          // Navigate to NFC for demo
                          Navigator.pushNamed(context, AppRouter.nfcPayment);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url, double left) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(url),
        ),
      ),
    );
  }
}
