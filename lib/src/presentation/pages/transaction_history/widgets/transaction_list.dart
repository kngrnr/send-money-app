import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/models/transaction_model.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_card.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TransactionHistoryCubit>().fetchTransactions(),
      child: ListView.builder(
        itemCount: transactions.length,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemBuilder: (context, index) =>
            TransactionCard(transaction: transactions[index]),
      ),
    );
  }
}
