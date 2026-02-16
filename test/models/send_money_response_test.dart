import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/send_money_response.dart';

void main() {
  group('SendMoneyResponse Model', () {
    final testResponse = SendMoneyResponse(
      message: 'Money sent successfully',
      success: true,
      transactionId: 'TXN123456',
    );

    test('should create a SendMoneyResponse instance with correct properties', () {
      expect(testResponse.message, equals('Money sent successfully'));
      expect(testResponse.success, isTrue);
      expect(testResponse.transactionId, equals('TXN123456'));
    });

    test('should create a SendMoneyResponse from JSON', () {
      final jsonData = {
        'message': 'Money sent successfully',
        'success': true,
        'transactionId': 'TXN123456',
      };

      final response = SendMoneyResponse.fromJson(jsonData);

      expect(response.message, equals('Money sent successfully'));
      expect(response.success, isTrue);
      expect(response.transactionId, equals('TXN123456'));
    });

    test('should convert SendMoneyResponse to JSON', () {
      final json = testResponse.toJson();

      expect(json['message'], equals('Money sent successfully'));
      expect(json['success'], isTrue);
      expect(json['transactionId'], equals('TXN123456'));
    });

    test('should handle fromJson with missing transactionId', () {
      final jsonData = {
        'message': 'Transaction failed',
        'success': false,
      };

      final response = SendMoneyResponse.fromJson(jsonData);

      expect(response.message, equals('Transaction failed'));
      expect(response.success, isFalse);
      expect(response.transactionId, isNull);
    });

    test('should handle fromJson with default values', () {
      final jsonData = <String, dynamic>{};

      final response = SendMoneyResponse.fromJson(jsonData);

      expect(response.message, isEmpty);
      expect(response.success, isFalse);
      expect(response.transactionId, isNull);
    });

    test('should round trip JSON conversion', () {
      final jsonData = {
        'message': 'Transaction pending',
        'success': true,
        'transactionId': 'TXN789012',
      };

      final response = SendMoneyResponse.fromJson(jsonData);
      final json = response.toJson();

      expect(json['message'], equals('Transaction pending'));
      expect(json['success'], isTrue);
      expect(json['transactionId'], equals('TXN789012'));
    });
  });
}
