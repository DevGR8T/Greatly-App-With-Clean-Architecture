import 'package:dio/dio.dart';
import '../config/env/env_config.dart';

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
      ..options.responseType = ResponseType.json; // Default response type.
      
  }

  /// Performs a GET request.
  ///
  /// [uri] is the endpoint to fetch data from.
  /// [queryParameters] are optional query parameters for the request.
  /// Returns the response from the server.
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
  ///
  /// [uri] is the endpoint to send data to.
  /// [data] is the payload for the request.
  /// [queryParameters] are optional query parameters for the request.
  /// Returns the response from the server.
  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow; // Rethrow the exception for higher-level handling.
    }
  }
}