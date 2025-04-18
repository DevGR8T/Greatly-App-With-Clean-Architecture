import 'package:dio/dio.dart';
import '../config/env/env_config.dart';

/// A Dio client for making HTTP requests.
class DioClient {
  final Dio _dio;
  final EnvConfig _envConfig;

  /// Initializes Dio with base options.
  DioClient(this._dio, this._envConfig) {
    _dio
      ..options.baseUrl = _envConfig.apiUrl // Set the base URL
      ..options.connectTimeout = const Duration(seconds: 30) // Connection timeout 
      ..options.receiveTimeout = const Duration(seconds: 30) // Receive timeout 
      ..options.responseType = ResponseType.json; // Default response type
  }

  /// Performs a GET request.
// In your dio_client.dart file, enhance the get method:
Future<Response> get(
  String uri, {
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
}) async {
  try {
    print('GET Request: ${_dio.options.baseUrl}$uri');
    print('Query Parameters: $queryParameters');
    
    final Response response = await _dio.get(
      uri,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    return response;
  } catch (e) {
    print('Error in GET request: $e');
    rethrow;
  }
}

  /// Performs a POST request.
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
      rethrow;
    }
  }
}