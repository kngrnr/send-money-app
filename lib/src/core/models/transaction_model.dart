class TransactionModel {
  final int transactionId;
  final int userId;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final String currency;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.currency,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: (json['transactionId'] as int?) ?? 0,
      userId: (json['userId'] as int?) ?? 0,
      type: json['type'] as String? ?? '',
      amount: ((json['amount'] as num?)?.toDouble()) ?? 0.0,
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      currency: json['currency'] as String? ?? 'PHP',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'currency': currency,
    };
  }
}
