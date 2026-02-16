import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponse> execute(String username, String password) async {
    // Validate input
    if (username.isEmpty) {
      throw AppException(
        message: 'Username is required',
        code: 'EMPTY_USERNAME',
      );
    }
    if (password.isEmpty) {
      throw AppException(
        message: 'Password is required',
        code: 'EMPTY_PASSWORD',
      );
    }
    
    try {
      return await repository.login(username, password);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'An unexpected error occurred during login',
        originalException: e,
      );
    }
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}