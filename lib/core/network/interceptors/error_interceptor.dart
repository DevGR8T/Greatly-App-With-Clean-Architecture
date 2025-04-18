import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorMessage = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout',
      DioExceptionType.sendTimeout => 'Request send timeout',
      DioExceptionType.receiveTimeout => 'Response timeout',
      DioExceptionType.connectionError => 'No internet connection',
      DioExceptionType.badCertificate => 'Invalid SSL certificate',
      DioExceptionType.badResponse => 'Invalid server response',
      DioExceptionType.cancel => 'Request cancelled',
      DioExceptionType.unknown => 'Unknown network error',
    };

    err = err.copyWith(error: errorMessage);
    return handler.next(err);
  }
}