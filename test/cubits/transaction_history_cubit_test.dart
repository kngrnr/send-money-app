import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/data/usecases/transaction_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_state.dart';

class MockFetchTransactionsUseCase extends Mock
    implements FetchTransactionsUseCase {}

void main() {
  late TransactionHistoryCubit transactionHistoryCubit;
  late MockFetchTransactionsUseCase mockFetchTransactionsUseCase;

  setUp(() {
    mockFetchTransactionsUseCase = MockFetchTransactionsUseCase();
    transactionHistoryCubit = TransactionHistoryCubit(
      fetchTransactionsUseCase: mockFetchTransactionsUseCase,
    );
  });

  tearDown(() {
    transactionHistoryCubit.close();
  });

  group('TransactionHistoryCubit', () {
    final testTransactions = [
      TransactionModel(
        transactionId: 1,
        userId: 1,
        type: 'transfer',
        amount: 100.0,
        description: 'Transfer to John',
        date: DateTime(2024, 1, 15),
        currency: 'PHP',
      ),
      TransactionModel(
        transactionId: 2,
        userId: 1,
        type: 'deposit',
        amount: 500.0,
        description: 'Deposit',
        date: DateTime(2024, 1, 10),
        currency: 'PHP',
      ),
    ];

    test('initial state is TransactionHistoryInitial', () {
      expect(transactionHistoryCubit.state,
          isA<TransactionHistoryInitial>());
    });

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should emit [TransactionHistoryLoading, TransactionHistoryLoaded] on successful fetch',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => testTransactions);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryLoaded>()
            .having((state) => state.transactions.length, 'transactions length',
                2)
            .having((state) => state.transactions[0].transactionId,
                'first transaction id', 1),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should emit [TransactionHistoryLoading, TransactionHistoryError] on failure',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenThrow(Exception('Network error'));

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryError>(),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should handle empty transaction list',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => []);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryLoaded>()
            .having((state) => state.transactions.length, 'transactions length',
                0),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should emit multiple transactions correctly',
      build: () {
        final manyTransactions = List.generate(
          10,
          (index) => TransactionModel(
            transactionId: index,
            userId: 1,
            type: 'transfer',
            amount: 100.0 * index,
            description: 'Transaction $index',
            date: DateTime(2024, 1, 1).add(Duration(days: index)),
            currency: 'PHP',
          ),
        );

        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => manyTransactions);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryLoaded>()
            .having((state) => state.transactions.length, 'transactions length',
                10),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should load transactions correctly with proper data',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => testTransactions);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryLoaded>(),
      ],
      verify: (_) {
        verify(() => mockFetchTransactionsUseCase.execute()).called(1);
      },
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should verify usecase is called',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => testTransactions);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      verify: (_) {
        verify(() => mockFetchTransactionsUseCase.execute()).called(1);
      },
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should handle API errors gracefully',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenThrow(Exception('API Error: 500'));

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryError>()
            .having((state) => state.message, 'message', contains('Error')),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'should contain transaction details in loaded state',
      build: () {
        when(() => mockFetchTransactionsUseCase.execute())
            .thenAnswer((_) async => testTransactions);

        return transactionHistoryCubit;
      },
      act: (cubit) => cubit.fetchTransactions(),
      expect: () => [
        isA<TransactionHistoryLoading>(),
        isA<TransactionHistoryLoaded>()
            .having((state) => state.transactions[0].amount, 'amount', 100.0)
            .having((state) => state.transactions[0].type, 'type', 'transfer'),
      ],
    );
  });
}
