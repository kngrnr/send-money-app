import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class WalletRepository {
  Future<double> getBalance();
  Future<void> deductBalance(double amount);
}

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final ApiService apiService;

  WalletRepositoryImpl(this.apiService);

  @override
  Future<double> getBalance() async {
    final data = await apiService.get('/wallet/balance');
    return data['balance'].toDouble();
  }

  @override
  Future<void> deductBalance(double amount) async {
    await apiService.post(
      '/wallet/send',
      data: {'amount': amount},
    );
  }
}
