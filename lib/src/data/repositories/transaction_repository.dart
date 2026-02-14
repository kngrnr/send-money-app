

import 'package:send_money_app/src/core/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<void> save(TransactionModel transaction);
  Future<List<TransactionModel>> fetchAll();
}

class TransactionRepositoryImpl implements TransactionRepository {
  final List<TransactionModel> _transactions = [];

  @override
  Future<void> save(TransactionModel transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    return List.unmodifiable(_transactions);
  }
}