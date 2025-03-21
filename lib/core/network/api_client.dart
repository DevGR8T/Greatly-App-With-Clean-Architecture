import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: "https://api.yourmedusaapi.com",
          connectTimeout: Duration(milliseconds: 5000),
          receiveTimeout: Duration(milliseconds: 3000),
        )) {
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  // Example of a GET request
  Future<Response> getData(String endpoint) async {
    return await _dio.get(endpoint);
  }
}