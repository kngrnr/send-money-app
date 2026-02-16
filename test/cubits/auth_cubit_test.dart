import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/core/network/dio_client.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockDioClient mockDioClient;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockDioClient = MockDioClient();

    authCubit = AuthCubit(
      mockLoginUseCase,
      mockLogoutUseCase,
      mockDioClient,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      username: 'johndoe',
    );

    final testResponse = LoginResponse(
      token: 'test_token',
      user: testUser,
    );

    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthLoading, AuthLoaded] on successful login',
      build: () {
        when(
          () => mockLoginUseCase.execute('johndoe', 'password123'),
        ).thenAnswer((_) async => testResponse);

        return authCubit;
      },
      act: (cubit) => cubit.login('johndoe', 'password123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthLoaded>()
            .having((state) => state.user.username, 'username', 'johndoe')
            .having((state) => state.token, 'token', 'test_token'),
      ],
      verify: (_) {
        verify(() => mockDioClient.setToken('test_token')).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthLoading, InvalidCredentials] on invalid credentials',
      build: () {
        when(
          () => mockLoginUseCase.execute(any(), any()),
        ).thenThrow(
          AppException(
            message: 'Invalid credentials',
            code: 'INVALID_CREDENTIALS',
          ),
        );

        return authCubit;
      },
      act: (cubit) => cubit.login('johndoe', 'wrong'),
      expect: () => [
        isA<AuthLoading>(),
        isA<InvalidCredentials>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthLoading, AuthError] on generic exception',
      build: () {
        when(
          () => mockLoginUseCase.execute(any(), any()),
        ).thenThrow(
          AppException(
            message: 'Network error',
            code: 'NETWORK_ERROR',
          ),
        );

        return authCubit;
      },
      act: (cubit) => cubit.login('johndoe', 'password'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthLoading, AuthError] on unexpected exception',
      build: () {
        when(
          () => mockLoginUseCase.execute(any(), any()),
        ).thenThrow(Exception('Unexpected error'));

        return authCubit;
      },
      act: (cubit) => cubit.login('johndoe', 'password'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthUnauthenticated] on successful logout',
      build: () {
        when(() => mockLogoutUseCase.execute())
            .thenAnswer((_) async => {});

        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockDioClient.clearToken()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [AuthError] on logout failure',
      build: () {
        when(() => mockLogoutUseCase.execute()).thenThrow(
          AppException(
            message: 'Logout failed',
            code: 'LOGOUT_ERROR',
          ),
        );

        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthError>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'should set token in DioClient on successful login',
      build: () {
        when(
          () => mockLoginUseCase.execute(any(), any()),
        ).thenAnswer((_) async => testResponse);

        return authCubit;
      },
      act: (cubit) => cubit.login('user', 'pass'),
      verify: (_) {
        verify(() => mockDioClient.setToken('test_token')).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'should clear token in DioClient on logout',
      build: () {
        when(() => mockLogoutUseCase.execute())
            .thenAnswer((_) async => {});

        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      verify: (_) {
        verify(() => mockDioClient.clearToken()).called(1);
      },
    );
  });
}
