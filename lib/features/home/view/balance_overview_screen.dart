// lib/features/home/view/balance_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../home/controller/home_controller.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../../transactions/model/transaction_model.dart';

class BalanceOverviewScreen extends ConsumerStatefulWidget {
  final bool isTab;
  const BalanceOverviewScreen({super.key, this.isTab = false});

  @override
  ConsumerState<BalanceOverviewScreen> createState() =>
      _BalanceOverviewScreenState();
}

class _BalanceOverviewScreenState extends ConsumerState<BalanceOverviewScreen> {
  int _selectedPeriod = 2; // Default: Month
  int _selectedChart = 0; // 0=Categories, 1=Transactions

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<TransactionModel> _filterByPeriod(
      List<TransactionModel> txns, int period) {
    final now = DateTime.now();
    DateTime cutoff;
    switch (period) {
      case 0:
        cutoff = DateTime(now.year, now.month, now.day);
        break;
      case 1:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case 2:
        cutoff = DateTime(now.year, now.month, 1);
        break;
      case 3:
        cutoff = DateTime(now.year, 1, 1);
        break;
      default:
        cutoff = DateTime(now.year, now.month, 1);
    }
    return txns.where((t) => t.date.isAfter(cutoff)).toList();
  }

  Map<String, double> _categoryTotals(List<TransactionModel> txns) {
    final Map<String, double> map = {};
    for (final t in txns) {
      if (t.amount < 0 && t.category != 'Income' && t.category != 'Rewards') {
        map[t.category] = (map[t.category] ?? 0) + t.amount.abs();
      }
    }
    return map;
  }

  Color _colorForCategory(String cat) {
    const m = {
      'Food & Drink': Color(0xFFFF9800),
      'Shopping': Color(0xFF9C27B0),
      'Transportation': Color(0xFF2196F3),
      'Entertainment': Color(0xFFE91E63),
      'Transfer': Color(0xFF009688),
    };
    return m[cat] ?? AppTheme.primaryDarkGreen;
  }

  IconData _iconForCategory(String cat) {
    const m = {
      'Food & Drink': Icons.local_cafe_outlined,
      'Shopping': Icons.shopping_bag_outlined,
      'Transportation': Icons.directions_car_outlined,
      'Entertainment': Icons.movie_outlined,
      'Transfer': Icons.swap_horiz_outlined,
    };
    return m[cat] ?? Icons.receipt_outlined;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(homeProvider).balance;
    final allTxns = ref.watch(transactionsProvider);
    final filtered = _filterByPeriod(allTxns, _selectedPeriod);

    final totalIncome =
        filtered.where((t) => t.amount > 0).fold(0.0, (s, t) => s + t.amount);
    final totalExpenses = filtered
        .where((t) => t.amount < 0)
        .fold(0.0, (s, t) => s + t.amount.abs());

    final catTotals = _categoryTotals(filtered);
    final sortedCats = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.primaryDarkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab ? null : const BackButton(color: Colors.white),
        title: const Text('Balance Overview',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Balance + income/expense summary ─────────────────────────
          const SizedBox(height: 8),
          Text(
            'Total Balance',
            style:
                TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(balance),
            style: const TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Income / Expenses chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: totalIncome,
                    color: AppTheme.accentLime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expenses',
                    amount: totalExpenses,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Period selector ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children:
                  ['Day', 'Week', 'Month', 'Year'].asMap().entries.map((e) {
                final isSelected = _selectedPeriod == e.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryDarkGreen
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── Main content panel ────────────────────────────────────────
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
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 52, color: AppTheme.textLight),
                          SizedBox(height: 12),
                          Text(
                            'No transactions in this period',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // View toggle
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Row(
                            children: [
                              _ViewToggle(
                                label: 'By Category',
                                icon: Icons.pie_chart_outline,
                                selected: _selectedChart == 0,
                                onTap: () => setState(() => _selectedChart = 0),
                              ),
                              const SizedBox(width: 10),
                              _ViewToggle(
                                label: 'Transactions',
                                icon: Icons.receipt_long_outlined,
                                selected: _selectedChart == 1,
                                onTap: () => setState(() => _selectedChart = 1),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Expanded(
                          child: _selectedChart == 0
                              ? _CategoriesView(
                                  sortedCats: sortedCats,
                                  totalExpenses: totalExpenses,
                                  colorForCat: _colorForCategory,
                                  iconForCat: _iconForCategory,
                                )
                              : _TransactionsView(transactions: filtered),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Chip ───────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.white.withOpacity(0.7))),
              Text(
                CurrencyFormatter.format(amount),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── View Toggle Button ────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? AppTheme.cardShadow : null,
          border: selected
              ? null
              : Border.all(color: AppTheme.textLight.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15, color: selected ? Colors.white : AppTheme.textLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Categories View ───────────────────────────────────────────────────────

class _CategoriesView extends StatelessWidget {
  final List<MapEntry<String, double>> sortedCats;
  final double totalExpenses;
  final Color Function(String) colorForCat;
  final IconData Function(String) iconForCat;

  const _CategoriesView({
    required this.sortedCats,
    required this.totalExpenses,
    required this.colorForCat,
    required this.iconForCat,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedCats.isEmpty) {
      return const Center(
        child: Text('No expense categories for this period',
            style: TextStyle(color: AppTheme.textLight)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      children: [
        // Visual stacked bar
        Container(
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: AppTheme.pillBackground,
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: sortedCats.map((e) {
              final frac = totalExpenses > 0
                  ? (e.value / totalExpenses).clamp(0.0, 1.0)
                  : 0.0;
              return Flexible(
                flex: (frac * 1000).round(),
                child: Container(color: colorForCat(e.key)),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Category rows
        ...sortedCats.map((e) {
          final frac = totalExpenses > 0
              ? (e.value / totalExpenses).clamp(0.0, 1.0)
              : 0.0;
          final color = colorForCat(e.key);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconForCat(e.key), size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(e.value),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark),
                        ),
                        Text(
                          '${(frac * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Transactions View ─────────────────────────────────────────────────────

class _TransactionsView extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TransactionsView({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = transactions[i];
        final isCredit = t.amount > 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 18,
                  color: isCredit ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    Text(t.category,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : '-'}${CurrencyFormatter.format(t.amount.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCredit ? AppTheme.success : AppTheme.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
