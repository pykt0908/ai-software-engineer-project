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
          // Do not send Authorization header for public auth routes
          if (options.path.contains('/auth/local')) {
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
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final requestPath = error.requestOptions.path;
            if (!requestPath.contains('/auth/local') &&
                !requestPath.contains('/auth/refresh')) {
              _isRefreshing = true;
              var refreshToken = _refreshToken;
              if (refreshToken == null || refreshToken.isEmpty) {
                try {
                  refreshToken = await storage.read(key: keyRefreshToken);
                  _refreshToken = refreshToken;
                } catch (_) {}
              }

              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  final refreshResponse = await dio.post(
                    '/auth/refresh',
                    data: {'refreshToken': refreshToken},
                    options: Options(headers: {'Authorization': ''}),
                  );

                  if (refreshResponse.statusCode == 200 &&
                      refreshResponse.data != null) {
                    final newJwt = refreshResponse.data['jwt'] as String?;
                    final newRefresh = refreshResponse.data['refreshToken'] as String?;

                    if (newJwt != null) {
                      _accessToken = newJwt;
                      _refreshToken = newRefresh ?? _refreshToken;
                      try {
                        await storage.write(key: keyAccessToken, value: newJwt);
                        if (newRefresh != null) {
                          await storage.write(
                              key: keyRefreshToken, value: newRefresh);
                        }
                      } catch (_) {}
                    }

                    _isRefreshing = false;

                    // Retry original request with new token
                    final clonedOptions = error.requestOptions;
                    clonedOptions.headers['Authorization'] = 'Bearer $newJwt';
                    final retryResponse = await dio.fetch(clonedOptions);
                    return handler.resolve(retryResponse);
                  }
                } catch (_) {
                  // Refresh token failed or expired
                }
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
