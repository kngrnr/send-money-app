import 'package:send_money_app/src/core/models/wallet_model.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;

  WalletLoaded({required this.wallet});
}

class WalletError extends WalletState {
  final String message;

  WalletError({required this.message});
}
