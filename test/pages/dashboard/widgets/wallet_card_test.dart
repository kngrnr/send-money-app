import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/wallet_model.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/wallet/wallet_state.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/wallet_card.dart';

class MockWalletCubit extends MockCubit<WalletState> implements WalletCubit {}

Widget _buildSubject(WalletCubit cubit) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(116, 236, 166, 1),
        ),
      ),
      home: Scaffold(
        body: BlocProvider<WalletCubit>.value(
          value: cubit,
          child: const WalletCard(),
        ),
      ),
    );

// WalletCard renders the balance as RichText (not Text), so find.textContaining
// won't match it. Use a byWidgetPredicate that inspects the plain text.
Finder _richTextContaining(String value) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains(value),
    );

void main() {
  late MockWalletCubit walletCubit;

  setUp(() {
    walletCubit = MockWalletCubit();
    when(() => walletCubit.state).thenReturn(WalletInitial());
  });

  group('WalletCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(walletCubit));
      expect(find.byType(WalletCard), findsOneWidget);
    });

    testWidgets('shows "Wallet Balance" label', (tester) async {
      await tester.pumpWidget(_buildSubject(walletCubit));
      expect(find.text('Wallet Balance'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when WalletLoading',
        (tester) async {
      when(() => walletCubit.state).thenReturn(WalletLoading());
      await tester.pumpWidget(_buildSubject(walletCubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows balance amount and currency when WalletLoaded',
        (tester) async {
      when(() => walletCubit.state).thenReturn(
        WalletLoaded(wallet: Wallet(balance: 9876.54, currency: 'PHP')),
      );
      await tester.pumpWidget(_buildSubject(walletCubit));
      await tester.pump();

      // WalletCard uses RichText for the balance — use predicate, not textContaining
      expect(_richTextContaining('9876.54'), findsOneWidget);
      expect(_richTextContaining('PHP'), findsOneWidget);
    });

    testWidgets('shows error message when WalletError', (tester) async {
      when(() => walletCubit.state)
          .thenReturn(WalletError(message: 'Timeout'));
      await tester.pumpWidget(_buildSubject(walletCubit));
      await tester.pump();

      expect(find.text('Timeout'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('hides balance after tapping visibility icon', (tester) async {
      when(() => walletCubit.state).thenReturn(
        WalletLoaded(wallet: Wallet(balance: 500.0, currency: 'PHP')),
      );
      await tester.pumpWidget(_buildSubject(walletCubit));
      await tester.pump();

      // Balance visible as RichText
      expect(_richTextContaining('500.00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now replaced by dot string rendered as regular Text
      expect(find.text('••••••'), findsOneWidget);
      expect(_richTextContaining('500.00'), findsNothing);
    });

    testWidgets('shows balance again after tapping visibility icon twice',
        (tester) async {
      when(() => walletCubit.state).thenReturn(
        WalletLoaded(wallet: Wallet(balance: 500.0, currency: 'PHP')),
      );
      await tester.pumpWidget(_buildSubject(walletCubit));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(_richTextContaining('500.00'), findsOneWidget);
    });

    testWidgets('shows pull-to-refresh hint text', (tester) async {
      await tester.pumpWidget(_buildSubject(walletCubit));
      expect(find.text('Pull down to refresh'), findsOneWidget);
    });

    testWidgets('is a StatefulWidget (owns visibility state)', (tester) async {
      expect(const WalletCard(), isA<StatefulWidget>());
    });
  });
}
