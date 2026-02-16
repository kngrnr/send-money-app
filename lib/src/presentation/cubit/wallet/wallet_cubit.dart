import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/data/usecases/wallet_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final DeductBalanceUseCase deductBalanceUseCase;

  WalletCubit({
    required this.getWalletUseCase,
    required this.deductBalanceUseCase,
  }) : super(WalletInitial());

  Future<void> fetchWallet() async {
    emit(WalletLoading());
    try {
      final wallet = await getWalletUseCase.execute();
      emit(WalletLoaded(wallet: wallet));
    } on DioException catch (e) {
      final errorMessage = (e.error is AppException)
          ? (e.error as AppException).message
          : e.message ?? 'An error occurred';
      emit(WalletError(message: errorMessage));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }

  Future<void> deductBalance(double amount) async {
    try {
      await deductBalanceUseCase.execute(amount);
      await fetchWallet();
    } on DioException catch (e) {
      final errorMessage = (e.error is AppException)
          ? (e.error as AppException).message
          : e.message ?? 'An error occurred';
      emit(WalletError(message: errorMessage));
    } catch (e) {
      emit(WalletError(message: e.toString()));
    }
  }
}
