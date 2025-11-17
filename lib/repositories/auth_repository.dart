class AuthRepository {
  /// 사용자 이름과 비밀번호로 로그인을 시도합니다.
  /// 성공하면 사용자 이름을, 실패하면 예외를 발생시킵니다.
  Future<String> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'test' && password == '1234') {
      return username;
    } else {
      throw Exception('Invalid username or password');
    }
  }
}