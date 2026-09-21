import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'api_client.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;

  final ApiClient _apiClient = ApiClient();

  PostService._internal();

  Future<List<Post>> getPublicFeed({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '/feed/public',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<Post>> getUserPosts(String username, {int page = 1, int pageSize = 30}) async {
    try {
      final response = await _apiClient.dio.get(
        '/profiles/$username/posts',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<Post>> getFollowingFeed({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '/feed/following',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Post> getPost(String documentId) async {
    try {
      final response = await _apiClient.dio.get('/posts/$documentId');
      final data = response.data;
      if (data is Map && data['data'] != null) {
        return Post.fromJson(data['data']);
      }
      return Post.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<int>> uploadImages(List<File> files) async {
    if (files.isEmpty) return [];
    if (files.length > 10) {
      throw Exception('A maximum of 10 images can be uploaded per post.');
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final multipartFiles = <MultipartFile>[];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final targetPath =
            '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 85,
          minWidth: 2048,
          minHeight: 2048,
          format: CompressFormat.jpeg,
        );

        final filePath = compressed?.path ?? file.path;
        multipartFiles.add(
          await MultipartFile.fromFile(
            filePath,
            filename: 'post_img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          ),
        );
      }

      final formData = FormData();
      for (final mf in multipartFiles) {
        formData.files.add(MapEntry('files', mf));
      }

      final response = await _apiClient.dio.post('/upload', data: formData);

      final uploadedIds = <int>[];
      if (response.data is List) {
        for (final item in response.data) {
          if (item is Map && item['id'] != null) {
            uploadedIds.add(item['id'] as int);
          }
        }
      }
      return uploadedIds;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Post> createPost({
    required String caption,
    required List<int> imageIds,
    String location = '',
    List<String> taggedUsernames = const [],
  }) async {
    if (imageIds.isEmpty) {
      throw Exception('Please select at least 1 image');
    }
    if (imageIds.length > 10) {
      throw Exception('A post cannot contain more than 10 images');
    }

    try {
      final response = await _apiClient.dio.post(
        '/posts',
        data: {
          'caption': caption.trim(),
          'images': imageIds,
          'location': location.trim(),
          'taggedUsernames': taggedUsernames,
        },
      );

      final data = response.data;
      if (data is Map && data['data'] != null) {
        return Post.fromJson(data['data'] as Map<String, dynamic>);
      }
      return Post.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Post> updatePost({
    required String documentId,
    String? caption,
    List<int>? imageIds,
    String? location,
    List<String>? taggedUsernames,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (caption != null) payload['caption'] = caption.trim();
      if (imageIds != null) payload['images'] = imageIds;
      if (location != null) payload['location'] = location.trim();
      if (taggedUsernames != null) payload['taggedUsernames'] = taggedUsernames;

      final response = await _apiClient.dio.put(
        '/posts/$documentId',
        data: payload,
      );

      final data = response.data;
      if (data is Map && data['data'] != null) {
        return Post.fromJson(data['data'] as Map<String, dynamic>);
      }
      return Post.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deletePost(String documentId) async {
    try {
      await _apiClient.dio.delete('/posts/$documentId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> toggleLike({
    required String postDocumentId,
    required bool currentLiked,
  }) async {
    try {
      final response = currentLiked
          ? await _apiClient.dio.delete('/posts/$postDocumentId/like')
          : await _apiClient.dio.post('/posts/$postDocumentId/like');

      final raw = response.data;
      final payload = (raw is Map && raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw as Map);

      return {
        'liked': payload['liked'] == true,
        'likeCount': payload['likeCount'] is int
            ? payload['likeCount'] as int
            : (int.tryParse(payload['likeCount']?.toString() ?? '0') ?? 0),
      };
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> seedMockData() async {
    try {
      await _apiClient.dio.post('/feed/seed');
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
    return e.message ?? 'Post request failed';
  }
}
