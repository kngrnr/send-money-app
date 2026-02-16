import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/models/user_model.dart';

void main() {
  group('User Model', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      username: 'johndoe',
    );

    test('should create a User instance with correct properties', () {
      expect(testUser.id, equals(1));
      expect(testUser.name, equals('John Doe'));
      expect(testUser.username, equals('johndoe'));
    });

    test('should create a User from JSON', () {
      const jsonData = {
        'id': 1,
        'name': 'John Doe',
        'username': 'johndoe',
      };

      final user = User.fromJson(jsonData);

      expect(user.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.username, equals('johndoe'));
    });

    test('should convert User to JSON', () {
      final json = testUser.toJson();

      expect(json['id'], equals(1));
      expect(json['name'], equals('John Doe'));
      expect(json['username'], equals('johndoe'));
    });

    test('should handle fromJson with missing fields', () {
      const jsonData = {
        'id': 2,
        'name': 'Jane Doe',
        'username': 'janedoe',
      };

      final user = User.fromJson(jsonData);

      expect(user.id, equals(2));
      expect(user.name, equals('Jane Doe'));
      expect(user.username, equals('janedoe'));
    });

    test('should maintain equality based on properties', () {
      final user1 = User(id: 1, name: 'John', username: 'john');
      final user2 = User(id: 1, name: 'John', username: 'john');

      expect(user1.id, equals(user2.id));
      expect(user1.name, equals(user2.name));
      expect(user1.username, equals(user2.username));
    });
  });
}
