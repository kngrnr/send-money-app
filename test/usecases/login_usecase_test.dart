import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/core/models/user_model.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';
import 'package:send_money_app/src/data/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  group('LoginUseCase', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      username: 'johndoe',
    );

    final testResponse = LoginResponse(
      token: 'test_token',
      user: testUser,
    );

    test('should execute login successfully with valid credentials', () async {
      when(
        () => mockAuthRepository.login('johndoe', 'password123'),
      ).thenAnswer((_) async => testResponse);

      final result = await loginUseCase.execute('johndoe', 'password123');

      expect(result.token, equals('test_token'));
      expect(result.user.username, equals('johndoe'));
      verify(
        () => mockAuthRepository.login('johndoe', 'password123'),
      ).called(1);
    });

    test('should throw AppException when username is empty', () async {
      expect(
        () => loginUseCase.execute('', 'password123'),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          equals('EMPTY_USERNAME'),
        )),
      );
    });

    test('should throw AppException when password is empty', () async {
      expect(
        () => loginUseCase.execute('johndoe', ''),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          equals('EMPTY_PASSWORD'),
        )),
      );
    });

    test('should throw AppException when repository throws AppException', () async {
      final appException = AppException(
        message: 'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      when(
        () => mockAuthRepository.login('johndoe', 'wrong'),
      ).thenThrow(appException);

      expect(
        () => loginUseCase.execute('johndoe', 'wrong'),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          equals('INVALID_CREDENTIALS'),
        )),
      );
    });

    test('should throw wrapped AppException for other exceptions', () async {
      final exception = Exception('Network error');

      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenThrow(exception);

      expect(
        () => loginUseCase.execute('johndoe', 'password'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('unexpected error'),
          ),
        ),
      );
    });

    test('should validate both username and password before calling repository', () async {
      expect(
        () => loginUseCase.execute('', ''),
        throwsA(isA<AppException>()),
      );

      verifyNever(() => mockAuthRepository.login(any(), any()));
    });
  });

  group('LogoutUseCase', () {
    late LogoutUseCase logoutUseCase;

    setUp(() {
      logoutUseCase = LogoutUseCase(mockAuthRepository);
    });

    test('should execute logout successfully', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      await logoutUseCase.execute();

      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should propagate exception from repository', () async {
      when(() => mockAuthRepository.logout()).thenThrow(
        Exception('Logout failed'),
      );

      expect(
        () => logoutUseCase.execute(),
        throwsException,
      );
    });
  });
}
