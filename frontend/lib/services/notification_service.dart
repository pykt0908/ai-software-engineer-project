import 'package:dio/dio.dart';

import '../models/models.dart';
import '../utils/platform_utils.dart';
import 'api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationItem>> list({String? type}) async {
    if (isFlutterTest) {
      return const [];
    }

    try {
      final query = <String, dynamic>{};
      if (type != null && type.isNotEmpty) {
        query['type'] = type;
      }
      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: query.isEmpty ? null : query,
      );
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map>()
          .map((item) => NotificationItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<int> unreadCount() async {
    if (isFlutterTest) return 0;

    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');
      final data = response.data['data'];
      if (data is Map) {
        final count = data['unreadCount'];
        if (count is int) return count;
        return int.tryParse(count?.toString() ?? '0') ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> markRead(String documentId) async {
    if (isFlutterTest) return;
    try {
      await _apiClient.dio.patch('/notifications/$documentId/read');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> markAllRead() async {
    if (isFlutterTest) return;
    try {
      await _apiClient.dio.post('/notifications/mark-all-read');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> delete(String documentId) async {
    if (isFlutterTest) return;
    try {
      await _apiClient.dio.delete('/notifications/$documentId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['error'] is Map && data['error']['message'] != null) {
        return data['error']['message'].toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return e.message ?? 'Request failed';
  }
}
