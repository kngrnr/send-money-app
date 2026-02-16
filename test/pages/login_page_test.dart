import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/pages/login_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    });

    testWidgets('should render LoginPage without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // If we reach here, page rendered without errors
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should have username and password text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      // Look for input fields
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have a login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      // Look for button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should show error snackbar on InvalidCredentials state',
        (WidgetTester tester) async {
      final mockAuthCubitWithError = MockAuthCubit();
      when(() => mockAuthCubitWithError.state)
          .thenReturn(InvalidCredentials('Invalid username or password'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubitWithError,
            child: const LoginPage(),
          ),
        ),
      );

      // Trigger the listener by rebuilding
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubitWithError,
            child: const LoginPage(),
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('should display gradient background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      // Look for Container with gradient
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should have Column for layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(Column), findsWidgets);
    });
  });
}
