import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/data/usecases/transaction_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final FetchTransactionsUseCase fetchTransactionsUseCase;

  TransactionHistoryCubit({
    required this.fetchTransactionsUseCase,
  }) : super(TransactionHistoryInitial());

  /// Fetch transactions for the current authenticated user
  Future<void> fetchTransactions() async {
    emit(TransactionHistoryLoading());
    try {
      final transactions = await fetchTransactionsUseCase.execute();
      emit(TransactionHistoryLoaded(transactions: transactions));
    } on DioException catch (e) {
      final errorMessage = (e.error is AppException)
          ? (e.error as AppException).message
          : e.message ?? 'An error occurred';
      emit(TransactionHistoryError(message: errorMessage));
    } catch (e) {
      emit(TransactionHistoryError(message: e.toString()));
    }
  }
}
