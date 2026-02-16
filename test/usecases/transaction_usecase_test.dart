import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/data/repositories/transaction_repository.dart';
import 'package:send_money_app/src/data/usecases/transaction_usecase.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late FetchTransactionsUseCase fetchTransactionsUseCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    fetchTransactionsUseCase = FetchTransactionsUseCase(mockRepository);
  });

  group('FetchTransactionsUseCase', () {
    test('should fetch and sort transactions from latest to oldest', () async {
      final testTransactions = [
        TransactionModel(
          transactionId: 1,
          userId: 1,
          type: 'transfer',
          amount: 100.0,
          description: 'Transfer to John',
          date: DateTime(2024, 1, 10),
          currency: 'PHP',
        ),
        TransactionModel(
          transactionId: 2,
          userId: 1,
          type: 'deposit',
          amount: 500.0,
          description: 'Deposit',
          date: DateTime(2024, 1, 5),
          currency: 'PHP',
        ),
        TransactionModel(
          transactionId: 3,
          userId: 1,
          type: 'withdrawal',
          amount: 200.0,
          description: 'Withdrawal',
          date: DateTime(2024, 1, 15),
          currency: 'PHP',
        ),
      ];

      when(() => mockRepository.fetchAll())
          .thenAnswer((_) async => testTransactions);

      final result = await fetchTransactionsUseCase.execute();

      expect(result.length, equals(3));
      // Should be sorted from latest (2024-01-15) to oldest (2024-01-05)
      expect(result[0].date, equals(DateTime(2024, 1, 15)));
      expect(result[1].date, equals(DateTime(2024, 1, 10)));
      expect(result[2].date, equals(DateTime(2024, 1, 5)));
    });

    test('should return empty list when no transactions exist', () async {
      when(() => mockRepository.fetchAll()).thenAnswer((_) async => []);

      final result = await fetchTransactionsUseCase.execute();

      expect(result, isEmpty);
      verify(() => mockRepository.fetchAll()).called(1);
    });

    test('should sort single transaction correctly', () async {
      final singleTransaction = [
        TransactionModel(
          transactionId: 1,
          userId: 1,
          type: 'transfer',
          amount: 100.0,
          description: 'Transfer to John',
          date: DateTime(2024, 1, 10),
          currency: 'PHP',
        ),
      ];

      when(() => mockRepository.fetchAll())
          .thenAnswer((_) async => singleTransaction);

      final result = await fetchTransactionsUseCase.execute();

      expect(result.length, equals(1));
      expect(result[0].transactionId, equals(1));
    });

    test('should propagate exception from repository', () async {
      when(() => mockRepository.fetchAll())
          .thenThrow(Exception('Network error'));

      expect(
        () => fetchTransactionsUseCase.execute(),
        throwsException,
      );
    });

    test('should sort transactions with same date correctly', () async {
      final sameDateTransactions = [
        TransactionModel(
          transactionId: 1,
          userId: 1,
          type: 'transfer',
          amount: 100.0,
          description: 'Transfer 1',
          date: DateTime(2024, 1, 10, 10, 0),
          currency: 'PHP',
        ),
        TransactionModel(
          transactionId: 2,
          userId: 1,
          type: 'transfer',
          amount: 200.0,
          description: 'Transfer 2',
          date: DateTime(2024, 1, 10, 11, 0),
          currency: 'PHP',
        ),
      ];

      when(() => mockRepository.fetchAll())
          .thenAnswer((_) async => sameDateTransactions);

      final result = await fetchTransactionsUseCase.execute();

      expect(result.length, equals(2));
      // Should be sorted from latest time
      expect(result[0].date, equals(DateTime(2024, 1, 10, 11, 0)));
      expect(result[1].date, equals(DateTime(2024, 1, 10, 10, 0)));
    });

    test('should handle large list of transactions', () async {
      final manyTransactions = List.generate(
        100,
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

      when(() => mockRepository.fetchAll())
          .thenAnswer((_) async => manyTransactions);

      final result = await fetchTransactionsUseCase.execute();

      expect(result.length, equals(100));
      // Verify latest is first
      expect(result[0].transactionId, equals(99));
      // Verify oldest is last
      expect(result[99].transactionId, equals(0));
    });

    test('should filter transactions by type', () async {
      final testTransactions = [
        TransactionModel(
          transactionId: 1,
          userId: 1,
          type: 'transfer',
          amount: 100.0,
          description: 'Transfer to John',
          date: DateTime(2024, 1, 10),
          currency: 'PHP',
        ),
        TransactionModel(
          transactionId: 2,
          userId: 1,
          type: 'deposit',
          amount: 500.0,
          description: 'Deposit',
          date: DateTime(2024, 1, 5),
          currency: 'PHP',
        ),
        TransactionModel(
          transactionId: 3,
          userId: 1,
          type: 'withdrawal',
          amount: 200.0,
          description: 'Withdrawal',
          date: DateTime(2024, 1, 15),
          currency: 'PHP',
        ),
      ];

      when(() => mockRepository.fetchAll())
          .thenAnswer((_) async => testTransactions);

      final result = await fetchTransactionsUseCase.execute();
      final transferTransactions =
          result.where((t) => t.type == 'transfer').toList();

      expect(transferTransactions.length, equals(1));
      expect(transferTransactions[0].type, equals('transfer'));
    });

    test('should verify repository is called exactly once', () async {
      when(() => mockRepository.fetchAll()).thenAnswer((_) async => []);

      await fetchTransactionsUseCase.execute();

      verify(() => mockRepository.fetchAll()).called(1);
    });
  });
}
