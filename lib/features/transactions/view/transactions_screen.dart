import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controller/transactions_controller.dart';
import '../model/transaction_model.dart';
import '../../../core/utils/date_formatter.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('All transactions'),
        centerTitle:
            false, // Left aligned usually in reference, or center with back button
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helper Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'The following transactions were made through TechPay.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLight.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.pillBackground, // Light grey
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Name/UPI ID/Amount',
                  hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(width: 8),
                // Sort/Filter Icon
                Icon(Icons.filter_list, size: 20, color: AppTheme.textDark),
                Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(
                height: 32,
                thickness: 0.5,
                color: Color(0xFFE5E7EB), // Very light divider
              ),
              itemBuilder: (context, index) {
                return _buildTransactionRow(transactions[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
      TransactionModel transaction, BuildContext context) {
    final initials = _getInitials(transaction.title);
    final avatarColor = _getAvatarColor(transaction.title);
    final formattedDate = _formatDateDetails(transaction.date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarColor.withOpacity(0.2),
          child: Text(
            initials,
            style: TextStyle(
              color: avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Middle: Title, ID, Bank/Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              // UPI ID Placeholder + ID
              Text(
                '${transaction.id}@techpay', // Placeholder UPI ID
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 12,
                      color: AppTheme.primaryDarkGreen), // Bank Brand Icon
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right: Amount & Status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(
                  transaction.amount.abs()), // Show positive amount
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.type == 'sent' ? 'Sent' : 'Received',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: transaction.type == 'sent'
                    ? AppTheme.textDark
                    : AppTheme.success,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Savings account',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.teal,
      AppTheme.primaryDarkGreen,
    ];
    final hash = name.hashCode;
    return colors[hash % colors.length];
  }

  String _formatDateDetails(DateTime date) {
    // Format: "14 FEB 2026, 12:56 PM"
    return DateFormatter.displayDateTime(date);
  }
}
