import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:1337';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:1337';
    }
    return 'http://127.0.0.1:1337';
  }

  static String get baseUrl => '$serverUrl/api';

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
