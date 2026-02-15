import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;
  final String baseUrl;
  
  // Token managed internally
  String? _token;

  DioClient({
    required this.baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Duration(milliseconds: connectTimeout),
            receiveTimeout: Duration(milliseconds: receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _initializeInterceptors();
  }

  Dio get dio => _dio;

  /// Get current token
  String? get token => _token;

  /// Set token after successful login
  void setToken(String? token) {
    _token = token;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null && _token?.isNotEmpty == true;

  /// Clear token (logout)
  void clearToken() {
    _token = null;
  }

  void _initializeInterceptors() {
    _dio.interceptors.addAll([
      _authInterceptor(),
    ]);
  }

  // Auth Interceptor - Adds Bearer token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null && _token?.isNotEmpty == true) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    );
  }

 
}
