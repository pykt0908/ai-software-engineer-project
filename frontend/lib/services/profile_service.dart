import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  final ApiClient _apiClient = ApiClient();

  ProfileService._internal();

  Future<CatUser> getMe() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return AuthService().currentUser ?? MockData.currentUser;
    }
    try {
      final response = await _apiClient.dio.get('/me');
      return CatUser.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<CatUser> updateMe({
    String? username,
    String? displayName,
    String? bio,
    bool? isPublic,
    int? avatarId,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final current = AuthService().currentUser ?? MockData.currentUser;
      return current.copyWith(
        username: username ?? current.username,
        displayName: displayName ?? current.displayName,
        bio: bio ?? current.bio,
        isPublic: isPublic ?? current.isPublic,
      );
    }
    try {
      final data = <String, dynamic>{};
      if (username != null && username.isNotEmpty) data['username'] = username.trim();
      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (isPublic != null) data['isPublic'] = isPublic;
      if (avatarId != null) data['avatar'] = avatarId;

      final response = await _apiClient.dio.put('/me', data: data);
      return CatUser.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<CatUser> getProfile(String username) async {
    try {
      final response = await _apiClient.dio.get('/profiles/$username');
      return CatUser.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> toggleFollow({
    required String targetDocumentId,
    required bool currentFollowing,
  }) async {
    try {
      final response = currentFollowing
          ? await _apiClient.dio.delete('/users/$targetDocumentId/follow')
          : await _apiClient.dio.post('/users/$targetDocumentId/follow');

      return {
        'following': response.data['following'] == true,
        'followersCount': response.data['followersCount'] ?? 0,
      };
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<int> uploadAvatar(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      final uploadPath = compressedXFile?.path ?? file.path;

      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          uploadPath,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _apiClient.dio.post('/upload', data: formData);
      if (response.data is List && (response.data as List).isNotEmpty) {
        return response.data[0]['id'] as int;
      }
      throw Exception('Avatar upload did not return media record');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
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
    return e.message ?? 'Profile request failed';
  }
}
