import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../controller/transactions_controller.dart';
import '../model/transaction_model.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildTransactionItem(transactions[index], context);
        },
      ),
    );
  }

  Widget _buildTransactionItem(
      TransactionModel transaction, BuildContext context) {
    final formattedDate = DateFormatter.display(transaction.date);
    final icon = _resolveIcon(transaction.iconKey);
    final color = _resolveColor(transaction.colorKey, context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
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
                  transaction.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(transaction.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount < 0
                      ? AppTheme.textDark
                      : AppTheme.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String key) {
    const map = {
      'coffee': Icons.coffee,
      'wallet': Icons.account_balance_wallet,
      'shopping': Icons.shopping_bag,
      'taxi': Icons.local_taxi,
      'gift': Icons.card_giftcard,
      'movie': Icons.movie,
    };
    return map[key] ?? Icons.receipt;
  }

  Color _resolveColor(String key, BuildContext context) {
    const map = {
      'error': AppTheme.error,
      'success': AppTheme.success,
      'mint': AppTheme.accentLime,
      'textDark': AppTheme.textDark,
    };
    return map[key] ?? AppTheme.textDark;
  }
}
