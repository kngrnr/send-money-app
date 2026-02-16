import 'package:flutter_test/flutter_test.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';

void main() {
  group('AppException', () {
    test('should create an AppException with message only', () {
      final exception = AppException(message: 'Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.originalException, isNull);
    });

    test('should create an AppException with message and code', () {
      final exception = AppException(
        message: 'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      expect(exception.message, equals('Invalid credentials'));
      expect(exception.code, equals('INVALID_CREDENTIALS'));
    });

    test('should create an AppException with original exception', () {
      final originalError = Exception('Original error');
      final exception = AppException(
        message: 'Wrapped error',
        originalException: originalError,
      );

      expect(exception.message, equals('Wrapped error'));
      expect(exception.originalException, equals(originalError));
    });

    test('should create an AppException with all parameters', () {
      final originalError = Exception('Database error');
      final exception = AppException(
        message: 'Failed to fetch data',
        code: 'DB_ERROR',
        originalException: originalError,
      );

      expect(exception.message, equals('Failed to fetch data'));
      expect(exception.code, equals('DB_ERROR'));
      expect(exception.originalException, equals(originalError));
    });

    test('should return message when toString is called', () {
      final exception = AppException(message: 'Test exception');

      expect(exception.toString(), equals('Test exception'));
    });

    test('should implement Exception interface', () {
      final exception = AppException(message: 'Test');

      expect(exception, isA<Exception>());
    });

    test('should handle empty message', () {
      final exception = AppException(message: '');

      expect(exception.message, isEmpty);
      expect(exception.toString(), isEmpty);
    });

    test('should handle different error codes', () {
      final exc1 = AppException(
        message: 'Unauthorized',
        code: 'UNAUTHORIZED',
      );
      final exc2 = AppException(
        message: 'Not Found',
        code: 'NOT_FOUND',
      );

      expect(exc1.code, equals('UNAUTHORIZED'));
      expect(exc2.code, equals('NOT_FOUND'));
    });

    test('should preserve original exception of any type', () {
      const stringError = 'String error';
      final exception = AppException(
        message: 'Wrapped error',
        originalException: stringError,
      );

      expect(exception.originalException, equals(stringError));
    });

    test('should be throwable', () {
      final exception = AppException(message: 'Test error', code: 'TEST');

      expect(
        () => throw exception,
        throwsA(isA<AppException>()),
      );
    });
  });
}
