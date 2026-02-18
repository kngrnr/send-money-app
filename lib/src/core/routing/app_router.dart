import 'package:go_router/go_router.dart';
import 'package:send_money_app/src/presentation/pages/login/login_page.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/dashboard_page.dart';
import 'package:send_money_app/src/presentation/pages/send_money/send_money_page.dart';
import 'package:send_money_app/src/presentation/pages/transaction_history/transaction_history_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String sendMoney = '/send-money';
  static const String transactionHistory = '/transaction-history';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashBoardPage(),
      ),
      GoRoute(
        path: sendMoney,
        builder: (context, state) => const SendMoneyPage(),
      ),
      GoRoute(
        path: transactionHistory,
        builder: (context, state) => const TransactionHistoryPage(),
      ),
    ],
  );
}
