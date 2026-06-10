import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Production / hosted backend:
  /// flutter run --dart-define=API_BASE_URL=https://your-app.up.railway.app
  static const baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Local dev port override:
  /// flutter run --dart-define=API_PORT=8081
  static const port = String.fromEnvironment('API_PORT', defaultValue: '8081');

  /// Local dev host override (physical Android device — use your PC's LAN IP):
  /// flutter run --dart-define=API_HOST=192.168.0.204 --dart-define=API_PORT=8081
  static const hostOverride = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    return 'http://127.0.0.1:8081';
    if (baseUrlOverride.isNotEmpty) return baseUrlOverride;

    if (kIsWeb) return 'http://localhost:$port';
    if (Platform.isAndroid) {
      final host = hostOverride.isNotEmpty ? hostOverride : 'http://192.168.0.204:8081';
      return 'http://$host:$port';
    }
    return 'http://127.0.0.1:$port';
  }
}
