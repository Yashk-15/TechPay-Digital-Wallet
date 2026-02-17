import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../controller/cards_controller.dart';
import 'bank_card_widget.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsState = ref.watch(cardsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Card feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cardsState.cards.isEmpty)
                  const Center(child: Text('No cards added'))
                else
                  ...cardsState.cards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: BankCardWidget(card: card),
                      )),

                const SizedBox(height: 8),
                // Card Settings
                const Text('Card Settings',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Show CVV',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Biometric required to reveal CVV')),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('•••',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark)),
                                SizedBox(width: 8),
                                Icon(Icons.visibility_outlined,
                                    size: 20, color: AppTheme.primaryDarkTeal),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      _buildSettingItem(Icons.lock_outline, 'Freeze Card'),
                      const SizedBox(height: 24),
                      _buildSettingItem(Icons.settings_outlined, 'Card Limits'),
                      const SizedBox(height: 24),
                      _buildSettingItem(Icons.pin_drop_outlined, 'Change PIN'),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for FAB
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: FloatingNavBar(
              selectedIndex: 4,
              onItemSelected: (index) {
                // Handle navigation logic here if needed, or rely on internal logic if any.
                // The router usually handles this at the scaffold level, but here it is embedded.
                // For now empty callback to satisfy required param.
                Navigator.pushReplacementNamed(
                    context, _getRouteForIndex(index));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryDarkGreen.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryDarkGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: AppTheme.textLight),
      ],
    );
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/payments';
      case 2:
        return '/scanner';
      case 3:
        return '/rewards';
      case 4:
        return '/cards';
      default:
        return '/home';
    }
  }
}
