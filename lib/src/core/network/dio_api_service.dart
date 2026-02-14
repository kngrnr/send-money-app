import 'package:dio/dio.dart';
import 'package:send_money_app/src/core/network/api_service.dart';


class DioApiService implements ApiService {
  final Dio dio;

  DioApiService(this.dio);

  @override
  Future<dynamic> get(String path) async {
    final response = await dio.get(path);
    return response.data;
  }

  @override
  Future<dynamic> post(String path, {data}) async {
    final response = await dio.post(path, data: data);
    return response.data;
  }
}
