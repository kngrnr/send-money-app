import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/core/network/api_service.dart';
import 'package:send_money_app/src/data/repositories/transaction_repository.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late TransactionRepositoryImpl transactionRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    transactionRepository = TransactionRepositoryImpl(mockApiService);
  });

  group('TransactionRepository - fetchAll', () {
    test('should fetch transactions successfully from list response', () async {
      final responseData = [
        {
          'transactionId': 1,
          'userId': 1,
          'type': 'transfer',
          'amount': 100.0,
          'description': 'Transfer to John',
          'date': '2024-01-15T10:30:00.000',
          'currency': 'PHP',
        },
        {
          'transactionId': 2,
          'userId': 1,
          'type': 'deposit',
          'amount': 500.0,
          'description': 'Deposit',
          'date': '2024-01-10T14:45:00.000',
          'currency': 'PHP',
        },
      ];

      when(() => mockApiService.get('/api/transactions'))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(2));
      expect(result[0].transactionId, equals(1));
      expect(result[1].transactionId, equals(2));
    });

    test('should fetch transactions from nested array in response', () async {
      final responseData = {
        'transactions': [
          {
            'transactionId': 1,
            'userId': 1,
            'type': 'transfer',
            'amount': 100.0,
            'description': 'Transfer',
            'date': '2024-01-15T10:30:00.000',
            'currency': 'PHP',
          },
        ],
      };

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(1));
      expect(result[0].transactionId, equals(1));
    });

    test('should fetch from data array if transactions not found', () async {
      final responseData = {
        'data': [
          {
            'transactionId': 1,
            'userId': 1,
            'type': 'transfer',
            'amount': 100.0,
            'description': 'Transfer',
            'date': '2024-01-15T10:30:00.000',
            'currency': 'PHP',
          },
        ],
      };

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(1));
    });

    test('should fetch from items array if data not found', () async {
      final responseData = {
        'items': [
          {
            'transactionId': 1,
            'userId': 1,
            'type': 'transfer',
            'amount': 100.0,
            'description': 'Transfer',
            'date': '2024-01-15T10:30:00.000',
            'currency': 'PHP',
          },
        ],
      };

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(1));
    });

    test('should return empty list when no transactions found', () async {
      final responseData = <String, dynamic>{};

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result, isEmpty);
    });

    test('should call correct API endpoint', () async {
      when(() => mockApiService.get(any())).thenAnswer((_) async => []);

      await transactionRepository.fetchAll();

      verify(() => mockApiService.get('/api/transactions')).called(1);
    });

    test('should propagate exception from API', () async {
      when(() => mockApiService.get(any()))
          .thenThrow(Exception('Network error'));

      expect(
        () => transactionRepository.fetchAll(),
        throwsException,
      );
    });

    test('should parse multiple transactions correctly', () async {
      final responseData = [
        {
          'transactionId': 1,
          'userId': 1,
          'type': 'transfer',
          'amount': 100.0,
          'description': 'Transfer 1',
          'date': '2024-01-15T10:30:00.000',
          'currency': 'PHP',
        },
        {
          'transactionId': 2,
          'userId': 1,
          'type': 'deposit',
          'amount': 500.0,
          'description': 'Deposit',
          'date': '2024-01-14T14:45:00.000',
          'currency': 'PHP',
        },
        {
          'transactionId': 3,
          'userId': 1,
          'type': 'withdrawal',
          'amount': 200.0,
          'description': 'Withdrawal',
          'date': '2024-01-13T09:15:00.000',
          'currency': 'PHP',
        },
      ];

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(3));
      expect(result[0].type, equals('transfer'));
      expect(result[1].type, equals('deposit'));
      expect(result[2].type, equals('withdrawal'));
    });

    test('should handle various response formats', () async {
      // Test with direct list response
      when(() => mockApiService.get(any())).thenAnswer((_) async => [
            {
              'transactionId': 1,
              'userId': 1,
              'type': 'transfer',
              'amount': 100.0,
              'description': 'Test',
              'date': '2024-01-15T10:30:00.000',
              'currency': 'PHP',
            },
          ]);

      final result = await transactionRepository.fetchAll();

      expect(result, isNotEmpty);
      expect(result[0], isA<TransactionModel>());
    });

    test('should create TransactionModel objects correctly', () async {
      final responseData = [
        {
          'transactionId': 100,
          'userId': 50,
          'type': 'transfer',
          'amount': 1500.75,
          'description': 'Test transaction',
          'date': '2024-06-15T12:00:00.000',
          'currency': 'USD',
        },
      ];

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await transactionRepository.fetchAll();

      expect(result.length, equals(1));
      expect(result[0].transactionId, equals(100));
      expect(result[0].userId, equals(50));
      expect(result[0].amount, equals(1500.75));
    });
  });
}
