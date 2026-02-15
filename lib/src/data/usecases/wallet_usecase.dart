import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/data/repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  Future<Wallet> execute() {
    return repository.getBalance();
  }
}

class DeductBalanceUseCase {
  final WalletRepository repository;

  DeductBalanceUseCase(this.repository);

  Future<void> execute(double amount) {
    return repository.deductBalance(amount);
  }
}
