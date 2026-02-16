import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:send_money_app/src/core/network/api_service.dart';
import 'package:send_money_app/src/data/repositories/auth_repository.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authRepository = AuthRepositoryImpl(mockApiService);
  });

  group('AuthRepository', () {
    test('should login successfully with valid credentials', () async {
      final responseData = {
        'token': 'test_token_12345',
        'user': {
          'id': 1,
          'name': 'John Doe',
          'username': 'johndoe',
        },
      };

      when(
        () => mockApiService.post(
          '/api/login',
          data: {
            'username': 'johndoe',
            'password': 'password123',
          },
        ),
      ).thenAnswer((_) async => responseData);

      final result = await authRepository.login('johndoe', 'password123');

      expect(result.token, equals('test_token_12345'));
      expect(result.user.username, equals('johndoe'));
      verify(
        () => mockApiService.post(
          '/api/login',
          data: {
            'username': 'johndoe',
            'password': 'password123',
          },
        ),
      ).called(1);
    });

    test('should call correct API endpoint for login', () async {
      when(
        () => mockApiService.post(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {
            'token': 'token',
            'user': {
              'id': 1,
              'name': 'test',
              'username': 'test',
            }
          });

      await authRepository.login('user', 'pass');

      verify(
        () => mockApiService.post(
          '/api/login',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('should pass credentials in request data', () async {
      when(
        () => mockApiService.post(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {
            'token': 'token',
            'user': {
              'id': 1,
              'name': 'test',
              'username': 'test',
            }
          });

      await authRepository.login('testuser', 'testpass');

      verify(
        () => mockApiService.post(
          any(),
          data: {
            'username': 'testuser',
            'password': 'testpass',
          },
        ),
      ).called(1);
    });

    test('should propagate exception from API service', () async {
      when(
        () => mockApiService.post(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => authRepository.login('user', 'pass'),
        throwsException,
      );
    });

    test('should create LoginResponse with correct user data', () async {
      final responseData = {
        'token': 'token_xyz',
        'user': {
          'id': 99,
          'name': 'Jane Doe',
          'username': 'janedoe',
        },
      };

      when(
        () => mockApiService.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => responseData);

      final result = await authRepository.login('janedoe', 'pass123');

      expect(result.user.id, equals(99));
      expect(result.user.name, equals('Jane Doe'));
      expect(result.token, equals('token_xyz'));
    });
  });

  group('AuthRepository - logout', () {
    test('should logout successfully', () async {
      when(() => mockApiService.post('/api/logout'))
          .thenAnswer((_) async => {});

      await authRepository.logout();

      verify(() => mockApiService.post('/api/logout')).called(1);
    });

    test('should call logout endpoint', () async {
      when(() => mockApiService.post(any()))
          .thenAnswer((_) async => {});

      await authRepository.logout();

      verify(() => mockApiService.post('/api/logout')).called(1);
    });

    test('should propagate exception from API during logout', () async {
      when(() => mockApiService.post(any()))
          .thenThrow(Exception('API error'));

      expect(
        () => authRepository.logout(),
        throwsException,
      );
    });
  });
}
