// auth_interceptor.dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authentication headers
    options.headers['Authorization'] = 'Bearer your_token';
    return handler.next(options);
  }
}