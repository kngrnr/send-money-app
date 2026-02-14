abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<void> logout();
}   

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> login(String email, String password) async {
    return true;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(seconds: 1));
  }
}
