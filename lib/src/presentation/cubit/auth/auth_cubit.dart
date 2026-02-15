import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit(
    this.loginUseCase,
    this.logoutUseCase,
  ) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final response = await loginUseCase.execute(username, password);
      emit(AuthLoaded(user: response.user, token: response.token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}