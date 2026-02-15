class Wallet {
  final double balance;
  final String currency;

  Wallet({
    required this.balance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
    };
  }
}
