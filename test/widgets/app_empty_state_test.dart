import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/presentation/widgets/app_empty_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppEmptyState', () {
    testWidgets('renders icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            subtitle: 'Try adding something.',
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try adding something.'), findsOneWidget);
    });

    testWidgets('renders without subtitle when not provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      // No subtitle text in the tree
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('does NOT render RefreshIndicator when onRefresh is null',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('renders RefreshIndicator when onRefresh is provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('renders inside a scrollable when onRefresh is provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('calls onRefresh callback on pull-to-refresh', (tester) async {
      var refreshed = false;

      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            onRefresh: () async => refreshed = true,
          ),
        ),
      );

      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        800,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshed, isTrue);
    });

    testWidgets('renders icon inside a circular container', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No data',
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
