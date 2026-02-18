// lib/features/home/controller/home_controller.dart
//
// HomeState is seeded with the Firebase Auth display name on first build.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeState {
  final double balance;
  final String userName;
  final int selectedIndex;

  const HomeState({
    this.balance = 2548.00,
    this.userName = 'User',
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
  HomeNotifier() : super(const HomeState()) {
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final name = user.displayName?.isNotEmpty == true
          ? user.displayName!.split(' ').first // First name only
          : user.email?.split('@').first ?? 'User';
      state = state.copyWith(userName: name);
    }
  }

  void updateBalance(double newBalance) {
    state = state.copyWith(balance: newBalance);
  }

  void setTabIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void updateUserName(String name) {
    state = state.copyWith(userName: name);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
