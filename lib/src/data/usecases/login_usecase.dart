import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponse> execute(String username, String password) {
    return repository.login(username, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}