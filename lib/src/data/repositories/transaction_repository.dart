

import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class TransactionRepository {
  Future<void> save(TransactionModel transaction);
  Future<List<TransactionModel>> fetchAll();
}


class TransactionRepositoryImpl implements TransactionRepository {
  final ApiService apiService;

  TransactionRepositoryImpl(this.apiService);

  @override
  Future<void> save(TransactionModel transaction) async {
    await apiService.post(
      '/transactions',
      data: {
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
      },
    );
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    final List data = await apiService.get('/transactions');

    return data.map((json) {
      return TransactionModel(
        amount: json['amount'].toDouble(),
        date: DateTime.parse(json['date']),
      );
    }).toList();
  }
}
