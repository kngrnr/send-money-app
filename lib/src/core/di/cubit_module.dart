import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';

/// Injectable module for cubit and use case dependencies
@module
abstract class CubitModule {
  /// Provides LoginUseCase
  @lazySingleton
  LoginUseCase loginUseCase(AuthRepository repository) =>
      LoginUseCase(repository);

  /// Provides LogoutUseCase
  @lazySingleton
  LogoutUseCase logoutUseCase(AuthRepository repository) =>
      LogoutUseCase(repository);

  /// Provides AuthCubit
  @lazySingleton
  AuthCubit authCubit(LoginUseCase loginUseCase, LogoutUseCase logoutUseCase) =>
      AuthCubit(loginUseCase, logoutUseCase);
}
