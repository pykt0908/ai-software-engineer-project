import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'api_config.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  bool _initialized = false;

  /// Initializes OneSignal SDK and sets up notification listeners.
  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return;

    final appId = ApiConfig.oneSignalAppId;
    if (appId.isEmpty) {
      debugPrint('[PushNotificationService] ONESIGNAL_APP_ID is not set. Push notifications are skipped.');
      return;
    }

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.info);
      }

      OneSignal.initialize(appId);

      // Request push notification permission
      OneSignal.Notifications.requestPermission(true);

      // Foreground notification display handler (shows notification banner even when app is open)
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('[PushNotificationService] Foreground notification: ${event.notification.title}');
        event.notification.display();
      });

      // Notification click handler
      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        debugPrint('[PushNotificationService] Notification clicked: $data');
      });

      _initialized = true;
      debugPrint('[PushNotificationService] OneSignal initialized successfully.');
    } catch (e) {
      debugPrint('[PushNotificationService] Error initializing OneSignal: $e');
    }
  }

  /// Associates the current user with OneSignal External ID for targeted push notifications.
  Future<void> login(String userId) async {
    if (kIsWeb) return;
    try {
      if (!_initialized) {
        await initialize();
      }
      if (_initialized) {
        await OneSignal.login(userId);
        debugPrint('[PushNotificationService] OneSignal logged in with external_id: $userId');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] OneSignal login error: $e');
    }
  }

  /// Clears user association on logout.
  Future<void> logout() async {
    if (kIsWeb || !_initialized) return;
    try {
      await OneSignal.logout();
      debugPrint('[PushNotificationService] OneSignal logged out');
    } catch (e) {
      debugPrint('[PushNotificationService] OneSignal logout error: $e');
    }
  }
}
