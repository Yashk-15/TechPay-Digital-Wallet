import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 12),
                _buildFilterChip('Sent'),
                const SizedBox(width: 12),
                _buildFilterChip('Received'),
                const SizedBox(width: 12),
                _buildFilterChip('Pending'),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildDateHeader('Today'),
                _buildTransactionItem(
                  'Starbucks Coffee',
                  'Food & Drink',
                  '-\$5.75',
                  '2:30 PM',
                  Icons.coffee,
                  AppTheme.error,
                ),
                _buildTransactionItem(
                  'Salary Deposit',
                  'Income',
                  '+\$3,500.00',
                  '9:00 AM',
                  Icons.account_balance_wallet,
                  AppTheme.success,
                ),
                const SizedBox(height: 16),
                _buildDateHeader('Yesterday'),
                _buildTransactionItem(
                  'Amazon Purchase',
                  'Shopping',
                  '-\$45.99',
                  '6:15 PM',
                  Icons.shopping_bag,
                  AppTheme.error,
                ),
                _buildTransactionItem(
                  'Uber Ride',
                  'Transportation',
                  '-\$12.50',
                  '3:45 PM',
                  Icons.local_taxi,
                  AppTheme.error,
                ),
                _buildTransactionItem(
                  'Cashback Reward',
                  'Rewards',
                  '+\$8.25',
                  '12:00 PM',
                  Icons.card_giftcard,
                  AppTheme.accentMintGreen,
                ),
                const SizedBox(height: 16),
                _buildDateHeader('Feb 14, 2026'),
                _buildTransactionItem(
                  'Netflix Subscription',
                  'Entertainment',
                  '-\$15.99',
                  '8:00 AM',
                  Icons.movie,
                  AppTheme.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppTheme.primaryDarkTeal.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isSelected ? AppTheme.cardShadow : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLight,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String category,
    String amount,
    String time,
    IconData icon,
    Color amountColor,
  ) {
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryDarkTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                  '$category • $time',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
