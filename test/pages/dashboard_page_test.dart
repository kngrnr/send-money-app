import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/dashboard_page.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_actions.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_greeting.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/quick_action_card.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/wallet_card.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockWalletCubit extends MockCubit<WalletState> implements WalletCubit {}

final _testUser = User(id: 1, name: 'Test User', username: 'testuser');
final _testWallet = Wallet(balance: 1234.56, currency: 'PHP');

// WalletCard uses RichText for the balance — find.textContaining won't match it.
// Use byWidgetPredicate with RichText.toPlainText() instead.
Finder _richTextContaining(String value) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains(value),
    );

Widget _buildSubject({
  required AuthCubit auth,
  required WalletCubit wallet,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<WalletCubit>.value(value: wallet),
      ],
      child: const DashBoardPage(),
    ),
  );
}

void main() {
  late MockAuthCubit authCubit;
  late MockWalletCubit walletCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    walletCubit = MockWalletCubit();
    when(() => authCubit.state)
        .thenReturn(AuthLoaded(user: _testUser, token: 'tok'));
    when(() => walletCubit.state).thenReturn(WalletInitial());
    when(() => walletCubit.fetchWallet()).thenAnswer((_) async {});
  });

  group('DashBoardPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();
      expect(find.byType(DashBoardPage), findsOneWidget);
    });

    testWidgets('calls fetchWallet on init', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();
      verify(() => walletCubit.fetchWallet()).called(1);
    });

    testWidgets('renders all key sub-widgets', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      expect(find.byType(DashboardGreeting), findsOneWidget);
      expect(find.byType(WalletCard), findsOneWidget);
      expect(find.byType(QuickActionCard), findsNWidgets(2));
      expect(find.byType(DashboardActions), findsOneWidget);
    });

    testWidgets('shows greeting with username', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();
      expect(find.text('@testuser'), findsWidgets);
    });

    testWidgets('shows RefreshIndicator', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('calls fetchWallet again on pull-to-refresh', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        800,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(() => walletCubit.fetchWallet()).called(greaterThanOrEqualTo(1));
    });

    testWidgets('shows balance when WalletLoaded', (tester) async {
      when(() => walletCubit.state)
          .thenReturn(WalletLoaded(wallet: _testWallet));

      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      // WalletCard renders balance as RichText, not Text — use predicate
      expect(_richTextContaining('1234.56'), findsOneWidget);
      expect(_richTextContaining('PHP'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when WalletLoading',
        (tester) async {
      when(() => walletCubit.state).thenReturn(WalletLoading());

      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when WalletError', (tester) async {
      when(() => walletCubit.state)
          .thenReturn(WalletError(message: 'Network error'));

      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('hides balance when visibility toggled', (tester) async {
      when(() => walletCubit.state)
          .thenReturn(WalletLoaded(wallet: _testWallet));

      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      expect(_richTextContaining('1234.56'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.text('••••••'), findsOneWidget);
      expect(_richTextContaining('1234.56'), findsNothing);
    });

    testWidgets('has Send Money and History action buttons', (tester) async {
      await tester.pumpWidget(
          _buildSubject(auth: authCubit, wallet: walletCubit));
      await tester.pump();

      // 'Send Money' appears in QuickActionCard AND DashboardActions
      expect(find.text('Send Money'), findsWidgets);
      // 'History' appears in QuickActionCard AND DashboardActions
      expect(find.text('History'), findsWidgets);
    });
  });
}
