import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';
import 'api_config.dart';

enum CaptionStyle {
  cute,
  funny,
  sassy,
  short;

  String get labelTh {
    switch (this) {
      case CaptionStyle.cute:
        return 'น่ารัก';
      case CaptionStyle.funny:
        return 'ตลก';
      case CaptionStyle.sassy:
        return 'กวนๆ';
      case CaptionStyle.short:
        return 'สั้นกระชับ';
    }
  }
}

class AiCaptionService {
  static final AiCaptionService _instance = AiCaptionService._internal();
  factory AiCaptionService() => _instance;

  final ApiClient _apiClient = ApiClient();

  AiCaptionService._internal();

  /// Downloads a remote image (e.g. existing post media) to a temp file for AI generate.
  Future<File> downloadImageToTempFile(String url) async {
    final resolved = ApiConfig.resolveImageUrl(url) ?? url;
    try {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/ai_caption_dl_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _apiClient.dio.download(
        resolved,
        path,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
          responseType: ResponseType.bytes,
        ),
      );
      return File(path);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<String>> generate({
    required File imageFile,
    required CaptionStyle style,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/ai_caption_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      final uploadPath = compressed?.path ?? imageFile.path;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          uploadPath,
          filename: 'caption_img.jpg',
        ),
        'style': style.name,
      });

      final response = await _apiClient.dio.post(
        '/ai-caption/generate',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;
      if (data is Map && data['data'] is Map) {
        final captions = data['data']['captions'];
        if (captions is List) {
          return captions
              .whereType<String>()
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList();
        }
      }
      throw Exception('ไม่ได้รับ caption จากเซิร์ฟเวอร์');
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
    if (e.response?.statusCode == 429) {
      return 'วันนี้ใช้ AI สร้าง caption ครบโควต้าแล้ว ลองใหม่พรุ่งนี้';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'AI ใช้เวลานานเกินไป กรุณาลองใหม่';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ ตรวจสอบว่า Strapi กำลังรันอยู่';
    }
    return e.message ?? 'สร้าง caption ไม่สำเร็จ';
  }
}
