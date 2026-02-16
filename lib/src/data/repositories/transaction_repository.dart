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
    final response = await apiService.get('/api/transactions');
    
    final List data;
    if (response is List) {
      data = response;
    } else if (response is Map<String, dynamic>) {
      data = response['transactions'] ?? 
             response['data'] ?? 
             response['items'] ?? 
             [];
    } else {
      data = [];
    }

    return data.map((json) {
      return TransactionModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }
}
