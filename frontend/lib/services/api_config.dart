import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:1337';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:1337';
    }
    return 'http://127.0.0.1:1337';
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
