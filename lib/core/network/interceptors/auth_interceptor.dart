import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authentication logic here
    const token = 'YOUR_STRAPI_TOKEN'; // Get from secure storage
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }
}