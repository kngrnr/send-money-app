import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/presentation/widgets/app_error_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppErrorState', () {
    testWidgets('renders error icon, message, and retry button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Connection failed',
            onRetry: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onRetry when Try Again is tapped', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Network error',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('does NOT render RefreshIndicator when onRefresh is null',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('renders RefreshIndicator when onRefresh is provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Error',
            onRetry: () {},
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
          AppErrorState(
            message: 'Error',
            onRetry: () {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('calls onRefresh on pull-to-refresh', (tester) async {
      var refreshed = false;

      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Error',
            onRetry: () {},
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

    testWidgets('renders "Something went wrong" as the heading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppErrorState(
            message: 'Timeout',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
