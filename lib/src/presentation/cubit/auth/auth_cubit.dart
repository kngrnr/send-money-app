import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/core/network/dio_client.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final DioClient dioClient;

  AuthCubit(
    this.loginUseCase,
    this.logoutUseCase,
    this.dioClient,
  ) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final response = await loginUseCase.execute(username, password);
      dioClient.setToken(response.token);
      emit(AuthLoaded(user: response.user, token: response.token));
    } on AppException catch (e) {
      if (e.code == 'INVALID_CREDENTIALS') {
        emit(InvalidCredentials(e.message));
      } else {
        emit(AuthError(e.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      logoutUseCase.execute();
      dioClient.clearToken();
      emit(AuthUnauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}