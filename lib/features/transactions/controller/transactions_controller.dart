import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/transaction_model.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsController, List<TransactionModel>>(
        (ref) {
  return TransactionsController();
});

class TransactionsController extends StateNotifier<List<TransactionModel>> {
  TransactionsController() : super(_mockTransactions);

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
  }

  static final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: '1',
      title: 'Starbucks Coffee',
      category: 'Food & Drink',
      amount: -350.00,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'sent',
      iconKey: 'coffee',
      colorKey: 'textDark',
    ),
    TransactionModel(
      id: '2',
      title: 'Salary Credit',
      category: 'Income',
      amount: 45000.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'received',
      iconKey: 'wallet',
      colorKey: 'success',
    ),
    TransactionModel(
      id: '3',
      title: 'Grocery Store',
      category: 'Shopping',
      amount: -2450.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'sent',
      iconKey: 'shopping',
      colorKey: 'textDark',
    ),
    TransactionModel(
      id: '4',
      title: 'Uber Ride',
      category: 'Transportation',
      amount: -450.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: 'sent',
      iconKey: 'taxi',
      colorKey: 'textDark',
    ),
    TransactionModel(
      id: '5',
      title: 'Cashback Reward',
      category: 'Rewards',
      amount: 150.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      type: 'received',
      iconKey: 'gift',
      colorKey: 'mint',
    ),
    TransactionModel(
      id: '6',
      title: 'Netflix Subscription',
      category: 'Entertainment',
      amount: -650.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: 'sent',
      iconKey: 'movie',
      colorKey: 'textDark',
    ),
  ];
}
