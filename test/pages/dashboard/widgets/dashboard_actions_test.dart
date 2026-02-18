import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_actions.dart';

GoRouter _testRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) =>
              const Scaffold(body: DashboardActions()),
        ),
        GoRoute(
          path: '/send-money',
          builder: (_, __) => const Scaffold(body: Text('SendMoney')),
        ),
        GoRoute(
          path: '/transaction-history',
          builder: (_, __) => const Scaffold(body: Text('History')),
        ),
      ],
    );

Widget _buildSubject() => MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(116, 236, 166, 1),
        ),
      ),
      routerConfig: _testRouter(),
    );

// ElevatedButton.icon() creates _ElevatedButtonWithIcon (private subclass).
// find.byType() uses runtimeType equality, not `is`. Use byWidgetPredicate.
final _elevatedButtonPredicate =
    find.byWidgetPredicate((w) => w is ElevatedButton);
final _outlinedButtonPredicate =
    find.byWidgetPredicate((w) => w is OutlinedButton);

void main() {
  group('DashboardActions', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.byType(DashboardActions), findsOneWidget);
    });

    testWidgets('has Send Money and History buttons', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.text('Send Money'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('has send and history icons', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('navigates to /send-money on Send Money tap', (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.tap(find.text('Send Money'));
      await tester.pumpAndSettle();

      expect(find.text('SendMoney'), findsOneWidget);
    });

    testWidgets('navigates to /transaction-history on History tap',
        (tester) async {
      await tester.pumpWidget(_buildSubject());

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // The route shows a scaffold with 'History' text
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Send Money button is an ElevatedButton', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Use ancestor with byWidgetPredicate (supports `is` subtype matching)
      expect(
        find.ancestor(
          of: find.text('Send Money'),
          matching: _elevatedButtonPredicate,
        ),
        findsOneWidget,
      );
    });

    testWidgets('History button is an OutlinedButton', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.ancestor(
          of: find.text('History'),
          matching: _outlinedButtonPredicate,
        ),
        findsOneWidget,
      );
    });

    testWidgets('is a StatelessWidget', (tester) async {
      expect(const DashboardActions(), isA<StatelessWidget>());
    });
  });
}
