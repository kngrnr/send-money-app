abstract class WalletRepository {
  Future<double> getBalance();
  Future<void> deductBalance(double amount);
}

class WalletRepositoryImpl implements WalletRepository {
  double _balance = 0.00;

  @override
  Future<double> getBalance() async {
    return _balance;
  }

  @override
  Future<void> deductBalance(double amount) async {
    if (amount > _balance) {
      throw Exception('Insufficient balance');
    }
    _balance -= amount;
  }
}
