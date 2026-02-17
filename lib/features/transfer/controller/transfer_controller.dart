import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/transfer_service.dart';
import '../../home/controller/home_controller.dart';

class TransferState {
  final bool isLoading;
  final String? error;

  const TransferState({
    this.isLoading = false,
    this.error,
  });

  TransferState copyWith({
    bool? isLoading,
    String? error,
  }) {
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
    // Access HomeState directly for the single source of truth balance
    final homeState = _ref.read(homeProvider);
    if (amount > homeState.balance) {
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

      // Update the Single Source of Truth in HomeProvider
      _ref
          .read(homeProvider.notifier)
          .updateBalance(homeState.balance - amount);

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
  return TransferController(service, ref);
});
