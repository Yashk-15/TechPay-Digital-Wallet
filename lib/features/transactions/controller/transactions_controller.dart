import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/transaction_model.dart';

class TransactionsState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> filteredTransactions;
  final String activeFilter;

  TransactionsState({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.activeFilter,
  });

  TransactionsState copyWith({
    List<TransactionModel>? allTransactions,
    List<TransactionModel>? filteredTransactions,
    String? activeFilter,
  }) {
    return TransactionsState(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  TransactionsNotifier()
      : super(TransactionsState(
          allTransactions: _mockTransactions,
          filteredTransactions: _mockTransactions,
          activeFilter: 'All',
        ));

  void setFilter(String filter) {
    if (filter == 'All') {
      state = state.copyWith(
        activeFilter: filter,
        filteredTransactions: state.allTransactions,
      );
    } else {
      final filtered = state.allTransactions
          .where((t) => t.type.toLowerCase() == filter.toLowerCase())
          .toList();
      state = state.copyWith(
        activeFilter: filter,
        filteredTransactions: filtered,
      );
    }
  }

  static final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: '1',
      title: 'Starbucks Coffee',
      category: 'Food & Drink',
      amount: -5.75,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'sent',
    ),
    TransactionModel(
      id: '2',
      title: 'Salary Deposit',
      category: 'Income',
      amount: 3500.00,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'received',
    ),
    TransactionModel(
      id: '3',
      title: 'Amazon Purchase',
      category: 'Shopping',
      amount: -45.99,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'sent',
    ),
    TransactionModel(
      id: '4',
      title: 'Uber Ride',
      category: 'Transportation',
      amount: -12.50,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      type: 'sent',
    ),
    TransactionModel(
      id: '5',
      title: 'Cashback Reward',
      category: 'Rewards',
      amount: 8.25,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      type: 'received',
    ),
    TransactionModel(
      id: '6',
      title: 'Netflix Subscription',
      category: 'Entertainment',
      amount: -15.99,
      date: DateTime(2026, 2, 14, 8, 0),
      type: 'pending',
    ),
  ];
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier();
});
