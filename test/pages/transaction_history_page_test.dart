import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_state.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/transaction_history_page.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_list.dart';
import 'package:send_money_app/src/presentation/widgets/app_empty_state.dart';
import 'package:send_money_app/src/presentation/widgets/app_error_state.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockTransactionHistoryCubit extends MockCubit<TransactionHistoryState>
    implements TransactionHistoryCubit {}

final _testUser = User(id: 1, name: 'Test', username: 'testuser');

final _testTransactions = [
  TransactionModel(
    transactionId: 1,
    userId: 1,
    type: 'credit',
    amount: 500.0,
    description: 'Payment received',
    date: DateTime(2025, 1, 15, 10, 30),
    currency: 'PHP',
  ),
  TransactionModel(
    transactionId: 2,
    userId: 1,
    type: 'debit',
    amount: 200.0,
    description: 'Transfer sent',
    date: DateTime(2025, 1, 14, 9, 0),
    currency: 'PHP',
  ),
];

Widget _buildSubject({
  required AuthCubit auth,
  required TransactionHistoryCubit txCubit,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<TransactionHistoryCubit>.value(value: txCubit),
      ],
      child: const TransactionHistoryPage(),
    ),
  );
}

void main() {
  late MockAuthCubit authCubit;
  late MockTransactionHistoryCubit txCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    txCubit = MockTransactionHistoryCubit();
    when(() => authCubit.state)
        .thenReturn(AuthLoaded(user: _testUser, token: 'tok'));
    when(() => txCubit.state).thenReturn(TransactionHistoryInitial());
    when(() => txCubit.fetchTransactions()).thenAnswer((_) async {});
  });

  group('TransactionHistoryPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.byType(TransactionHistoryPage), findsOneWidget);
    });

    testWidgets('calls fetchTransactions on init', (tester) async {
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      verify(() => txCubit.fetchTransactions()).called(1);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      when(() => txCubit.state).thenReturn(TransactionHistoryLoading());
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppEmptyState when loaded with empty list',
        (tester) async {
      when(() => txCubit.state)
          .thenReturn(TransactionHistoryLoaded(transactions: []));
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('shows AppErrorState on TransactionHistoryError', (tester) async {
      when(() => txCubit.state)
          .thenReturn(TransactionHistoryError(message: 'Network failed'));
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('Network failed'), findsOneWidget);
    });

    testWidgets('shows TransactionList when loaded with transactions',
        (tester) async {
      when(() => txCubit.state)
          .thenReturn(TransactionHistoryLoaded(transactions: _testTransactions));
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.byType(TransactionList), findsOneWidget);
    });

    testWidgets('shows correct number of transaction cards', (tester) async {
      when(() => txCubit.state)
          .thenReturn(TransactionHistoryLoaded(transactions: _testTransactions));
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();
      expect(find.text('Payment received'), findsOneWidget);
      expect(find.text('Transfer sent'), findsOneWidget);
    });

    testWidgets('retries on Try Again tap from error state', (tester) async {
      when(() => txCubit.state)
          .thenReturn(TransactionHistoryError(message: 'Failed'));
      await tester.pumpWidget(_buildSubject(auth: authCubit, txCubit: txCubit));
      await tester.pump();

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // fetchTransactions called once on init + once on retry
      verify(() => txCubit.fetchTransactions()).called(greaterThanOrEqualTo(2));
    });
  });
}
