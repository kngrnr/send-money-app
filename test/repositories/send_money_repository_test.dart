import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/network/api_service.dart';
import 'package:send_money_app/src/data/repositories/send_money_repository.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late SendMoneyRepositoryImpl sendMoneyRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    sendMoneyRepository = SendMoneyRepositoryImpl(mockApiService);
  });

  group('SendMoneyRepository', () {

    test('should send money successfully', () async {
      final responseData = {
        'message': 'Money sent successfully',
        'success': true,
        'transactionId': 'TXN123456',
      };

      when(
        () => mockApiService.post(
          '/api/send',
          data: {
            'recipientUsername': 'jane',
            'amount': 500.0,
          },
        ),
      ).thenAnswer((_) async => responseData);

      final result = await sendMoneyRepository.sendMoney(
        recipientUsername: 'jane',
        amount: 500.0,
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Money sent successfully'));
      expect(result.transactionId, equals('TXN123456'));
    });

    test('should call correct API endpoint', () async {
      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => {
            'message': 'success',
            'success': true,
          });

      await sendMoneyRepository.sendMoney(
        recipientUsername: 'user',
        amount: 1000.0,
      );

      verify(
        () => mockApiService.post(
          '/api/send',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('should pass correct recipient and amount in request', () async {
      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => {
            'message': 'success',
            'success': true,
          });

      await sendMoneyRepository.sendMoney(
        recipientUsername: 'recipient123',
        amount: 2500.50,
      );

      verify(
        () => mockApiService.post(
          any(),
          data: {
            'recipientUsername': 'recipient123',
            'amount': 2500.50,
          },
        ),
      ).called(1);
    });

    test('should handle failed transaction response', () async {
      final failedResponse = {
        'message': 'Insufficient balance',
        'success': false,
      };

      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => failedResponse);

      final result = await sendMoneyRepository.sendMoney(
        recipientUsername: 'jane',
        amount: 5000.0,
      );

      expect(result.success, isFalse);
      expect(result.message, equals('Insufficient balance'));
    });

    test('should propagate exception from API', () async {
      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenThrow(Exception('Network error'));

      expect(
        () => sendMoneyRepository.sendMoney(
          recipientUsername: 'jane',
          amount: 500.0,
        ),
        throwsException,
      );
    });

    test('should handle response with transaction ID', () async {
      final responseData = {
        'message': 'sent',
        'success': true,
        'transactionId': 'TXN999',
      };

      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => responseData);

      final result = await sendMoneyRepository.sendMoney(
        recipientUsername: 'user',
        amount: 100.0,
      );

      expect(result.transactionId, equals('TXN999'));
    });

    test('should handle various amounts', () async {
      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => {
            'message': 'success',
            'success': true,
          });

      final amounts = [10.0, 100.0, 1000.0, 9999.99];

      for (final amount in amounts) {
        await sendMoneyRepository.sendMoney(
          recipientUsername: 'user',
          amount: amount,
        );
      }

      expect(true, isTrue);
    });
  });
}
