import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

TransactionModel _makeTransaction({
  required String type,
  required double amount,
  required String description,
}) =>
    TransactionModel(
      transactionId: 1,
      userId: 1,
      type: type,
      amount: amount,
      description: description,
      date: DateTime(2025, 6, 15, 14, 30),
      currency: 'PHP',
    );

void main() {
  group('TransactionCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(TransactionCard(transaction: _makeTransaction(
          type: 'credit',
          amount: 100.0,
          description: 'Salary',
        ))),
      );
      expect(find.byType(TransactionCard), findsOneWidget);
    });

    testWidgets('shows the transaction description', (tester) async {
      await tester.pumpWidget(
        _wrap(TransactionCard(transaction: _makeTransaction(
          type: 'credit',
          amount: 500.0,
          description: 'Payment received',
        ))),
      );
      expect(find.text('Payment received'), findsOneWidget);
    });

    testWidgets('shows the formatted date', (tester) async {
      await tester.pumpWidget(
        _wrap(TransactionCard(transaction: _makeTransaction(
          type: 'credit',
          amount: 100.0,
          description: 'Test',
        ))),
      );
      // Date is formatted as "Jun 15, 2025 · 02:30 PM"
      expect(find.textContaining('Jun 15, 2025'), findsOneWidget);
    });

    group('credit transaction', () {
      late TransactionModel creditTx;

      setUp(() => creditTx = _makeTransaction(
            type: 'credit',
            amount: 750.0,
            description: 'Received',
          ));

      testWidgets('shows + prefix on amount', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: creditTx)));
        await tester.pump();
        expect(find.textContaining('+PHP 750.00'), findsOneWidget);
      });

      testWidgets('shows Credit badge', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: creditTx)));
        await tester.pump();
        expect(find.text('Credit'), findsOneWidget);
      });

      testWidgets('shows downward arrow icon', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: creditTx)));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      });
    });

    group('debit transaction', () {
      late TransactionModel debitTx;

      setUp(() => debitTx = _makeTransaction(
            type: 'debit',
            amount: 200.0,
            description: 'Transfer sent',
          ));

      testWidgets('shows - prefix on amount', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: debitTx)));
        await tester.pump();
        expect(find.textContaining('-PHP 200.00'), findsOneWidget);
      });

      testWidgets('shows Debit badge', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: debitTx)));
        await tester.pump();
        expect(find.text('Debit'), findsOneWidget);
      });

      testWidgets('shows upward arrow icon', (tester) async {
        await tester.pumpWidget(_wrap(TransactionCard(transaction: debitTx)));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      });
    });

    testWidgets('is a StatelessWidget', (tester) async {
      expect(
        TransactionCard(
          transaction: _makeTransaction(
            type: 'credit',
            amount: 1.0,
            description: 'x',
          ),
        ),
        isA<StatelessWidget>(),
      );
    });
  });
}
