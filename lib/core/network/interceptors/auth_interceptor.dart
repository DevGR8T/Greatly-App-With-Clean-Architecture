// Update your AuthInterceptor.dart with this code

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Your Strapi API token
  final String _strapiApiToken = "f442d01a76acf235d880c0251630dc26371de712907b69b30d0a7e864f9649063c4c5598cbb7ae90703d3b191430b4f36356b439f88e0af62ea9a4ae885aa42c076bc1e70bbfb971d49c828522da97ff18ab3db9b677d26e6cba6e40acd2abe6525a2eee78daf51f87fb51e50712035b49f8e4bfc84711439e6b9b215b15efac";
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Always add Strapi API token for authentication
    options.headers['Authorization'] = 'Bearer $_strapiApiToken';
    
    // Get the current Firebase user
    final user = _auth.currentUser;
    
    if (user != null) {
      try {
        // For review submissions, ensure correct data format
        if ((options.method == 'POST' || options.method == 'PUT') && 
            options.path.contains('/reviews')) {
          
          // Make sure we don't modify the review data structure
          // Just ensure it has the required format for Strapi
          if (options.data is Map && options.data['data'] is Map) {
            // Data is already structured properly, just ensure product ID is int
            final Map<String, dynamic> data = Map<String, dynamic>.from(options.data);
            final Map<String, dynamic> innerData = Map<String, dynamic>.from(data['data']);
            
            // Ensure product ID is an integer if it's not already
            if (innerData['product'] is String) {
              innerData['product'] = int.tryParse(innerData['product']) ?? 0;
            }
            
            data['data'] = innerData;
            options.data = data;
          }
          
          // Print for debugging
          print('Auth Interceptor - Request data: ${options.data}');
          print('Auth Interceptor - Headers: ${options.headers}');
        }
      } catch (e) {
        print('Error in auth interceptor: $e');
      }
    }
    
    // Continue with the request
    return handler.next(options);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Print detailed error response for debugging
    print('API Error: ${err.response?.statusCode}');
    print('API Error Response: ${err.response?.data}');
    
    return handler.next(err);
  }
}