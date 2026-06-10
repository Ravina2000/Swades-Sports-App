class ApiConfig {
  /// Railway backend — must use https. http:// redirects break POST /bookings.
  static const _defaultBaseUrl =
      'https://swades-sports-backend-production.up.railway.app';

  /// Override for local dev:
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
  static const baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    final raw =
        baseUrlOverride.isNotEmpty ? baseUrlOverride : _defaultBaseUrl;
    // Railway 301s http→https; Dart's http client does not follow that for POST.
    if (raw.startsWith('http://') && raw.contains('.railway.app')) {
      return raw.replaceFirst('http://', 'https://');
    }
    return raw;
  }
}
