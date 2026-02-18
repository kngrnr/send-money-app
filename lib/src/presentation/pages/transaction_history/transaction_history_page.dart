import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/transaction/transaction_history_state.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/widgets/transaction_list.dart';
import 'package:send_money_app/src/presentation/widgets/app_bar_widget.dart';
import 'package:send_money_app/src/presentation/widgets/app_empty_state.dart';
import 'package:send_money_app/src/presentation/widgets/app_error_state.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionHistoryCubit>().fetchTransactions();
  }

  Future<void> _refresh() async =>
      context.read<TransactionHistoryCubit>().fetchTransactions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Transaction History',
        showBackButton: true,
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
          builder: (context, state) {
            return switch (state) {
              TransactionHistoryLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              TransactionHistoryLoaded() => state.transactions.isEmpty
                  ? AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle: 'Your transaction history will appear here.',
                      onRefresh: _refresh,
                    )
                  : TransactionList(transactions: state.transactions),
              TransactionHistoryError() => AppErrorState(
                  message: state.message,
                  onRetry: _refresh,
                  onRefresh: _refresh,
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
