// error_interceptor.dart
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors globally
    super.onError(err, handler);
  }
}