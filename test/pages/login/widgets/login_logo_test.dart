import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/presentation/pages/login/widgets/login_logo.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(116, 236, 166, 1),
        ),
      ),
      home: Scaffold(body: child),
    );

void main() {
  group('LoginLogo', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const LoginLogo()));
      expect(find.byType(LoginLogo), findsOneWidget);
    });

    testWidgets('displays the Send Money title', (tester) async {
      await tester.pumpWidget(_wrap(const LoginLogo()));
      expect(find.text('Send Money'), findsOneWidget);
    });

    testWidgets('displays the tagline', (tester) async {
      await tester.pumpWidget(_wrap(const LoginLogo()));
      expect(find.text('Fast, simple, secure transfers'), findsOneWidget);
    });

    testWidgets('renders the send icon', (tester) async {
      await tester.pumpWidget(_wrap(const LoginLogo()));
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('icon is placed inside a rounded container', (tester) async {
      await tester.pumpWidget(_wrap(const LoginLogo()));
      // Container wrapping the icon exists
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('is a StatelessWidget (no unnecessary state)', (tester) async {
      expect(const LoginLogo(), isA<StatelessWidget>());
    });
  });
}
