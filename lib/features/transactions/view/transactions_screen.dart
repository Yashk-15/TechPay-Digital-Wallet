import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controller/transactions_controller.dart';
import '../model/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsProvider);
    final controller = ref.read(transactionsProvider.notifier);

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
                _buildFilterChip('All', state.activeFilter, controller),
                const SizedBox(width: 12),
                _buildFilterChip('Sent', state.activeFilter, controller),
                const SizedBox(width: 12),
                _buildFilterChip('Received', state.activeFilter, controller),
                const SizedBox(width: 12),
                _buildFilterChip('Pending', state.activeFilter, controller),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: state.filteredTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.filteredTransactions[index];
                      // Simple date header logic could be added here if sorted
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String activeFilter, TransactionsNotifier controller) {
    final isSelected = activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(label),
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

  Widget _buildTransactionItem(TransactionModel transaction) {
    final formattedDate = DateFormat('MMM d, h:mm a').format(transaction.date);
    final icon = _getTransactionIcon(transaction.category);
    final color = _getTransactionColor(transaction.type);

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
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • $formattedDate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.amount >= 0 ? '+' : ''}${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.coffee;
      case 'Income':
        return Icons.account_balance_wallet;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Transportation':
        return Icons.local_taxi;
      case 'Rewards':
        return Icons.card_giftcard;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.receipt;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'received':
        return AppTheme.success;
      case 'sent':
        return AppTheme.error;
      case 'pending':
        return Colors.orange;
      default:
        return AppTheme.textDark;
    }
  }
}
