class ApiConfig {
  static const String liveServerUrl = 'https://instacat.cyfrex.co.th';
  static const String localServerUrl = 'http://172.20.10.10:1337';
  static const String androidEmulatorUrl = 'http://10.0.2.2:1337';

  static String get serverUrl {
    const fromEnv = String.fromEnvironment('API_SERVER_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return liveServerUrl;
  }

  static String get baseUrl {
    final clean = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    if (clean.endsWith('/api')) {
      return clean;
    }
    return '$clean/api';
  }

  /// Google Maps & Google Places API Key (can be passed via --dart-define=GOOGLE_MAPS_API_KEY=... or configured here).
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// OneSignal App ID (can be passed via --dart-define=ONESIGNAL_APP_ID=... or configured here).
  static const String oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '1a188487-4d05-4f93-ac03-666f15165e3a',
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
