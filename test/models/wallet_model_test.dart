import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';

void main() {
  group('Wallet Model', () {
    final testWallet = Wallet(
      balance: 5000.50,
      currency: 'PHP',
    );

    test('should create a Wallet instance with correct properties', () {
      expect(testWallet.balance, equals(5000.50));
      expect(testWallet.currency, equals('PHP'));
    });

    test('should create a Wallet from JSON', () {
      final jsonData = {
        'balance': 5000.50,
        'currency': 'PHP',
      };

      final wallet = Wallet.fromJson(jsonData);

      expect(wallet.balance, equals(5000.50));
      expect(wallet.currency, equals('PHP'));
    });

    test('should convert integer balance to double in fromJson', () {
      final jsonData = {
        'balance': 1000,
        'currency': 'USD',
      };

      final wallet = Wallet.fromJson(jsonData);

      expect(wallet.balance, isA<double>());
      expect(wallet.balance, equals(1000.0));
    });

    test('should convert Wallet to JSON', () {
      final json = testWallet.toJson();

      expect(json['balance'], equals(5000.50));
      expect(json['currency'], equals('PHP'));
    });

    test('should handle zero balance', () {
      final wallet = Wallet(balance: 0.0, currency: 'PHP');

      expect(wallet.balance, equals(0.0));
      expect(wallet.currency, equals('PHP'));
    });

    test('should handle different currencies', () {
      final walletUSD = Wallet(balance: 1000.0, currency: 'USD');
      final walletEUR = Wallet(balance: 1000.0, currency: 'EUR');

      expect(walletUSD.currency, equals('USD'));
      expect(walletEUR.currency, equals('EUR'));
    });

    test('should maintain balance precision', () {
      final jsonData = {
        'balance': 123.456789,
        'currency': 'PHP',
      };

      final wallet = Wallet.fromJson(jsonData);

      expect(wallet.balance, equals(123.456789));
    });

    test('should round trip JSON conversion', () {
      final original = Wallet(balance: 9999.99, currency: 'GBP');
      final json = original.toJson();
      final restored = Wallet.fromJson(json);

      expect(restored.balance, equals(original.balance));
      expect(restored.currency, equals(original.currency));
    });
  });
}
