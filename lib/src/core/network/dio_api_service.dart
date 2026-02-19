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
    String? code;
    String message;

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final serverMessage = e.response?.data?['message'] ?? e.response?.data?['error'];

      code = '$statusCode';
      if (statusCode == 401) code = 'INVALID_CREDENTIALS';

      final fallback = switch (statusCode) {
        400 => 'Bad request. Please check your input.',
        401 => 'Invalid username or password.',
        403 => 'Access forbidden.',
        404 => 'Endpoint not found.',
        500 => 'Server error. Please try again later.',
        _ => 'An error occurred.',
      };

      message = serverMessage is String ? serverMessage : fallback;
    } else {
      message = switch (e.type) {
        DioExceptionType.connectionTimeout => 'Connection timeout. Please check your internet.',
        DioExceptionType.receiveTimeout => 'Request timeout. Please try again.',
        _ => 'Network error occurred.',
      };
    }

    throw AppException(
      message: message,
      code: code,
      originalException: e,
    );
  }
}
