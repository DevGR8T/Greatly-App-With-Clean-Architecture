import 'env_config.dart';

class ProdConfig implements EnvConfig {
  @override
  String get baseUrl {
    return 'https://greatly-strapi-server.onrender.com';
  }

  @override
  String get apiUrl => '$baseUrl/api';
}