// lib/features/transfer/controller/transfer_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/transfer_service.dart';
import '../../home/controller/home_controller.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../../transactions/model/transaction_model.dart';
import '../../rewards/view/controller/rewards_controller.dart';

class TransferState {
  final bool isLoading;
  final String? error;

  const TransferState({this.isLoading = false, this.error});

  TransferState copyWith({bool? isLoading, String? error}) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TransferController extends StateNotifier<TransferState> {
  final TransferService _service;
  final Ref _ref;

  TransferController(this._service, this._ref) : super(const TransferState());

  Future<bool> initiateTransfer({
    required String recipientId,
    required double amount,
    String? note,
  }) async {
    final homeState = _ref.read(homeProvider);
    if (amount > homeState.balance) {
      state = state.copyWith(error: 'Insufficient balance');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final txnId = await _service.processTransfer(
        recipientId: recipientId,
        amount: amount,
        note: note,
      );

      // 1. Update wallet balance (single source of truth)
      _ref
          .read(homeProvider.notifier)
          .updateBalance(homeState.balance - amount);

      // 2. Append transaction to history
      _ref.read(transactionsProvider.notifier).addTransaction(
            TransactionModel(
              id: txnId,
              title: 'Sent to $recipientId',
              category: 'Transfer',
              amount: -amount,
              date: DateTime.now(),
              type: 'sent',
              iconKey: 'send',
              colorKey: 'textDark',
            ),
          );

      // 3. Earn rewards on transfer (gamification spec)
      _ref.read(rewardsProvider.notifier).earnRewards(
            merchant: 'Transfer to $recipientId',
            amount: amount,
            category: 'Transfer',
          );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Transfer failed: ${e.toString()}');
      return false;
    }
  }
}

final transferProvider =
    StateNotifierProvider<TransferController, TransferState>((ref) {
  final service = ref.watch(transferServiceProvider);
  return TransferController(service, ref);
});
