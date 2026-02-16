import 'package:dio/dio.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';

/// Error interceptor that maps Dio errors to app-specific exceptions
class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapDioErrorToAppException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppException _mapDioErrorToAppException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return AppException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'CONNECTION_TIMEOUT',
          originalException: dioError,
        );

      case DioExceptionType.sendTimeout:
        return AppException(
          message: 'Send timeout. Please try again.',
          code: 'SEND_TIMEOUT',
          originalException: dioError,
        );

      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'Receive timeout. Please try again.',
          code: 'RECEIVE_TIMEOUT',
          originalException: dioError,
        );

      case DioExceptionType.badResponse:
        return _mapStatusCodeToException(dioError);

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request cancelled.',
          code: 'REQUEST_CANCELLED',
          originalException: dioError,
        );

      case DioExceptionType.connectionError:
        return AppException(
          message: 'Connection error. Please check your internet connection.',
          code: 'CONNECTION_ERROR',
          originalException: dioError,
        );

      case DioExceptionType.unknown:
        return AppException(
          message: 'An unexpected error occurred. Please try again.',
          code: 'UNKNOWN_ERROR',
          originalException: dioError,
        );

      case DioExceptionType.badCertificate:
        return AppException(
          message: 'Certificate error. Please contact support.',
          code: 'BAD_CERTIFICATE',
          originalException: dioError,
        );
    }
  }

  AppException _mapStatusCodeToException(DioException dioError) {
    final statusCode = dioError.response?.statusCode;

    switch (statusCode) {
      case 400:
        return AppException(
          message: 'Bad request. Please check your input.',
          code: 'BAD_REQUEST',
          originalException: dioError,
        );

      case 401:
        return AppException(
          message: 'Invalid username or password.',
          code: 'UNAUTHORIZED',
          originalException: dioError,
        );

      case 403:
        return AppException(
          message: 'Access forbidden.',
          code: 'FORBIDDEN',
          originalException: dioError,
        );

      case 404:
        return AppException(
          message: 'Resource not found.',
          code: 'NOT_FOUND',
          originalException: dioError,
        );

      case 500:
        return AppException(
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          originalException: dioError,
        );

      case 503:
        return AppException(
          message: 'Service unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
          originalException: dioError,
        );

      default:
        final message = dioError.response?.data?['message'] ??
            dioError.response?.data?['error'] ??
            'An error occurred. Please try again.';
        return AppException(
          message: message is String ? message : 'An error occurred.',
          code: 'HTTP_ERROR_$statusCode',
          originalException: dioError,
        );
    }
  }
}
