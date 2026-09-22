import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    if (kIsWeb) {
      return File(resolved);
    }
    try {
      String tempPath;
      try {
        final tempDir = await getTemporaryDirectory();
        tempPath = tempDir.path;
      } catch (_) {
        tempPath = Directory.systemTemp.path;
      }
      final path =
          '$tempPath/ai_caption_dl_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<String>> generate({
    required File imageFile,
    required CaptionStyle style,
  }) async {
    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        Uint8List bytes;
        if (imageFile.path.startsWith('http://') ||
            imageFile.path.startsWith('https://')) {
          final res = await Dio().get<List<int>>(
            imageFile.path,
            options: Options(responseType: ResponseType.bytes),
          );
          bytes = Uint8List.fromList(res.data!);
        } else {
          bytes = await XFile(imageFile.path).readAsBytes();
        }
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: 'caption_img.jpg',
        );
      } else {
        String uploadPath = imageFile.path;
        try {
          String tempPath;
          try {
            final tempDir = await getTemporaryDirectory();
            tempPath = tempDir.path;
          } catch (_) {
            tempPath = Directory.systemTemp.path;
          }
          final targetPath =
              '$tempPath/ai_caption_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final compressed = await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: 80,
            minWidth: 1280,
            minHeight: 1280,
            format: CompressFormat.jpeg,
          );
          if (compressed != null) {
            uploadPath = compressed.path;
          }
        } catch (_) {
          uploadPath = imageFile.path;
        }

        multipartFile = await MultipartFile.fromFile(
          uploadPath,
          filename: 'caption_img.jpg',
        );
      }

      final formData = FormData.fromMap({
        'image': multipartFile,
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
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractErrorMessage(e));
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
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
    if (e.response?.statusCode == 405) {
      return 'ระบบ AI Caption ยังไม่พร้อมใช้งาน หรือ Endpoint ไม่ถูกต้อง (405 Method Not Allowed)';
    }
    if (e.response?.statusCode == 403) {
      return 'ไม่มีสิทธิ์เข้าถึงฟีเจอร์นี้ กรุณาเข้าสู่ระบบใหม่อีกครั้ง (403 Forbidden)';
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
    if (e.type == DioExceptionType.badResponse) {
      final status = e.response?.statusCode;
      return 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ ($status)';
    }
    return e.message ?? 'สร้าง caption ไม่สำเร็จ';
  }
}
