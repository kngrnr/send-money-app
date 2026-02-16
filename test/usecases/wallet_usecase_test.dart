import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/data/repositories/wallet_repository.dart';
import 'package:send_money_app/src/data/usecases/wallet_usecase.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
  });

  group('GetWalletUseCase', () {
    late GetWalletUseCase getWalletUseCase;

    setUp(() {
      getWalletUseCase = GetWalletUseCase(mockRepository);
    });

    final testWallet = Wallet(
      balance: 5000.0,
      currency: 'PHP',
    );

    test('should execute and return wallet successfully', () async {
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => testWallet);

      final result = await getWalletUseCase.execute();

      expect(result.balance, equals(5000.0));
      expect(result.currency, equals('PHP'));
      verify(() => mockRepository.getBalance()).called(1);
    });

    test('should return wallet with correct balance', () async {
      final expectedWallet = Wallet(balance: 7500.5, currency: 'USD');

      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => expectedWallet);

      final result = await getWalletUseCase.execute();

      expect(result.balance, equals(7500.5));
      expect(result.currency, equals('USD'));
    });

    test('should propagate exception from repository', () async {
      when(() => mockRepository.getBalance())
          .thenThrow(Exception('Network error'));

      expect(
        () => getWalletUseCase.execute(),
        throwsException,
      );
    });

    test('should handle zero balance', () async {
      final zeroWallet = Wallet(balance: 0.0, currency: 'PHP');

      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => zeroWallet);

      final result = await getWalletUseCase.execute();

      expect(result.balance, equals(0.0));
    });

    test('should handle different currencies', () async {
      final currencies = ['PHP', 'USD', 'EUR', 'GBP'];

      for (final currency in currencies) {
        final wallet = Wallet(balance: 1000.0, currency: currency);

        when(() => mockRepository.getBalance())
            .thenAnswer((_) async => wallet);

        final result = await getWalletUseCase.execute();

        expect(result.currency, equals(currency));
      }
    });
  });

  group('DeductBalanceUseCase', () {
    late DeductBalanceUseCase deductBalanceUseCase;

    setUp(() {
      deductBalanceUseCase = DeductBalanceUseCase(mockRepository);
    });

    test('should execute deduct balance successfully', () async {
      when(() => mockRepository.deductBalance(100.0))
          .thenAnswer((_) async => {});

      await deductBalanceUseCase.execute(100.0);

      verify(() => mockRepository.deductBalance(100.0)).called(1);
    });

    test('should pass correct amount to repository', () async {
      when(() => mockRepository.deductBalance(any()))
          .thenAnswer((_) async => {});

      final amounts = [50.0, 100.0, 500.0, 1000.0];

      for (final amount in amounts) {
        await deductBalanceUseCase.execute(amount);

        verify(() => mockRepository.deductBalance(amount)).called(1);
      }
    });

    test('should propagate exception from repository', () async {
      when(() => mockRepository.deductBalance(any()))
          .thenThrow(Exception('API error'));

      expect(
        () => deductBalanceUseCase.execute(100.0),
        throwsException,
      );
    });

    test('should handle zero deduction', () async {
      when(() => mockRepository.deductBalance(0.0))
          .thenAnswer((_) async => {});

      await deductBalanceUseCase.execute(0.0);

      verify(() => mockRepository.deductBalance(0.0)).called(1);
    });

    test('should handle large amounts', () async {
      when(() => mockRepository.deductBalance(any()))
          .thenAnswer((_) async => {});

      await deductBalanceUseCase.execute(999999.99);

      verify(() => mockRepository.deductBalance(999999.99)).called(1);
    });
  });
}
