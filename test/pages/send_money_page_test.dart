import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_state.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';
import 'package:send_money_app/src/presentation/pages/send_money/send_money_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockSendMoneyCubit extends MockCubit<SendMoneyState>
    implements SendMoneyCubit {}
class MockWalletCubit extends MockCubit<WalletState> implements WalletCubit {}

final _testUser = User(id: 1, name: 'Test User', username: 'testuser');

// ElevatedButton.icon() returns _ElevatedButtonWithIcon (a private subclass).
// find.byType() uses exact runtimeType matching, so we must use byWidgetPredicate
// with `is` for subtype matching.
final _elevatedButtonFinder =
    find.byWidgetPredicate((w) => w is ElevatedButton);

Widget _buildSubject({
  required AuthCubit auth,
  required SendMoneyCubit sendMoney,
  required WalletCubit wallet,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<SendMoneyCubit>.value(value: sendMoney),
        BlocProvider<WalletCubit>.value(value: wallet),
      ],
      child: const SendMoneyPage(),
    ),
  );
}

void main() {
  late MockAuthCubit authCubit;
  late MockSendMoneyCubit sendMoneyCubit;
  late MockWalletCubit walletCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    sendMoneyCubit = MockSendMoneyCubit();
    walletCubit = MockWalletCubit();
    when(() => authCubit.state)
        .thenReturn(AuthLoaded(user: _testUser, token: 'tok'));
    when(() => sendMoneyCubit.state).thenReturn(SendMoneyInitial());
    when(() => walletCubit.state).thenReturn(WalletInitial());
    when(() => walletCubit.fetchWallet()).thenAnswer((_) async {});
  });

  group('SendMoneyPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SendMoneyPage), findsOneWidget);
    });

    testWidgets('has recipient and amount TextFormFields', (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('has Send Money submit button', (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();
      // ElevatedButton.icon() creates _ElevatedButtonWithIcon — use `is` predicate
      expect(_elevatedButtonFinder, findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty fields',
        (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();

      await tester.tap(_elevatedButtonFinder);
      await tester.pump();

      expect(find.text('Please enter a recipient'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('shows validation error for non-numeric amount', (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'recipient');
      await tester.enterText(find.byType(TextFormField).last, 'abc');
      await tester.tap(_elevatedButtonFinder);
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('shows validation error for zero or negative amount',
        (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'recipient');
      await tester.enterText(find.byType(TextFormField).last, '0');
      await tester.tap(_elevatedButtonFinder);
      await tester.pump();

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
    });

    testWidgets('calls sendMoney with correct values on valid submit',
        (tester) async {
      when(() => sendMoneyCubit.sendMoney(
            recipientUsername: any(named: 'recipientUsername'),
            amount: any(named: 'amount'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'john');
      await tester.enterText(find.byType(TextFormField).last, '500');
      await tester.tap(_elevatedButtonFinder);
      await tester.pump();

      verify(() => sendMoneyCubit.sendMoney(
            recipientUsername: 'john',
            amount: 500.0,
          )).called(1);
    });

    testWidgets('button is disabled and shows spinner when SendMoneyLoading',
        (tester) async {
      when(() => sendMoneyCubit.state).thenReturn(SendMoneyLoading());

      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(_elevatedButtonFinder);
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sending...'), findsOneWidget);
    });

    testWidgets('shows success bottom sheet on SendMoneySuccess', (tester) async {
      whenListen(
        sendMoneyCubit,
        Stream.fromIterable([
          SendMoneySuccess(message: 'Transfer complete', transactionId: 'TXN1'),
        ]),
        initialState: SendMoneyInitial(),
      );

      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Transfer Successful!'), findsOneWidget);
      expect(find.text('Transfer complete'), findsOneWidget);
    });

    testWidgets('shows error bottom sheet on SendMoneyError', (tester) async {
      whenListen(
        sendMoneyCubit,
        Stream.fromIterable([
          SendMoneyError(message: 'Insufficient funds'),
        ]),
        initialState: SendMoneyInitial(),
      );

      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Transfer Failed'), findsOneWidget);
      expect(find.text('Insufficient funds'), findsOneWidget);
    });

    testWidgets('shows info hint banner', (tester) async {
      await tester.pumpWidget(_buildSubject(
        auth: authCubit,
        sendMoney: sendMoneyCubit,
        wallet: walletCubit,
      ));
      await tester.pumpAndSettle();
      expect(
        find.text('Double-check the recipient before sending.'),
        findsOneWidget,
      );
    });
  });
}
