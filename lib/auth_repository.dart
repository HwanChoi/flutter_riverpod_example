import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// A simple User model.
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

/// A repository for handling authentication.
class AuthRepository {
  /// Logs in a user with the given username and password.
  ///
  /// In a real app, this would make a network request to your backend.
  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'test' && password == 'password') {
      return User(id: '1', name: 'Test User');
    } else {
      throw Exception('Invalid username or password');
    }
  }

  /// Logs out the user.
  Future<void> logout() async {
    // In a real app, you might clear tokens or session data.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Provider for the [AuthRepository].
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}

/// Controller for authentication state.
///
/// This uses an [AsyncNotifier] to manage the asynchronous state of logging in.
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    // Initially, no user is logged in.
    return null;
  }

  /// Logs in the user and updates the state.
  Future<void> login(String username, String password) async {
    // Set the state to loading.
    state = const AsyncValue.loading();
    try {
      // Inject the repository and call the login method.
      final user = await ref.read(authRepositoryProvider).login(username, password);
      // If login is successful, update the state with the user data.
      state = AsyncValue.data(user);
    } catch (e, st) {
      // If login fails, update the state with the error.
      state = AsyncValue.error(e, st);
    }
  }

  /// Logs out the user and updates the state.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    // Set the state back to null (no user logged in).
    state = const AsyncValue.data(null);
  }
}
