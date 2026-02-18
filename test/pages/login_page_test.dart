import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/pages/login/login_page.dart';
import 'package:send_money_app/src/presentation/pages/login/widgets/login_form.dart';
import 'package:send_money_app/src/presentation/pages/login/widgets/login_logo.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

Widget _buildSubject(AuthCubit cubit) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const LoginPage(),
    ),
  );
}

/// Wraps LoginPage inside a GoRouter so context.go('/dashboard') works.
Widget _buildWithRouter(AuthCubit cubit) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const Scaffold(body: Text('Dashboard')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  late MockAuthCubit authCubit;

  final testUser = User(id: 1, name: 'Test User', username: 'testuser');

  setUp(() {
    authCubit = MockAuthCubit();
    when(() => authCubit.state).thenReturn(AuthInitial());
  });

  group('LoginPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('renders LoginLogo and LoginForm sub-widgets', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      expect(find.byType(LoginLogo), findsOneWidget);
      expect(find.byType(LoginForm), findsOneWidget);
    });

    testWidgets('shows gradient background container', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows error snackbar on InvalidCredentials state',
        (tester) async {
      const errorMessage = 'Invalid username or password';
      whenListen(
        authCubit,
        Stream.fromIterable([InvalidCredentials(errorMessage)]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('shows snackbar on AuthError state', (tester) async {
      const errorMessage = 'Something went wrong';
      whenListen(
        authCubit,
        Stream.fromIterable([AuthError(errorMessage)]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('navigates to dashboard on AuthLoaded state', (tester) async {
      whenListen(
        authCubit,
        Stream.fromIterable([AuthLoaded(user: testUser, token: 'tok')]),
        initialState: AuthInitial(),
      );

      // Requires GoRouter because LoginPage calls context.go('/dashboard')
      await tester.pumpWidget(_buildWithRouter(authCubit));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });

  group('LoginPage — LoginForm interaction', () {
    testWidgets('has two text fields for username and password', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('has a Log In button', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Log In button is enabled in initial state', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Log In'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Log In button is disabled when AuthLoading', (tester) async {
      when(() => authCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      // LoginForm checks state in BlocBuilder to disable button
      final button = tester.widget<ElevatedButton>(
        find.byWidgetPredicate((w) => w is ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows CircularProgressIndicator when AuthLoading',
        (tester) async {
      when(() => authCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();
      final passwordField = tester.widgetList<TextField>(
        find.byType(TextField),
      ).last;
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('password visibility toggles on suffix icon tap', (tester) async {
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();

      expect(
        tester.widgetList<TextField>(find.byType(TextField)).last.obscureText,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(
        tester.widgetList<TextField>(find.byType(TextField)).last.obscureText,
        isFalse,
      );
    });

    testWidgets('calls login with entered credentials on button tap',
        (tester) async {
      when(() => authCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'myuser');
      await tester.enterText(find.byType(TextField).last, 'mypass');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      verify(() => authCubit.login('myuser', 'mypass')).called(1);
    });
  });
}
