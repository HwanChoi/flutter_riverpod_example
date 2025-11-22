import 'package:flutter_riverpod/flutter_riverpod.dart';

// This enum represents the authentication state.
enum AuthState {
  authenticated,
  unauthenticated,
  loading,
}

// This is the StateNotifier that will hold the authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unauthenticated);

  // Method to simulate a login.
  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    // In a real app, you would make an API call here.
    // For this example, we'll just simulate a delay.
    await Future.delayed(const Duration(seconds: 1));
    state = AuthState.authenticated;
  }

  // Method to simulate a logout.
  void logout() {
    state = AuthState.unauthenticated;
  }
}

// This is the provider that will expose the AuthNotifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
