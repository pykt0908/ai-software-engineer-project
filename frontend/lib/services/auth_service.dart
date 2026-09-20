import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../utils/platform_utils.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final ApiClient _apiClient = ApiClient();

  static const String keyLastUser = 'instacat_last_user';
  static const String keyLastIdentifier = 'instacat_last_identifier';
  static const String keyLastPassword = 'instacat_last_password';

  CatUser? _lastUser;
  CatUser? get lastUser => _lastUser;

  final ValueNotifier<CatUser?> currentUserNotifier = ValueNotifier<CatUser?>(null);
  CatUser? get currentUser => currentUserNotifier.value;

  AuthService._internal() {
    _apiClient.onAuthFailed = () {
      currentUserNotifier.value = null;
    };
  }

  Future<CatUser?> loadLastUser() async {
    try {
      final userJson = await _apiClient.storage.read(key: keyLastUser);
      if (userJson != null && userJson.isNotEmpty) {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          _lastUser = CatUser.fromJson(decoded);
          return _lastUser;
        }
      }
    } catch (e) {
      debugPrint('AuthService: error loading last user: $e');
    }
    return _lastUser;
  }

  Future<void> saveLastUser(CatUser user, {String? identifier, String? password}) async {
    _lastUser = user;
    try {
      await _apiClient.storage.write(
        key: keyLastUser,
        value: jsonEncode(user.toJson()),
      );
      if (identifier != null && identifier.isNotEmpty) {
        await _apiClient.storage.write(key: keyLastIdentifier, value: identifier);
      }
      if (password != null && password.isNotEmpty) {
        await _apiClient.storage.write(key: keyLastPassword, value: password);
      }
    } catch (e) {
      debugPrint('AuthService: error saving last user: $e');
    }
  }

  Future<String?> getLastIdentifier() async {
    try {
      return await _apiClient.storage.read(key: keyLastIdentifier);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getLastPassword() async {
    try {
      return await _apiClient.storage.read(key: keyLastPassword);
    } catch (_) {
      return null;
    }
  }

  Future<bool> init() async {
    await loadLastUser();
    if (isFlutterTest) {
      return false;
    }
    final token = await _apiClient.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final user = await fetchCurrentUser();
        currentUserNotifier.value = user;
        await saveLastUser(user, identifier: user.username);
        return true;
      } catch (e) {
        await _apiClient.clearTokens();
        currentUserNotifier.value = null;
        return false;
      }
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<CatUser> login({
    required String identifier,
    required String password,
  }) async {
    if (isFlutterTest) {
      currentUserNotifier.value = MockData.currentUser;
      return MockData.currentUser;
    }
    try {
      final response = await _apiClient.dio.post(
        '/auth/local',
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      final data = response.data;
      final jwt = data['jwt'] as String?;
      if (jwt == null) {
        throw Exception('Login failed: Token not found in response');
      }

      await _apiClient.saveTokens(
        jwt: jwt,
        refreshToken: data['refreshToken'] as String?,
      );

      CatUser user;
      try {
        user = await fetchCurrentUser();
      } catch (_) {
        if (data['user'] is Map) {
          user = CatUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
        } else {
          rethrow;
        }
      }

      currentUserNotifier.value = user;
      await saveLastUser(user, identifier: identifier.trim(), password: password);
      return user;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<CatUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/local/register',
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      final jwt = data['jwt'] as String?;
      if (jwt == null) {
        throw Exception('Registration failed: Token not found in response');
      }

      await _apiClient.saveTokens(
        jwt: jwt,
        refreshToken: data['refreshToken'] as String?,
      );

      CatUser user;
      try {
        user = await fetchCurrentUser();
      } catch (_) {
        if (data['user'] is Map) {
          user = CatUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
        } else {
          rethrow;
        }
      }

      currentUserNotifier.value = user;
      await saveLastUser(user, identifier: username.trim(), password: password);
      return user;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception(message);
    }
  }

  Future<CatUser> fetchCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/me');
      final userData = response.data;
      final user = CatUser.fromJson(userData);
      currentUserNotifier.value = user;
      return user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );
      try {
        await _apiClient.storage.write(key: keyLastPassword, value: password);
      } catch (_) {}
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _apiClient.clearTokens();
      try {
        await _apiClient.storage.delete(key: keyLastPassword);
      } catch (_) {}
      currentUserNotifier.value = null;
    }
  }

  void updateCurrentUser(CatUser updated) {
    currentUserNotifier.value = updated;
    saveLastUser(updated, identifier: updated.username);
  }

  void resetForTest() {
    _lastUser = null;
    currentUserNotifier.value = null;
  }

  String _extractErrorMessage(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map) {
      final error = responseData['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet or server.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to server. Ensure Strapi is running.';
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
