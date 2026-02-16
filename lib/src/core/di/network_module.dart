import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/network/dio_client.dart';
import 'package:send_money_app/src/core/network/error_interceptor.dart';
import 'package:send_money_app/src/core/network/logging_interceptor.dart';

/// Injectable module for network dependencies
/// Provides Dio and DioClient instances
@module
abstract class NetworkModule {
  /// Provides DioClient as singleton
  /// The base URL can be configured via environment or config
  @singleton
  DioClient get dioClient => DioClient(
        baseUrl: const String.fromEnvironment(
          'BASE_URL',
          defaultValue: 'https://mock-send-money-api.vercel.app',
        ),
      );

  /// Provides Dio instance from DioClient with logging and error interceptors
  @singleton
  Dio dio(DioClient client) {
    final dioInstance = client.dio;
    dioInstance.interceptors.add(DioLoggingInterceptor());
    dioInstance.interceptors.add(DioErrorInterceptor());
    return dioInstance;
  }
}
