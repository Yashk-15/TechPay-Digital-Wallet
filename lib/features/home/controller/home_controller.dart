import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final double balance;
  final String userName;
  final int selectedIndex;

  const HomeState({
    this.balance = 2548.00,
    this.userName = 'Yash',
    this.selectedIndex = 0,
  });

  HomeState copyWith({
    double? balance,
    String? userName,
    int? selectedIndex,
  }) {
    return HomeState(
      balance: balance ?? this.balance,
      userName: userName ?? this.userName,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void updateBalance(double newBalance) {
    state = state.copyWith(balance: newBalance);
  }

  void setTabIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
