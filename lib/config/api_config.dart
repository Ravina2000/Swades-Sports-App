import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Production / hosted backend:
  /// flutter run --dart-define=API_BASE_URL=https://your-app.up.railway.app
  static const baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Local dev port override:
  /// flutter run --dart-define=API_PORT=8081
  static const port = String.fromEnvironment('API_PORT', defaultValue: '8080');

  static String get baseUrl {
    if (baseUrlOverride.isNotEmpty) return baseUrlOverride;

    if (kIsWeb) return 'http://localhost:$port';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port';
    return 'http://127.0.0.1:$port';
  }
}
