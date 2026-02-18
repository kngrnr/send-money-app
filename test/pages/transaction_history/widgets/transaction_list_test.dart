import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_state.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_card.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_list.dart';

class MockTransactionHistoryCubit extends MockCubit<TransactionHistoryState>
    implements TransactionHistoryCubit {}

List<TransactionModel> _makeTransactions(int count) => List.generate(
      count,
      (i) => TransactionModel(
        transactionId: i + 1,
        userId: 1,
        type: i.isEven ? 'credit' : 'debit',
        amount: (i + 1) * 100.0,
        description: 'Transaction $i',
        date: DateTime(2025, 1, i + 1),
        currency: 'PHP',
      ),
    );

Widget _buildSubject(TransactionHistoryCubit cubit, List<TransactionModel> txs) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<TransactionHistoryCubit>.value(
        value: cubit,
        child: TransactionList(transactions: txs),
      ),
    ),
  );
}

void main() {
  late MockTransactionHistoryCubit txCubit;

  setUp(() {
    txCubit = MockTransactionHistoryCubit();
    when(() => txCubit.state)
        .thenReturn(TransactionHistoryLoaded(transactions: []));
    when(() => txCubit.fetchTransactions()).thenAnswer((_) async {});
  });

  group('TransactionList', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(txCubit, _makeTransactions(3)));
      expect(find.byType(TransactionList), findsOneWidget);
    });

    testWidgets('shows a TransactionCard for each transaction', (tester) async {
      final txs = _makeTransactions(3);
      await tester.pumpWidget(_buildSubject(txCubit, txs));
      await tester.pump();
      expect(find.byType(TransactionCard), findsNWidgets(3));
    });

    testWidgets('shows the description of each transaction', (tester) async {
      final txs = _makeTransactions(2);
      await tester.pumpWidget(_buildSubject(txCubit, txs));
      await tester.pump();

      for (final tx in txs) {
        expect(find.text(tx.description), findsOneWidget);
      }
    });

    testWidgets('renders a RefreshIndicator', (tester) async {
      await tester.pumpWidget(_buildSubject(txCubit, _makeTransactions(1)));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('calls fetchTransactions on pull-to-refresh', (tester) async {
      await tester.pumpWidget(_buildSubject(txCubit, _makeTransactions(1)));

      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        800,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(() => txCubit.fetchTransactions()).called(greaterThanOrEqualTo(1));
    });

    testWidgets('renders a scrollable ListView', (tester) async {
      await tester.pumpWidget(_buildSubject(txCubit, _makeTransactions(5)));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      expect(
        TransactionList(transactions: _makeTransactions(1)),
        isA<StatelessWidget>(),
      );
    });
  });
}
