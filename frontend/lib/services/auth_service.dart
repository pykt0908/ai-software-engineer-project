import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final ApiClient _apiClient = ApiClient();

  final ValueNotifier<CatUser?> currentUserNotifier = ValueNotifier<CatUser?>(null);
  CatUser? get currentUser => currentUserNotifier.value;

  AuthService._internal() {
    _apiClient.onAuthFailed = () {
      currentUserNotifier.value = null;
    };
  }

  Future<bool> init() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    final token = await _apiClient.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final user = await fetchCurrentUser();
        currentUserNotifier.value = user;
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
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
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
      currentUserNotifier.value = null;
    }
  }

  void updateCurrentUser(CatUser updated) {
    currentUserNotifier.value = updated;
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
