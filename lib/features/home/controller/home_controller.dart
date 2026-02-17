import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final double balance;
  final bool isLoading;
  final int selectedIndex;
  final String userName;
  final String cardLast4;
  final bool isBalanceVisible;

  const HomeState({
    required this.balance,
    this.isLoading = false,
    this.selectedIndex = 0,
    this.userName = 'Jon Snow',
    this.cardLast4 = '0849',
    this.isBalanceVisible = true,
  });

  HomeState copyWith({
    double? balance,
    bool? isLoading,
    int? selectedIndex,
    String? userName,
    String? cardLast4,
    bool? isBalanceVisible,
  }) {
    return HomeState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userName: userName ?? this.userName,
      cardLast4: cardLast4 ?? this.cardLast4,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState(balance: 430957.02));

  void setTabIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
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

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
