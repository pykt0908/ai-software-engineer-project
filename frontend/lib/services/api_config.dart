import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String liveServerUrl = 'https://instacat.cyfrex.co.th';

  static String get serverUrl {
    const fromEnv = String.fromEnvironment('API_SERVER_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return liveServerUrl;
  }

  static String get baseUrl => '$serverUrl/api';

  /// Google Maps & Google Places API Key (can be passed via --dart-define=GOOGLE_MAPS_API_KEY=... or configured here).
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '$serverUrl$url';
    }
    return '$serverUrl/$url';
  }
}
