import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class TransactionRepository {
  /// Fetch transactions for the current authenticated user
  /// Requires valid Bearer token in Authorization header
  Future<List<TransactionModel>> fetchAll();
}

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final ApiService apiService;

  TransactionRepositoryImpl(this.apiService);

  @override
  Future<List<TransactionModel>> fetchAll() async {
    final List data = await apiService.get('/api/transactions');

    return data.map((json) {
      return TransactionModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }
}
