import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class WalletRepository {
  Future<Wallet> getBalance();
  Future<void> deductBalance(double amount);
}

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final ApiService apiService;
  
  WalletRepositoryImpl(this.apiService);

  @override
  Future<Wallet> getBalance() async {
    final data = await apiService.get('/api/balance');
    return Wallet.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deductBalance(double amount) async {
    await apiService.post(
      '/wallet/send',
      data: {'amount': amount},
    );
  }
}

