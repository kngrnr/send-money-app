import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    // Fetch wallet balance on page load
    context.read<WalletCubit>().fetchWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: false,
        title: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final username = (state is AuthLoaded) ? state.user.username : '';
            return Text('@$username');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // RefreshIndicator covering the whole scrollable area
              RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletCubit>().fetchWallet();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Wallet Balance Card
                      SizedBox(
                        height: 150,
                        child: BlocBuilder<WalletCubit, WalletState>(
                          builder: (context, state) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Balance Label and Toggle
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Wallet Balance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isBalanceVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isBalanceVisible = !_isBalanceVisible;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Balance Amount
                                  switch (state) {
                                    WalletLoading() => const SizedBox(
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                    WalletLoaded() => Text(
                                      _isBalanceVisible
                                          ? '${state.wallet.currency} ${state.wallet.balance.toStringAsFixed(2)}'
                                          : '••••••',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    WalletError() => Text(
                                      'Error: ${state.message}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    _ => const Text(
                                      '•••••',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  },
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Add padding at bottom for button space
                      SizedBox(height: 130),
                    ],
                  ),
                ),
              ),
              // Buttons fixed at the bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Send Money Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to send money page
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Send Money'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // View Transactions Button
                    OutlinedButton.icon(
                      onPressed: () => context.push('/transaction-history'),
                      icon: const Icon(Icons.history),
                      label: const Text('View Transactions'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
