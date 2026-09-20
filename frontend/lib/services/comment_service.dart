import 'package:dio/dio.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../utils/platform_utils.dart';
import 'api_client.dart';
import 'auth_service.dart';

class CommentListResult {
  final List<Comment> comments;
  final int commentCount;

  const CommentListResult({
    required this.comments,
    required this.commentCount,
  });
}

class CommentCreateResult {
  final Comment comment;
  final int commentCount;

  const CommentCreateResult({
    required this.comment,
    required this.commentCount,
  });
}

class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;

  final ApiClient _apiClient = ApiClient();

  CommentService._internal();

  Future<CommentListResult> listComments(
    String postDocumentId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    if (isFlutterTest) {
      return const CommentListResult(comments: [], commentCount: 0);
    }

    try {
      final response = await _apiClient.dio.get(
        '/posts/$postDocumentId/comments',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final raw = response.data;
      final list = (raw is Map && raw['data'] is List)
          ? raw['data'] as List
          : <dynamic>[];
      final comments = list
          .whereType<Map>()
          .map((item) => Comment.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      final meta = (raw is Map && raw['meta'] is Map)
          ? Map<String, dynamic>.from(raw['meta'] as Map)
          : <String, dynamic>{};
      final commentCount = meta['commentCount'] is int
          ? meta['commentCount'] as int
          : comments.length;

      return CommentListResult(comments: comments, commentCount: commentCount);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<CommentCreateResult> createComment({
    required String postDocumentId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw Exception('Comment text is required');
    }

    if (isFlutterTest) {
      final user = AuthService().currentUser ?? MockData.currentUser;
      return CommentCreateResult(
        comment: Comment(
          id: 'comment_test_${DateTime.now().millisecondsSinceEpoch}',
          user: user,
          text: trimmed,
          timestamp: 'Just now',
        ),
        commentCount: 1,
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/posts/$postDocumentId/comments',
        data: {'text': trimmed},
      );

      final raw = response.data;
      if (raw is! Map) {
        throw Exception('Unexpected comment response');
      }
      final map = Map<String, dynamic>.from(raw);
      final payload = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;
      final meta = map['meta'] is Map
          ? Map<String, dynamic>.from(map['meta'] as Map)
          : <String, dynamic>{};

      return CommentCreateResult(
        comment: Comment.fromJson(payload),
        commentCount: meta['commentCount'] is int
            ? meta['commentCount'] as int
            : 1,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<int> deleteComment(String commentDocumentId) async {
    if (isFlutterTest) {
      return 0;
    }

    try {
      final response = await _apiClient.dio.delete('/comments/$commentDocumentId');
      final raw = response.data;
      final payload = (raw is Map && raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

      return payload['commentCount'] is int
          ? payload['commentCount'] as int
          : (int.tryParse(payload['commentCount']?.toString() ?? '0') ?? 0);
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
    return e.message ?? 'Comment request failed';
  }
}
