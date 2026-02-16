import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/network/api_service.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';

@LazySingleton(as: ApiService)
class DioApiService implements ApiService {
  final Dio dio;

  DioApiService(this.dio);

  @override
  Future<dynamic> get(String path) async {
    try {
      final response = await dio.get(path);
      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<dynamic> post(String path, {data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  /// Handle DioException and throw AppException with appropriate message
  void _handleDioException(DioException e) {
    String message = 'An error occurred';
    String? code;

    if (e.response != null) {
      code = '${e.response?.statusCode}';
      
      // Handle specific HTTP status codes
      switch (e.response?.statusCode) {
        case 400:
          message = e.response?.data?['message'] ?? 'Invalid credentials or bad request';
          break;
        case 401:
          message = 'Invalid username or password';
          code = 'INVALID_CREDENTIALS';
          break;
        case 403:
          message = 'Access forbidden';
          break;
        case 404:
          message = 'Endpoint not found';
          break;
        case 500:
          message = 'Server error. Please try again later';
          break;
        default:
          message = e.response?.data?['message'] ?? 'An error occurred';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timeout. Please try again';
    } else if (e.type == DioExceptionType.unknown) {
      message = e.error?.toString() ?? 'Network error occurred';
    }

    throw AppException(
      message: message,
      code: code,
      originalException: e,
    );
  }
}
