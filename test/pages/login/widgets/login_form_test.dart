import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/pages/login/widgets/login_form.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

Widget _buildSubject(AuthCubit cubit) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(116, 236, 166, 1),
        ),
      ),
      home: Scaffold(
        body: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const LoginForm(),
        ),
      ),
    );

void main() {
  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    when(() => authCubit.state).thenReturn(AuthInitial());
  });

  group('LoginForm', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      expect(find.byType(LoginForm), findsOneWidget);
    });

    testWidgets('has two TextField widgets (username and password)',
        (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('has a Log In button', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      final passwordField =
          tester.widgetList<TextField>(find.byType(TextField)).last;
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('password becomes visible after tapping eye icon', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final passwordField =
          tester.widgetList<TextField>(find.byType(TextField)).last;
      expect(passwordField.obscureText, isFalse);
    });

    testWidgets('password hides again on second eye icon tap', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final passwordField =
          tester.widgetList<TextField>(find.byType(TextField)).last;
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('Log In button is enabled in initial state', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      final btn =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('Log In button is disabled during AuthLoading', (tester) async {
      when(() => authCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      final btn =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows CircularProgressIndicator during AuthLoading',
        (tester) async {
      when(() => authCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls authCubit.login() with trimmed credentials on tap',
        (tester) async {
      when(() => authCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '  alice  ');
      await tester.enterText(find.byType(TextField).last, 'secret');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      verify(() => authCubit.login('alice', 'secret')).called(1);
    });

    testWidgets('calls authCubit.login() when keyboard submit on password field',
        (tester) async {
      when(() => authCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'bob');
      await tester.enterText(find.byType(TextField).last, 'pass123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(() => authCubit.login('bob', 'pass123')).called(1);
    });
  });
}
