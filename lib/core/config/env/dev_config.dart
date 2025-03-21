import 'env_config.dart';

class DevConfig implements EnvConfig {
  @override
  String get baseUrl => "https://dev.api.yourapp.com";
}