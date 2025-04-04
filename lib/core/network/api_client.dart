import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Handles API requests for the app.
class ApiClient {
  final Dio _dio;  // Dio is used to make HTTP requests.

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: "https://api.yourmedusaapi.com",  // Base API URL.
          connectTimeout: Duration(milliseconds: 5000),  // Wait 5 seconds before timeout.
          receiveTimeout: Duration(milliseconds: 3000),  // Wait 3 seconds for a response.
        )) {
    _dio.interceptors.add(AuthInterceptor());  // Adds authentication handling.
    _dio.interceptors.add(ErrorInterceptor());  // Handles errors automatically.
  }

  /// Makes a GET request to the given endpoint.
  Future<Response> getData(String endpoint) async {
    return await _dio.get(endpoint);
  }
}
