import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_demo/providers.dart';

// 로그인 상태를 나타내는 클래스 (로딩, 성공, 실패, 초기상태)
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String username;
  AuthSuccess(this.username);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// 로그인 로직을 처리하고 상태를 관리하는 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    state = AuthLoading(); // 상태를 '로딩 중'으로 변경
    try {
      // ref를 통해 AuthRepository 인스턴스를 읽어와서 사용
      final repository = _ref.read(authRepositoryProvider);
      final loggedInUser = await repository.login(username, password);
      state = AuthSuccess(loggedInUser); // 성공 시 상태 변경
    } catch (e) {
      state = AuthError(e.toString()); // 실패 시 상태 변경
    }
  }

  void logout() {
    state = AuthInitial(); // 로그아웃 시 초기 상태로 변경
  }
}

// AuthNotifier를 제공하는 StateNotifierProvider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref);
});
