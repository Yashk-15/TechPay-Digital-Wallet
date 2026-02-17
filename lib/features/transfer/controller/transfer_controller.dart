import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/transfer_service.dart';

class TransferState {
  final bool isLoading;
  final double availableBalance;
  final String? error;

  const TransferState({
    this.isLoading = false,
    this.availableBalance = 430957.02, // Mocked aligned with Home
    this.error,
  });

  TransferState copyWith({
    bool? isLoading,
    double? availableBalance,
    String? error,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      availableBalance: availableBalance ?? this.availableBalance,
      error: error,
    );
  }
}

class TransferController extends StateNotifier<TransferState> {
  final TransferService _service;

  TransferController(this._service) : super(const TransferState());

  Future<bool> initiateTransfer({
    required String recipientId,
    required double amount,
    String? note,
  }) async {
    if (amount > state.availableBalance) {
      state = state.copyWith(error: 'Insufficient balance');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.processTransfer(
        recipientId: recipientId,
        amount: amount,
        note: note,
      );
      // Update local balance state if needed, or rely on Home refresh
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Transfer failed');
      return false;
    }
  }
}

final transferProvider =
    StateNotifierProvider<TransferController, TransferState>((ref) {
  final service = ref.watch(transferServiceProvider);
  return TransferController(service);
});
