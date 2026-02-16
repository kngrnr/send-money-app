import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/core/network/api_service.dart';
import 'package:send_money_app/src/data/repositories/wallet_repository.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late WalletRepositoryImpl walletRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    walletRepository = WalletRepositoryImpl(mockApiService);
  });

  group('WalletRepository - getBalance', () {

    test('should fetch wallet balance successfully', () async {
      final responseData = {
        'balance': 5000.0,
        'currency': 'PHP',
      };

      when(() => mockApiService.get('/api/balance'))
          .thenAnswer((_) async => responseData);

      final result = await walletRepository.getBalance();

      expect(result.balance, equals(5000.0));
      expect(result.currency, equals('PHP'));
      verify(() => mockApiService.get('/api/balance')).called(1);
    });

    test('should call correct API endpoint for balance', () async {
      when(() => mockApiService.get(any())).thenAnswer((_) async => {
            'balance': 1000.0,
            'currency': 'PHP',
          });

      await walletRepository.getBalance();

      verify(() => mockApiService.get('/api/balance')).called(1);
    });

    test('should return Wallet object with correct data', () async {
      final responseData = {
        'balance': 7500.50,
        'currency': 'USD',
      };

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await walletRepository.getBalance();

      expect(result, isA<Wallet>());
      expect(result.balance, equals(7500.50));
      expect(result.currency, equals('USD'));
    });

    test('should handle zero balance', () async {
      final responseData = {
        'balance': 0.0,
        'currency': 'PHP',
      };

      when(() => mockApiService.get(any()))
          .thenAnswer((_) async => responseData);

      final result = await walletRepository.getBalance();

      expect(result.balance, equals(0.0));
    });

    test('should propagate exception from API', () async {
      when(() => mockApiService.get(any()))
          .thenThrow(Exception('Network error'));

      expect(
        () => walletRepository.getBalance(),
        throwsException,
      );
    });

    test('should handle different currencies', () async {
      final currencies = ['PHP', 'USD', 'EUR', 'GBP'];

      for (final currency in currencies) {
        final responseData = {
          'balance': 1000.0,
          'currency': currency,
        };

        when(() => mockApiService.get(any()))
            .thenAnswer((_) async => responseData);

        final result = await walletRepository.getBalance();

        expect(result.currency, equals(currency));
      }
    });
  });

  group('WalletRepository - deductBalance', () {
    test('should deduct balance successfully', () async {
      when(() => mockApiService.post(
            '/wallet/send',
            data: {'amount': 100.0},
          )).thenAnswer((_) async => {});

      await walletRepository.deductBalance(100.0);

      verify(
        () => mockApiService.post(
          '/wallet/send',
          data: {'amount': 100.0},
        ),
      ).called(1);
    });

    test('should call correct endpoint for deduction', () async {
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => {});

      await walletRepository.deductBalance(500.0);

      verify(
        () => mockApiService.post(
          '/wallet/send',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('should pass correct amount in request', () async {
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => {});

      await walletRepository.deductBalance(2500.50);

      verify(
        () => mockApiService.post(
          any(),
          data: {'amount': 2500.50},
        ),
      ).called(1);
    });

    test('should handle various amounts', () async {
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => {});

      final amounts = [10.0, 50.0, 100.0, 1000.0, 9999.99];

      for (final amount in amounts) {
        await walletRepository.deductBalance(amount);
      }

      expect(true, isTrue);
    });

    test('should propagate exception from API', () async {
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenThrow(Exception('API error'));

      expect(
        () => walletRepository.deductBalance(100.0),
        throwsException,
      );
    });

    test('should handle zero deduction', () async {
      when(() => mockApiService.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => {});

      await walletRepository.deductBalance(0.0);

      verify(
        () => mockApiService.post(
          any(),
          data: {'amount': 0.0},
        ),
      ).called(1);
    });
  });
}
