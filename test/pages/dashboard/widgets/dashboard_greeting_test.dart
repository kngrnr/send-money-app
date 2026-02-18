import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';
import 'package:send_money_app/src/presentation/pages/dashboard/widgets/dashboard_greeting.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

Widget _buildSubject(AuthCubit cubit) => MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const DashboardGreeting(),
        ),
      ),
    );

void main() {
  late MockAuthCubit authCubit;

  setUp(() => authCubit = MockAuthCubit());

  group('DashboardGreeting', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => authCubit.state).thenReturn(AuthInitial());
      await tester.pumpWidget(_buildSubject(authCubit));
      expect(find.byType(DashboardGreeting), findsOneWidget);
    });

    testWidgets('shows "..." placeholder when auth state is not AuthLoaded',
        (tester) async {
      when(() => authCubit.state).thenReturn(AuthInitial());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('shows @username when AuthLoaded', (tester) async {
      when(() => authCubit.state).thenReturn(
        AuthLoaded(
          user: User(id: 1, name: 'Alice', username: 'alice'),
          token: 'tok',
        ),
      );
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();
      expect(find.text('@alice'), findsOneWidget);
    });

    testWidgets('shows one of the three time-based greetings', (tester) async {
      when(() => authCubit.state).thenReturn(AuthInitial());
      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      final greetingTexts = ['Good morning,', 'Good afternoon,', 'Good evening,'];
      final found = greetingTexts.any(
        (g) => find.textContaining(g).evaluate().isNotEmpty,
      );
      expect(found, isTrue);
    });

    testWidgets('updates username when auth state changes', (tester) async {
      when(() => authCubit.state).thenReturn(AuthInitial());

      whenListen(
        authCubit,
        Stream.fromIterable([
          AuthLoaded(
            user: User(id: 2, name: 'Bob', username: 'bob'),
            token: 'tok',
          ),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(_buildSubject(authCubit));
      await tester.pump();

      expect(find.text('@bob'), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      expect(const DashboardGreeting(), isA<StatelessWidget>());
    });
  });
}
