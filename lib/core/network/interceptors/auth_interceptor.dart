import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // Define your API key - consider storing this securely
  final String _apiKey = 'f442d01a76acf235d880c0251630dc26371de712907b69b30d0a7e864f9649063c4c5598cbb7ae90703d3b191430b4f36356b439f88e0af62ea9a4ae885aa42c076bc1e70bbfb971d49c828522da97ff18ab3db9b677d26e6cba6e40acd2abe6525a2eee78daf51f87fb51e50712035b49f8e4bfc84711439e6b9b215b15efac';
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add API key to all requests
    options.headers['X-API-Key'] = _apiKey;
    
    // Continue with the request
    return handler.next(options);
  }
}