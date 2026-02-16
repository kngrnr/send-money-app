import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/data/usecases/wallet_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';

class MockGetWalletUseCase extends Mock implements GetWalletUseCase {}

class MockDeductBalanceUseCase extends Mock implements DeductBalanceUseCase {}

void main() {
  late WalletCubit walletCubit;
  late MockGetWalletUseCase mockGetWalletUseCase;
  late MockDeductBalanceUseCase mockDeductBalanceUseCase;

  setUp(() {
    mockGetWalletUseCase = MockGetWalletUseCase();
    mockDeductBalanceUseCase = MockDeductBalanceUseCase();

    walletCubit = WalletCubit(
      getWalletUseCase: mockGetWalletUseCase,
      deductBalanceUseCase: mockDeductBalanceUseCase,
    );
  });

  tearDown(() {
    walletCubit.close();
  });

  group('WalletCubit - fetchWallet', () {
    final testWallet = Wallet(
      balance: 5000.0,
      currency: 'PHP',
    );

    test('initial state is WalletInitial', () {
      expect(walletCubit.state, isA<WalletInitial>());
    });

    blocTest<WalletCubit, WalletState>(
      'should emit [WalletLoading, WalletLoaded] on successful fetch',
      build: () {
        when(() => mockGetWalletUseCase.execute())
            .thenAnswer((_) async => testWallet);

        return walletCubit;
      },
      act: (cubit) => cubit.fetchWallet(),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>()
            .having((state) => state.wallet.balance, 'balance', 5000.0)
            .having((state) => state.wallet.currency, 'currency', 'PHP'),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'should emit [WalletLoading, WalletError] on failure',
      build: () {
        when(() => mockGetWalletUseCase.execute())
            .thenThrow(Exception('Network error'));

        return walletCubit;
      },
      act: (cubit) => cubit.fetchWallet(),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletError>(),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'should handle zero balance',
      build: () {
        final zeroWallet = Wallet(balance: 0.0, currency: 'PHP');

        when(() => mockGetWalletUseCase.execute())
            .thenAnswer((_) async => zeroWallet);

        return walletCubit;
      },
      act: (cubit) => cubit.fetchWallet(),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>()
            .having((state) => state.wallet.balance, 'balance', 0.0),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'should handle different currencies',
      build: () {
        final usdWallet = Wallet(balance: 1000.0, currency: 'USD');

        when(() => mockGetWalletUseCase.execute())
            .thenAnswer((_) async => usdWallet);

        return walletCubit;
      },
      act: (cubit) => cubit.fetchWallet(),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>()
            .having((state) => state.wallet.currency, 'currency', 'USD'),
      ],
    );
  });

  group('WalletCubit - deductBalance', () {
    final testWallet = Wallet(
      balance: 4500.0,
      currency: 'PHP',
    );

    blocTest<WalletCubit, WalletState>(
      'should deduct balance and fetch updated wallet',
      build: () {
        when(() => mockDeductBalanceUseCase.execute(500.0))
            .thenAnswer((_) async => {});
        when(() => mockGetWalletUseCase.execute())
            .thenAnswer((_) async => testWallet);

        return walletCubit;
      },
      act: (cubit) => cubit.deductBalance(500.0),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>()
            .having((state) => state.wallet.balance, 'balance', 4500.0),
      ],
      verify: (_) {
        verify(() => mockDeductBalanceUseCase.execute(500.0)).called(1);
        verify(() => mockGetWalletUseCase.execute()).called(1);
      },
    );

    blocTest<WalletCubit, WalletState>(
      'should emit error if deduction fails',
      build: () {
        when(() => mockDeductBalanceUseCase.execute(any()))
            .thenThrow(Exception('Insufficient balance'));

        return walletCubit;
      },
      act: (cubit) => cubit.deductBalance(10000.0),
      expect: () => [
        isA<WalletError>(),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'should emit error if wallet fetch fails after deduction',
      build: () {
        when(() => mockDeductBalanceUseCase.execute(any()))
            .thenAnswer((_) async => {});
        when(() => mockGetWalletUseCase.execute())
            .thenThrow(Exception('Fetch error'));

        return walletCubit;
      },
      act: (cubit) => cubit.deductBalance(100.0),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletError>(),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'should pass correct amount to deduct',
      build: () {
        when(() => mockDeductBalanceUseCase.execute(any()))
            .thenAnswer((_) async => {});
        when(() => mockGetWalletUseCase.execute())
            .thenAnswer((_) async => testWallet);

        return walletCubit;
      },
      act: (cubit) => cubit.deductBalance(250.50),
      verify: (_) {
        verify(() => mockDeductBalanceUseCase.execute(250.50)).called(1);
      },
    );
  });
}
