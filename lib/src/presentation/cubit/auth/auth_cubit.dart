import 'package:dio/dio.dart';
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
    } on DioException catch (e) {
      final errorMessage = (e.error is AppException)
          ? (e.error as AppException).message
          : e.message ?? 'An error occurred';
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      dioClient.clearToken();
      emit(AuthUnauthenticated());
    } on DioException catch (e) {
      final errorMessage = (e.error is AppException)
          ? (e.error as AppException).message
          : e.message ?? 'An error occurred';
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}