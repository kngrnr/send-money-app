import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/send_money_response.dart';
import 'package:send_money_app/src/data/usecases/send_money_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_state.dart';

class MockSendMoneyUseCase extends Mock implements SendMoneyUseCase {}

void main() {
  late SendMoneyCubit sendMoneyCubit;
  late MockSendMoneyUseCase mockSendMoneyUseCase;

  setUp(() {
    mockSendMoneyUseCase = MockSendMoneyUseCase();
    sendMoneyCubit = SendMoneyCubit(sendMoneyUseCase: mockSendMoneyUseCase);
  });

  tearDown(() {
    sendMoneyCubit.close();
  });

  group('SendMoneyCubit', () {
    final testResponse = SendMoneyResponse(
      message: 'Money sent successfully',
      success: true,
      transactionId: 'TXN123456',
    );

    test('initial state is SendMoneyInitial', () {
      expect(sendMoneyCubit.state, isA<SendMoneyInitial>());
    });

    blocTest<SendMoneyCubit, SendMoneyState>(
      'should emit [SendMoneyLoading, SendMoneySuccess] on successful send',
      build: () {
        when(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: 'jane',
            amount: 500.0,
          ),
        ).thenAnswer((_) async => testResponse);

        return sendMoneyCubit;
      },
      act: (cubit) => cubit.sendMoney(
        recipientUsername: 'jane',
        amount: 500.0,
      ),
      expect: () => [
        isA<SendMoneyLoading>(),
        isA<SendMoneySuccess>()
            .having((state) => state.message, 'message',
                'Money sent successfully')
            .having((state) => state.transactionId, 'transactionId',
                'TXN123456'),
      ],
    );

    blocTest<SendMoneyCubit, SendMoneyState>(
      'should emit [SendMoneyLoading, SendMoneyError] on failure',
      build: () {
        when(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: any(named: 'recipientUsername'),
            amount: any(named: 'amount'),
          ),
        ).thenThrow(Exception('Network error'));

        return sendMoneyCubit;
      },
      act: (cubit) => cubit.sendMoney(
        recipientUsername: 'jane',
        amount: 500.0,
      ),
      expect: () => [
        isA<SendMoneyLoading>(),
        isA<SendMoneyError>(),
      ],
    );

    blocTest<SendMoneyCubit, SendMoneyState>(
      'should pass correct parameters to usecase',
      build: () {
        when(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: any(named: 'recipientUsername'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => testResponse);

        return sendMoneyCubit;
      },
      act: (cubit) => cubit.sendMoney(
        recipientUsername: 'recipient123',
        amount: 1500.75,
      ),
      verify: (_) {
        verify(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: 'recipient123',
            amount: 1500.75,
          ),
        ).called(1);
      },
    );

    blocTest<SendMoneyCubit, SendMoneyState>(
      'should emit success with transaction ID',
      build: () {
        final responseWithId = SendMoneyResponse(
          message: 'Sent',
          success: true,
          transactionId: 'TXN999888',
        );

        when(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: any(named: 'recipientUsername'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => responseWithId);

        return sendMoneyCubit;
      },
      act: (cubit) => cubit.sendMoney(
        recipientUsername: 'user',
        amount: 100.0,
      ),
      expect: () => [
        isA<SendMoneyLoading>(),
        isA<SendMoneySuccess>()
            .having((state) => state.transactionId, 'transactionId',
                'TXN999888'),
      ],
    );

    blocTest<SendMoneyCubit, SendMoneyState>(
      'should emit error with error message',
      build: () {
        when(
          () => mockSendMoneyUseCase.execute(
            recipientUsername: any(named: 'recipientUsername'),
            amount: any(named: 'amount'),
          ),
        ).thenThrow(Exception('Insufficient balance'));

        return sendMoneyCubit;
      },
      act: (cubit) => cubit.sendMoney(
        recipientUsername: 'user',
        amount: 10000.0,
      ),
      expect: () => [
        isA<SendMoneyLoading>(),
        isA<SendMoneyError>()
            .having((state) => state.message, 'message', contains('balance')),
      ],
    );
  });
}
