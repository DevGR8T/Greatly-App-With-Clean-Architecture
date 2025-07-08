import 'env_config.dart';

class ProdConfig implements EnvConfig {
  @override
  String get baseUrl {
    return 'https://greatlystrapiserver-production.up.railway.app';
  }

  @override
  String get apiUrl => '$baseUrl/api';
}