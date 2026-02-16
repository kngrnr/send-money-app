import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/network/dio_client.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';
import 'package:send_money_app/src/data/repositories/transaction_repository.dart';
import 'package:send_money_app/src/data/repositories/wallet_repository.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';
import 'package:send_money_app/src/data/usecases/transaction_usecase.dart';
import 'package:send_money_app/src/data/usecases/wallet_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';

/// Injectable module for cubit and use case dependencies
@module
abstract class CubitModule {
  /// Auth Use Cases
  @lazySingleton
  LoginUseCase loginUseCase(AuthRepository repository) =>
      LoginUseCase(repository);

  @lazySingleton
  LogoutUseCase logoutUseCase(AuthRepository repository) =>
      LogoutUseCase(repository);

  /// Wallet Use Cases
  @lazySingleton
  GetWalletUseCase getWalletUseCase(WalletRepository repository) =>
      GetWalletUseCase(repository);

  @lazySingleton
  DeductBalanceUseCase deductBalanceUseCase(WalletRepository repository) =>
      DeductBalanceUseCase(repository);

  /// Transaction Use Cases
  @lazySingleton
  FetchTransactionsUseCase fetchTransactionsUseCase(
    TransactionRepository repository,
  ) =>
      FetchTransactionsUseCase(repository);

  /// Auth Cubit
  @lazySingleton
  AuthCubit authCubit(
    LoginUseCase loginUseCase,
    LogoutUseCase logoutUseCase,
    DioClient dioClient,
  ) =>
      AuthCubit(loginUseCase, logoutUseCase, dioClient);

  /// Wallet Cubit
  @lazySingleton
  WalletCubit walletCubit(
    GetWalletUseCase getWalletUseCase,
    DeductBalanceUseCase deductBalanceUseCase,
  ) =>
      WalletCubit(
        getWalletUseCase: getWalletUseCase,
        deductBalanceUseCase: deductBalanceUseCase,
      );

  /// Transaction History Cubit
  @lazySingleton
  TransactionHistoryCubit transactionHistoryCubit(
    FetchTransactionsUseCase fetchTransactionsUseCase,
  ) =>
      TransactionHistoryCubit(
        fetchTransactionsUseCase: fetchTransactionsUseCase,
      );
}
