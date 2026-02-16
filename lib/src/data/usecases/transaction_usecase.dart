import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/data/repositories/transaction_repository.dart';

class FetchTransactionsUseCase {
  final TransactionRepository repository;

  FetchTransactionsUseCase(this.repository);

  /// Fetch transactions for the current authenticated user
  /// Requires valid Bearer token in Authorization header
  /// Sorted from latest to oldest
  Future<List<TransactionModel>> execute() async {
    final transactions = await repository.fetchAll();
    // Sort by date in descending order (latest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }
}
