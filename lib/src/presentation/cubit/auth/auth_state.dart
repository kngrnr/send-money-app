import 'package:send_money_app/src/core/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthLoaded extends AuthState {
  final User user;
  final String token;

  AuthLoaded({required this.user, required this.token});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}