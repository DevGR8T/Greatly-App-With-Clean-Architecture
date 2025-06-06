import 'package:dio/dio.dart';
import '../config/env/env_config.dart';
import 'interceptors/auth_interceptor.dart';

/// A Dio client for making HTTP requests.
class DioClient {
  final Dio _dio;
  final EnvConfig _envConfig;

  /// Initializes Dio with base options.
  DioClient(this._dio, this._envConfig) {
    _dio
      ..options.baseUrl = _envConfig.apiUrl // Set the base URL.
      ..options.connectTimeout = const Duration(seconds: 30) // Connection timeout. 
      ..options.receiveTimeout = const Duration(seconds: 30) // Receive timeout.
      ..options.responseType = ResponseType.json // Default response type.
      ..options.headers = {
        'Content-Type': 'application/json', // Default content type
        'Accept': 'application/json',
      }
      // Added the Auth Interceptor here
      ..interceptors.add(AuthInterceptor())
      // Add logging interceptor for debugging
      ..interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ));
  }

  /// Performs a GET request.
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow; // Rethrow the exception for higher-level handling.
    }
  }

  /// Performs a POST request.
  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Ensure proper headers for JSON requests
      final defaultOptions = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Merge with provided options
      final mergedOptions = options != null 
        ? Options(
            headers: {
              ...defaultOptions.headers ?? {},
              ...options.headers ?? {},
            },
            method: options.method ?? defaultOptions.method,
            sendTimeout: options.sendTimeout ?? defaultOptions.sendTimeout,
            receiveTimeout: options.receiveTimeout ?? defaultOptions.receiveTimeout,
            extra: options.extra ?? defaultOptions.extra,
            followRedirects: options.followRedirects ?? defaultOptions.followRedirects,
            maxRedirects: options.maxRedirects ?? defaultOptions.maxRedirects,
            persistentConnection: options.persistentConnection ?? defaultOptions.persistentConnection,
            requestEncoder: options.requestEncoder ?? defaultOptions.requestEncoder,
            responseDecoder: options.responseDecoder ?? defaultOptions.responseDecoder,
            listFormat: options.listFormat ?? defaultOptions.listFormat,
          )
        : defaultOptions;
      
      return await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow; // Rethrow the exception for higher-level handling.
    }
  }

  /// Performs a PUT request.
  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Ensure proper headers for JSON requests
      final defaultOptions = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      final mergedOptions = options != null 
        ? Options(
            headers: {
              ...defaultOptions.headers ?? {},
              ...options.headers ?? {},
            },
          )
        : defaultOptions;
      
      return await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow; // Rethrow the exception for higher-level handling.
    }
  }

  /// Performs a DELETE request.
  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow; // Rethrow the exception for higher-level handling.
    }
  }
}