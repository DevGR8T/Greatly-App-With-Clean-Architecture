import 'dart:io'; // For platform detection
import 'env_config.dart';

class DevConfig implements EnvConfig {
  @override
  String get baseUrl {
    // Replace with your host machine's IP address
    const String hostIp = '192.168.43.128';

    if (Platform.isAndroid || Platform.isIOS) {
      // Use the host machine's IP for both Android and iOS devices
      print('Running with baseUrl: http://$hostIp:1337');
      return 'http://$hostIp:1337';
    } else {
      // Fallback for other platforms (e.g., web)
      return 'http://localhost:1337';
    }
  }

  @override
  String get apiUrl => '$baseUrl/api';
}