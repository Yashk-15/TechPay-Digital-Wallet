import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../home/controller/home_controller.dart'; // Import for homeProvider

class BalanceOverviewScreen extends ConsumerStatefulWidget {
  const BalanceOverviewScreen({super.key});

  @override
  ConsumerState<BalanceOverviewScreen> createState() =>
      _BalanceOverviewScreenState();
}

class _BalanceOverviewScreenState extends ConsumerState<BalanceOverviewScreen> {
  int _selectedPeriod = 0;
  int _selectedChart = 2; // Line chart default

  @override
  Widget build(BuildContext context) {
    // FIX: use homeProvider for balance
    final balance = ref.watch(homeProvider).balance;

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Balance Overview',
            style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          // Time Period Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['Day', 'Week', 'Month', 'Year'].asMap().entries.map((entry) {
                final isSelected = _selectedPeriod == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = entry.key),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primaryDarkGreen
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          // Chart placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.show_chart,
                        size: 64,
                        color: AppTheme.primaryDarkGreen.withOpacity(0.2),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Chart Type Selector
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildChartButton(
                            Icons.candlestick_chart, 0, 'Candlestick'),
                        _buildChartButton(Icons.pie_chart, 1, 'Pie chart'),
                        _buildChartButton(
                            Icons.show_chart, 2, 'Line chart'), // Default
                        _buildChartButton(Icons.percent, 3, 'Percentage'),
                        _buildChartButton(
                            Icons.account_balance_wallet, 4, 'Wallet'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton(IconData icon, int index, String label) {
    final isSelected = _selectedChart == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedChart = index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to $label view')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDarkGreen : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryDarkGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : AppTheme.textLight,
        ),
      ),
    );
  }
}
