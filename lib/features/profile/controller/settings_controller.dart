import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool biometricEnabled;
  final bool notificationsEnabled;

  const SettingsState({
    this.biometricEnabled = true,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? biometricEnabled,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void toggleBiometric(bool value) {
    state = state.copyWith(biometricEnabled: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});
