import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/login_response.dart';
import 'package:send_money_app/src/core/models/user_model.dart';

void main() {
  group('LoginResponse Model', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      username: 'johndoe',
    );

    final testLoginResponse = LoginResponse(
      token: 'test_token_12345',
      user: testUser,
    );

    test('should create a LoginResponse instance with correct properties', () {
      expect(testLoginResponse.token, equals('test_token_12345'));
      expect(testLoginResponse.user.id, equals(1));
      expect(testLoginResponse.user.name, equals('John Doe'));
    });

    test('should create a LoginResponse from JSON', () {
      final jsonData = {
        'token': 'test_token_12345',
        'user': {
          'id': 1,
          'name': 'John Doe',
          'username': 'johndoe',
        },
      };

      final response = LoginResponse.fromJson(jsonData);

      expect(response.token, equals('test_token_12345'));
      expect(response.user.id, equals(1));
      expect(response.user.name, equals('John Doe'));
      expect(response.user.username, equals('johndoe'));
    });

    test('should convert LoginResponse to JSON', () {
      final json = testLoginResponse.toJson();

      expect(json['token'], equals('test_token_12345'));
      expect(json['user']['id'], equals(1));
      expect(json['user']['name'], equals('John Doe'));
      expect(json['user']['username'], equals('johndoe'));
    });

    test('should handle fromJson and toJson round trip', () {
      final jsonData = {
        'token': 'another_token',
        'user': {
          'id': 2,
          'name': 'Jane Doe',
          'username': 'janedoe',
        },
      };

      final response = LoginResponse.fromJson(jsonData);
      final json = response.toJson();

      expect(json['token'], equals('another_token'));
      expect(json['user']['id'], equals(2));
    });

    test('should maintain token and user data integrity', () {
      final response = LoginResponse(
        token: 'secure_token',
        user: User(id: 5, name: 'Test User', username: 'testuser'),
      );

      expect(response.token, isNotEmpty);
      expect(response.user, isNotNull);
    });
  });
}
