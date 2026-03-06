import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controller/transactions_controller.dart';
import '../model/transaction_model.dart';
import '../../../core/utils/date_formatter.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch full list
    final allTransactions = ref.watch(transactionsProvider);

    // Filter logic
    final transactions = allTransactions.where((t) {
      final query = _searchQuery.toLowerCase();
      final matchesName = t.title.toLowerCase().contains(query);
      final matchesAmount = t.amount.toString().contains(query);
      final matchesId = t.id.toLowerCase().contains(query);
      return matchesName || matchesAmount || matchesId;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title: const Text('All transactions',
            style: TextStyle(color: AppTheme.text100)),
        centerTitle: false,
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helper Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'The following transactions were made through TechPay.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.text400,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.bgBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Name/UPI ID/Amount',
                  hintStyle: TextStyle(color: AppTheme.text400, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppTheme.text400),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text100,
                  ),
                ),
                const SizedBox(width: 8),
                // Sort/Filter Icon
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Filter options coming soon')));
                  },
                  child: const Icon(Icons.filter_list,
                      size: 20, color: AppTheme.text100),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: AppTheme.text400, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 32,
                      thickness: 0.5,
                      color: AppTheme.bgBorder,
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
    final formattedDate = _formatDateDetails(transaction.date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor:
              (transaction.type == 'sent' ? AppTheme.coral : AppTheme.success)
                  .withOpacity(0.12),
          child: Text(
            initials,
            style: TextStyle(
              color: transaction.type == 'sent'
                  ? AppTheme.coralLight
                  : AppTheme.success,
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
                  color: AppTheme.text100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transaction.id}@techpay', // Placeholder UPI ID
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.text400,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 12, color: AppTheme.text400), // Bank Brand Icon
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.text400,
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
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.type == 'sent'
                    ? AppTheme.coralLight
                    : AppTheme.success,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.type == 'sent' ? 'Sent' : 'Received',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: transaction.type == 'sent'
                    ? AppTheme.coralLight
                    : AppTheme.success,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Savings account',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.text400,
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

  String _formatDateDetails(DateTime date) {
    // Format: "14 FEB 2026, 12:56 PM"
    return DateFormatter.displayDateTime(date);
  }
}
