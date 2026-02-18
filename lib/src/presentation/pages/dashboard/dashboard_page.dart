import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_actions.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_greeting.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/quick_action_card.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/wallet_card.dart';
import 'package:send_money_app/src/presentation/widgets/app_bar_widget.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().fetchWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<WalletCubit>().fetchWallet(),
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DashboardGreeting(),
                      SizedBox(height: 16),
                      WalletCard(),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.send_rounded,
                              label: 'Send Money',
                              sublabel: 'Transfer funds',
                              route: '/send-money',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.receipt_long_rounded,
                              label: 'History',
                              sublabel: 'View transactions',
                              route: '/transaction-history',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const DashboardActions(),
          ],
        ),
      ),
    );
  }
}
