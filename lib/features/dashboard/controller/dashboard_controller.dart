import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  final double balance;
  final bool isLoading;
  final int selectedIndex;
  final String userName;
  final String cardLast4;

  const DashboardState({
    required this.balance,
    this.isLoading = false,
    this.selectedIndex = 0,
    this.userName = 'Jon Snow',
    this.cardLast4 = '0849',
  });

  DashboardState copyWith({
    double? balance,
    bool? isLoading,
    int? selectedIndex,
    String? userName,
    String? cardLast4,
  }) {
    return DashboardState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userName: userName ?? this.userName,
      cardLast4: cardLast4 ?? this.cardLast4,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState(balance: 430957.02));

  void setTabIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> refreshBalance() async {
    state = state.copyWith(isLoading: true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false, balance: 430957.02);
  }

  void updateBalance(double newBalance) {
    state = state.copyWith(balance: newBalance);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
