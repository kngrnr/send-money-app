import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/quick_action_card.dart';

GoRouter _testRouter(Widget child, String targetRoute) => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => child),
        GoRoute(
          path: targetRoute,
          builder: (_, __) => const Scaffold(body: Text('Target')),
        ),
      ],
    );

Widget _buildSubject({
  required IconData icon,
  required String label,
  required String sublabel,
  required String route,
}) {
  final card = QuickActionCard(
    icon: icon,
    label: label,
    sublabel: sublabel,
    route: route,
  );
  return MaterialApp.router(
    routerConfig: _testRouter(Scaffold(body: card), route),
  );
}

void main() {
  group('QuickActionCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(
        icon: Icons.send_rounded,
        label: 'Send Money',
        sublabel: 'Transfer funds',
        route: '/send-money',
      ));
      expect(find.byType(QuickActionCard), findsOneWidget);
    });

    testWidgets('displays the correct label', (tester) async {
      await tester.pumpWidget(_buildSubject(
        icon: Icons.send_rounded,
        label: 'Send Money',
        sublabel: 'Transfer funds',
        route: '/send-money',
      ));
      expect(find.text('Send Money'), findsOneWidget);
    });

    testWidgets('displays the correct sublabel', (tester) async {
      await tester.pumpWidget(_buildSubject(
        icon: Icons.send_rounded,
        label: 'Send Money',
        sublabel: 'Transfer funds',
        route: '/send-money',
      ));
      expect(find.text('Transfer funds'), findsOneWidget);
    });

    testWidgets('displays the correct icon', (tester) async {
      await tester.pumpWidget(_buildSubject(
        icon: Icons.receipt_long_rounded,
        label: 'History',
        sublabel: 'View transactions',
        route: '/transaction-history',
      ));
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('navigates to the given route on tap', (tester) async {
      await tester.pumpWidget(_buildSubject(
        icon: Icons.send_rounded,
        label: 'Send Money',
        sublabel: 'Transfer funds',
        route: '/send-money',
      ));

      await tester.tap(find.byType(QuickActionCard));
      await tester.pumpAndSettle();

      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      expect(
        const QuickActionCard(
          icon: Icons.send_rounded,
          label: 'Test',
          sublabel: 'sub',
          route: '/test',
        ),
        isA<StatelessWidget>(),
      );
    });
  });
}
