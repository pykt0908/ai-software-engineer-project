import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../utils/platform_utils.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  final ApiClient _apiClient = ApiClient();

  ProfileService._internal();

  Future<CatUser> getMe() async {
    if (isFlutterTest) {
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
    String? website,
    String? category,
    bool? isPublic,
    int? avatarId,
  }) async {
    if (isFlutterTest) {
      final current = AuthService().currentUser ?? MockData.currentUser;
      return current.copyWith(
        username: username ?? current.username,
        displayName: displayName ?? current.displayName,
        bio: bio ?? current.bio,
        website: website ?? current.website,
        category: category ?? current.category,
        isPublic: isPublic ?? current.isPublic,
      );
    }
    try {
      final data = <String, dynamic>{};
      if (username != null && username.isNotEmpty) data['username'] = username.trim();
      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (website != null) {
        data['website'] = website
            .trim()
            .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
      }
      if (category != null) data['category'] = category.trim();
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

  Future<List<CatUser>> searchUsers(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    if (isFlutterTest) {
      final all = [
        AuthService().currentUser ?? MockData.currentUser,
        MockData.biscuitPaw,
        MockData.miloTheScottish,
        MockData.lunaCalico,
        MockData.oliverWhiskers,
        MockData.churuLover,
      ];
      final lower = q.toLowerCase();
      return all
          .where((u) =>
              u.username.toLowerCase().contains(lower) ||
              u.displayName.toLowerCase().contains(lower))
          .toList();
    }

    try {
      final response = await _apiClient.dio.get(
        '/profiles/search',
        queryParameters: {'q': q},
      );
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map>()
          .map((item) => CatUser.fromJson(Map<String, dynamic>.from(item)))
          .where((u) => u.username.isNotEmpty)
          .toList();
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

      final raw = response.data;
      final payload = (raw is Map && raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw as Map);

      return {
        'following': payload['following'] == true,
        'followersCount': payload['followersCount'] is int
            ? payload['followersCount'] as int
            : (int.tryParse(payload['followersCount']?.toString() ?? '0') ?? 0),
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
