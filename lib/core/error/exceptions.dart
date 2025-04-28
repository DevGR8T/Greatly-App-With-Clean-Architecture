/// Exception for server-related errors.
class ServerException implements Exception {
  final String message; // Error message.
  ServerException(this.message);
}

/// Exception for cache-related errors.
class CacheException implements Exception {
  final String message; // Error message.
  CacheException(this.message);
}

/// Exception for connection-related errors.
class ConnectionException implements Exception {
  final String message; // Error message.
  ConnectionException(this.message);
}

class ProductNotFoundException implements Exception {
  final String message;
  
  ProductNotFoundException(this.message);
}