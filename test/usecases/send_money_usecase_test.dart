import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/send_money_response.dart';
import 'package:send_money_app/src/data/repositories/send_money_repository.dart';
import 'package:send_money_app/src/data/usecases/send_money_usecase.dart';

class MockSendMoneyRepository extends Mock implements SendMoneyRepository {}

void main() {
  late SendMoneyUseCase sendMoneyUseCase;
  late MockSendMoneyRepository mockRepository;

  setUp(() {
    mockRepository = MockSendMoneyRepository();
    sendMoneyUseCase = SendMoneyUseCase(mockRepository);
  });

  group('SendMoneyUseCase', () {
    final testResponse = SendMoneyResponse(
      message: 'Money sent successfully',
      success: true,
      transactionId: 'TXN123456',
    );

    test('should execute send money successfully with valid parameters', () async {
      when(
        () => mockRepository.sendMoney(
          recipientUsername: 'jane',
          amount: 500.0,
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await sendMoneyUseCase.execute(
        recipientUsername: 'jane',
        amount: 500.0,
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Money sent successfully'));
      expect(result.transactionId, equals('TXN123456'));
      verify(
        () => mockRepository.sendMoney(
          recipientUsername: 'jane',
          amount: 500.0,
        ),
      ).called(1);
    });

    test('should pass parameters to repository correctly', () async {
      when(
        () => mockRepository.sendMoney(
          recipientUsername: 'recipient',
          amount: 1000.0,
        ),
      ).thenAnswer((_) async => testResponse);

      await sendMoneyUseCase.execute(
        recipientUsername: 'recipient',
        amount: 1000.0,
      );

      verify(
        () => mockRepository.sendMoney(
          recipientUsername: 'recipient',
          amount: 1000.0,
        ),
      ).called(1);
    });

    test('should propagate exception from repository', () async {
      final exception = Exception('Network error');

      when(
        () => mockRepository.sendMoney(
          recipientUsername: any(named: 'recipientUsername'),
          amount: any(named: 'amount'),
        ),
      ).thenThrow(exception);

      expect(
        () => sendMoneyUseCase.execute(
          recipientUsername: 'jane',
          amount: 500.0,
        ),
        throwsException,
      );
    });

    test('should handle failed transaction response', () async {
      final failedResponse = SendMoneyResponse(
        message: 'Insufficient balance',
        success: false,
      );

      when(
        () => mockRepository.sendMoney(
          recipientUsername: any(named: 'recipientUsername'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async => failedResponse);

      final result = await sendMoneyUseCase.execute(
        recipientUsername: 'jane',
        amount: 5000.0,
      );

      expect(result.success, isFalse);
      expect(result.message, equals('Insufficient balance'));
    });

    test('should handle different amounts', () async {
      when(
        () => mockRepository.sendMoney(
          recipientUsername: any(named: 'recipientUsername'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async => testResponse);

      final amounts = [10.0, 100.0, 1000.0, 9999.99];

      for (final amount in amounts) {
        final result = await sendMoneyUseCase.execute(
          recipientUsername: 'user',
          amount: amount,
        );

        expect(result.success, isTrue);
      }
    });
  });
}
