import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Custom logging interceptor for Dio
class DioLoggingInterceptor extends Interceptor {
  /// Format data as pretty JSON
  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data);
        return JsonEncoder.withIndent('  ').convert(json);
      } else if (data is Map || data is List) {
        return JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Build curl command
    final curl = StringBuffer('curl -X ${options.method}');
    curl.write(' "${options.uri}"');
    
    // Add headers
    for (final header in options.headers.entries) {
      curl.write(' -H "${header.key}: ${header.value}"');
    }
    
    // Add data if present
    if (options.data != null) {
      if (options.data is String) {
        curl.write(' -d \'${options.data}\'');
      } else {
        curl.write(' -d \'${options.data}\'');
      }
    }
    
    developer.log(curl.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final prettyData = _prettyJson(response.data);
    final message = '✓ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}\n$prettyData';
    developer.log(message);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final prettyData = err.response?.data != null ? _prettyJson(err.response?.data) : 'null';
    final message = '✗ ${err.response?.statusCode ?? 'ERROR'} ${err.requestOptions.method} ${err.requestOptions.uri}\nError: ${err.message}\n$prettyData';
    developer.log(message);
    handler.next(err);
  }
}
