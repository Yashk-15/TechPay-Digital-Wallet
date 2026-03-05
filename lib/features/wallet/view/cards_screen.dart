import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/cards_controller.dart';
import 'bank_card_widget.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsState = ref.watch(cardsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title:
            const Text('My Cards', style: TextStyle(color: AppTheme.text100)),
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.text100),
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
                        color: AppTheme.text100)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.bgBorder),
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
                                  color: AppTheme.text100)),
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
                                        color: AppTheme.text100)),
                                SizedBox(width: 8),
                                Icon(Icons.visibility_outlined,
                                    size: 20, color: AppTheme.coral),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.bgBorder),
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
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppTheme.bgElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.coral, size: 20),
        ),
        const SizedBox(width: 16),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.text100)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: AppTheme.text400),
      ],
    );
  }
}
