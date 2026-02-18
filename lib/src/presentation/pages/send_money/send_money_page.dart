import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_state.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/widgets/app_bar_widget.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showResultBottomSheet({
    required bool isSuccess,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (isSuccess ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                size: 40,
                color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? 'Transfer Successful!' : 'Transfer Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      context.read<SendMoneyCubit>().sendMoney(
            recipientUsername: _recipientController.text.trim(),
            amount: amount,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Send Money', showBackButton: true),
      body: BlocListener<SendMoneyCubit, SendMoneyState>(
        listener: (context, state) {
          switch (state) {
            case SendMoneySuccess():
              _showResultBottomSheet(isSuccess: true, message: state.message);
              _recipientController.clear();
              _amountController.clear();
              context.read<WalletCubit>().fetchWallet();
            case SendMoneyError():
              _showResultBottomSheet(isSuccess: false, message: state.message);
              context.read<WalletCubit>().fetchWallet();
            case SendMoneyLoading() || SendMoneyInitial():
              break;
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: BlocBuilder<SendMoneyCubit, SendMoneyState>(
                builder: (context, state) {
                  final isLoading = state is SendMoneyLoading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Transfer Details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recipientController,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Recipient',
                          hintText: 'Username or phone number',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: primary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipient';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        enabled: !isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!isLoading) _handleSubmit();
                        },
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixIcon: Icon(
                            Icons.payments_outlined,
                            color: primary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null) {
                            return 'Please enter a valid number';
                          }
                          if (parsed <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Double-check the recipient before sending.',
                              style: TextStyle(
                                fontSize: 12,
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleSubmit,
                        icon: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                        label: Text(
                          isLoading ? 'Sending...' : 'Send Money',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
