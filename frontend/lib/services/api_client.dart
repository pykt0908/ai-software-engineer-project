import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String keyAccessToken = 'instacat_jwt';
  static const String keyRefreshToken = 'instacat_refresh_token';

  String? _accessToken;
  String? _refreshToken;
  bool _isRefreshing = false;
  void Function()? onAuthFailed;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // If sending FormData, remove forced application/json header to let Dio set boundary
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
            options.contentType = null;
          }

          // Do not send Authorization header for public auth routes or token refresh
          if (options.path.contains('/auth/local') ||
              options.path.contains('/auth/refresh')) {
            options.headers.remove('Authorization');
            return handler.next(options);
          }

          var token = _accessToken;
          if (token == null || token.isEmpty) {
            try {
              token = await storage.read(key: keyAccessToken);
              _accessToken = token;
            } catch (e) {
              debugPrint('ApiClient: error reading token: $e');
            }
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          debugPrint('❌ [API Error] ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}');
          if (error.response?.data != null) {
            debugPrint('   [API Response] ${error.response?.data}');
          }
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final requestPath = error.requestOptions.path;
            if (!requestPath.contains('/auth/local') &&
                !requestPath.contains('/auth/refresh')) {
              _isRefreshing = true;

              // Step 1: Try refreshing with stored refreshToken
              var refreshToken = _refreshToken;
              if (refreshToken == null || refreshToken.isEmpty) {
                try {
                  refreshToken = await storage.read(key: keyRefreshToken);
                  _refreshToken = refreshToken;
                } catch (_) {}
              }

              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  final refreshDio = Dio(BaseOptions(
                    baseUrl: ApiConfig.baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ));

                  final refreshResponse = await refreshDio.post(
                    '/auth/refresh',
                    data: {'refreshToken': refreshToken},
                  );

                  if (refreshResponse.statusCode == 200 &&
                      refreshResponse.data != null) {
                    final newJwt = refreshResponse.data['jwt'] as String?;
                    final newRefresh = refreshResponse.data['refreshToken'] as String?;

                    if (newJwt != null && newJwt.isNotEmpty) {
                      await saveTokens(jwt: newJwt, refreshToken: newRefresh);
                      _isRefreshing = false;

                      // Retry original request with new token
                      final clonedOptions = error.requestOptions;
                      clonedOptions.headers['Authorization'] = 'Bearer $newJwt';
                      final retryResponse = await dio.fetch(clonedOptions);
                      return handler.resolve(retryResponse);
                    }
                  }
                } catch (_) {
                  // Refresh token failed or expired
                }
              }

              // Step 2: Fallback to silent login using stored credentials if available
              try {
                final lastId = await storage.read(key: 'instacat_last_identifier');
                final lastPass = await storage.read(key: 'instacat_last_password');

                if (lastId != null &&
                    lastId.isNotEmpty &&
                    lastPass != null &&
                    lastPass.isNotEmpty) {
                  final authDio = Dio(BaseOptions(
                    baseUrl: ApiConfig.baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ));

                  final loginResponse = await authDio.post(
                    '/auth/local',
                    data: {
                      'identifier': lastId.trim(),
                      'password': lastPass,
                    },
                  );

                  if (loginResponse.statusCode == 200 && loginResponse.data != null) {
                    final newJwt = loginResponse.data['jwt'] as String?;
                    final newRefresh = loginResponse.data['refreshToken'] as String?;

                    if (newJwt != null && newJwt.isNotEmpty) {
                      await saveTokens(jwt: newJwt, refreshToken: newRefresh);
                      _isRefreshing = false;

                      final clonedOptions = error.requestOptions;
                      clonedOptions.headers['Authorization'] = 'Bearer $newJwt';
                      final retryResponse = await dio.fetch(clonedOptions);
                      return handler.resolve(retryResponse);
                    }
                  }
                }
              } catch (_) {
                // Silent login also failed
              }

              _isRefreshing = false;
              await clearTokens();
              onAuthFailed?.call();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> saveTokens({required String jwt, String? refreshToken}) async {
    _accessToken = jwt;
    _refreshToken = refreshToken;
    try {
      await storage.write(key: keyAccessToken, value: jwt);
      if (refreshToken != null) {
        await storage.write(key: keyRefreshToken, value: refreshToken);
      }
    } catch (e) {
      debugPrint('ApiClient: error saving tokens to storage: $e');
    }
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }
    try {
      _accessToken = await storage.read(key: keyAccessToken);
      return _accessToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      await storage.delete(key: keyAccessToken);
      await storage.delete(key: keyRefreshToken);
    } catch (_) {}
  }
}
