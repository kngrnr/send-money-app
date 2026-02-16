import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> logout();
}   

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<LoginResponse> login(String username, String password) async {
    final data = await apiService.post(
      '/api/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await apiService.post('/api/logout');
  }
}

