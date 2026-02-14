import 'package:send_money_app/src/core/network/api_service.dart';

abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<void> logout();
}   


class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<bool> login(String username, String password) async {
    final data = await apiService.post(
      '/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    return data['success'] == true;
  }

  @override
  Future<void> logout() async {
    await apiService.post('/logout');
  }
}
