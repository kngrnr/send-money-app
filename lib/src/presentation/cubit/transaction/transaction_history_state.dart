import 'package:send_money_app/src/core/models/transaction_model.dart';

abstract class TransactionHistoryState {}

class TransactionHistoryInitial extends TransactionHistoryState {}

class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionModel> transactions;

  TransactionHistoryLoaded({required this.transactions});
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;

  TransactionHistoryError({required this.message});
}
