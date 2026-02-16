import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    final testTransaction = TransactionModel(
      transactionId: 1,
      userId: 100,
      type: 'transfer',
      amount: 500.0,
      description: 'Money transfer to John',
      date: DateTime(2024, 1, 15, 10, 30),
      currency: 'PHP',
    );

    test('should create a TransactionModel instance with correct properties', () {
      expect(testTransaction.transactionId, equals(1));
      expect(testTransaction.userId, equals(100));
      expect(testTransaction.type, equals('transfer'));
      expect(testTransaction.amount, equals(500.0));
      expect(testTransaction.description, equals('Money transfer to John'));
      expect(testTransaction.currency, equals('PHP'));
    });

    test('should create a TransactionModel from JSON', () {
      final jsonData = {
        'transactionId': 1,
        'userId': 100,
        'type': 'transfer',
        'amount': 500.0,
        'description': 'Money transfer to John',
        'date': '2024-01-15T10:30:00.000',
        'currency': 'PHP',
      };

      final transaction = TransactionModel.fromJson(jsonData);

      expect(transaction.transactionId, equals(1));
      expect(transaction.userId, equals(100));
      expect(transaction.type, equals('transfer'));
      expect(transaction.amount, equals(500.0));
      expect(transaction.description, equals('Money transfer to John'));
      expect(transaction.currency, equals('PHP'));
    });

    test('should convert TransactionModel to JSON', () {
      final json = testTransaction.toJson();

      expect(json['transactionId'], equals(1));
      expect(json['userId'], equals(100));
      expect(json['type'], equals('transfer'));
      expect(json['amount'], equals(500.0));
      expect(json['description'], equals('Money transfer to John'));
      expect(json['currency'], equals('PHP'));
    });

    test('should handle fromJson with missing fields using defaults', () {
      final jsonData = {
        'transactionId': 2,
        'userId': 200,
      };

      final transaction = TransactionModel.fromJson(jsonData);

      expect(transaction.transactionId, equals(2));
      expect(transaction.userId, equals(200));
      expect(transaction.type, isEmpty);
      expect(transaction.amount, equals(0.0));
      expect(transaction.description, isEmpty);
      expect(transaction.currency, equals('PHP'));
    });

    test('should handle different transaction types', () {
      final transferTx = TransactionModel(
        transactionId: 1,
        userId: 1,
        type: 'transfer',
        amount: 100.0,
        description: 'Transfer',
        date: DateTime.now(),
        currency: 'PHP',
      );

      final depositTx = TransactionModel(
        transactionId: 2,
        userId: 1,
        type: 'deposit',
        amount: 500.0,
        description: 'Deposit',
        date: DateTime.now(),
        currency: 'PHP',
      );

      expect(transferTx.type, equals('transfer'));
      expect(depositTx.type, equals('deposit'));
    });

    test('should handle integer amounts and convert to double', () {
      final jsonData = {
        'transactionId': 3,
        'userId': 1,
        'type': 'withdrawal',
        'amount': 1000,
        'description': 'Withdrawal',
        'date': DateTime.now().toIso8601String(),
        'currency': 'PHP',
      };

      final transaction = TransactionModel.fromJson(jsonData);

      expect(transaction.amount, isA<double>());
      expect(transaction.amount, equals(1000.0));
    });

    test('should maintain date precision', () {
      final date = DateTime(2024, 6, 15, 14, 45, 30);
      final transaction = TransactionModel(
        transactionId: 4,
        userId: 1,
        type: 'transfer',
        amount: 250.0,
        description: 'Test',
        date: date,
        currency: 'PHP',
      );

      expect(transaction.date.year, equals(2024));
      expect(transaction.date.month, equals(6));
      expect(transaction.date.day, equals(15));
    });

    test('should round trip JSON conversion', () {
      final json = testTransaction.toJson();
      final restored = TransactionModel.fromJson(json);

      expect(restored.transactionId, equals(testTransaction.transactionId));
      expect(restored.userId, equals(testTransaction.userId));
      expect(restored.type, equals(testTransaction.type));
      expect(restored.amount, equals(testTransaction.amount));
      expect(restored.description, equals(testTransaction.description));
    });
  });
}
