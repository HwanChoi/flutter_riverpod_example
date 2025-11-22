import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier(this._apiService) : super(null) {
    _loadUserFromPrefs();
  }

  final ApiService _apiService;
  final Completer<void> _initCompleter = Completer();

  Future<void> get isInitialized => _initCompleter.future;

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        // In a real app, you would validate the token with the backend
        // and fetch user details. For now, we'll just assume it's valid.
        // This is a placeholder for actual token validation and user fetching logic.
        state = User(id: 0, username: "cachedUser", isActive: true); // Dummy user
      }
    } catch (e) {
      // ignore
    } finally {
      _initCompleter.complete();
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final token = await _apiService.login(username, password);
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        // Assuming a successful login means we can set a dummy user for now
        // In a real app, fetch actual user data based on the token
        state = User(id: 1, username: username, isActive: true); // Dummy user
        return null; // No error
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
    return 'Login failed'; // Generic error
  }

  Future<String?> register(String username, String password) async {
    try {
      final user = await _apiService.register(username, password);
      if (user != null) {
        // Automatically log in after registration for convenience
        return await login(username, password);
      }
    } catch (e) {
      return e.toString();
    }
    return 'Registration failed';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    state = null;
  }
}

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});
