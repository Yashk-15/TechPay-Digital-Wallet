// lib/features/auth/controller/auth_controller.dart
//
// Riverpod providers for Firebase Auth state.
// authStateProvider   — Stream<User?> drives top-level routing.
// authProvider        — Manages sign-in/sign-up/sign-out with loading/error state.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';

// ── Singleton service ─────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth state stream (drives navigation) ────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Logged-in user's profile ──────────────────────────────────────────────────

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;
  return ref.read(authServiceProvider).fetchProfile(user.uid);
});

// ── UI state for sign-in / sign-up actions ────────────────────────────────────

class AuthFormState {
  final bool isLoading;
  final String? error;

  const AuthFormState({this.isLoading = false, this.error});

  AuthFormState copyWith({bool? isLoading, String? error}) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AuthFormState clearError() => AuthFormState(isLoading: isLoading);
}

class AuthNotifier extends StateNotifier<AuthFormState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AuthFormState());

  // ── Sign In ──────────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.signInWithEmail(email, password);
      state = const AuthFormState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(error: AuthService.mapError(e));
      return false;
    } catch (e) {
      state = AuthFormState(error: 'Unexpected error. Please try again.');
      return false;
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = const AuthFormState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(error: AuthService.mapError(e));
      return false;
    } catch (e) {
      state = AuthFormState(error: 'Unexpected error. Please try again.');
      return false;
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthFormState();
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.sendPasswordReset(email);
      state = const AuthFormState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthFormState(error: AuthService.mapError(e));
      return false;
    }
  }

  void clearError() {
    state = state.clearError();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthFormState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
