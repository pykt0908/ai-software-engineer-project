import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import 'api_client.dart';
import 'api_config.dart';

class AiImageService {
  static final AiImageService _instance = AiImageService._internal();
  factory AiImageService() => _instance;

  final ApiClient _apiClient = ApiClient();

  AiImageService._internal();

  /// Downloads a generated image from remote URL to a local temporary File
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
          '$tempPath/ai_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _apiClient.dio.download(
        resolved,
        path,
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 20),
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

  Future<MultipartFile> _prepareMultipartFile(File imageFile) async {
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
        bytes = await imageFile.readAsBytes();
      }
      return MultipartFile.fromBytes(
        bytes,
        filename: 'source_cat.jpg',
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
            '$tempPath/ai_src_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressed = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          targetPath,
          quality: 85,
          minWidth: 1080,
          minHeight: 1080,
          format: CompressFormat.jpeg,
        );

        if (compressed != null) {
          uploadPath = compressed.path;
        }
      } catch (_) {
        uploadPath = imageFile.path;
      }

      return await MultipartFile.fromFile(
        uploadPath,
        filename: 'source_cat.jpg',
      );
    }
  }

  /// Asks AI to generate an image-to-image editing prompt from the image and optional user intent
  Future<AiPromptResponse> generateEditPrompt({
    required File imageFile,
    String? userIntent,
    String? style,
  }) async {
    try {
      final multipart = await _prepareMultipartFile(imageFile);
      final formData = FormData.fromMap({
        'image': multipart,
        if (userIntent != null && userIntent.trim().isNotEmpty)
          'userIntent': userIntent.trim(),
        if (style != null && style.trim().isNotEmpty)
          'style': style.trim(),
      });

      final response = await _apiClient.dio.post(
        '/ai/generate-edit-prompt',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return AiPromptResponse.fromJson(
            Map<String, dynamic>.from(data['data']));
      }
      throw Exception('ไม่ได้รับ prompt จากเซิร์ฟเวอร์');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Sends the image + prompt / preset to the backend AI image editing service
  Future<AiImageEditResult> editImage({
    required File imageFile,
    required String prompt,
    String operation = 'edit',
    String? preset,
  }) async {
    try {
      final multipart = await _prepareMultipartFile(imageFile);
      final formData = FormData.fromMap({
        'image': multipart,
        'prompt': prompt,
        'operation': operation,
        if (preset != null && preset.isNotEmpty) 'preset': preset,
      });

      final response = await _apiClient.dio.post(
        '/ai/image-edit',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return AiImageEditResult.fromJson(
            Map<String, dynamic>.from(data['data']));
      }
      throw Exception('ไม่ได้รับผลลัพธ์รูปภาพจากเซิร์ฟเวอร์');
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
    if (e.response?.statusCode == 405) {
      return 'เซิร์ฟเวอร์ยังไม่เปิดให้บริการฟีเจอร์ AI นี้ (405 Method Not Allowed)';
    }
    if (e.response?.statusCode == 403) {
      return 'ไม่มีสิทธิ์เข้าถึงฟีเจอร์นี้ กรุณาเข้าสู่ระบบใหม่อีกครั้ง';
    }
    if (e.response?.statusCode == 429) {
      return 'วันนี้ใช้ AI แต่งภาพครบโควต้าแล้ว ลองใหม่อีกครั้งพรุ่งนี้นะครับ 🐾';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'AI ใช้เวลาประมวลผลนานเกินไป กรุณาลองใหม่อีกครั้ง';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ ตรวจสอบว่าระบบหลังบ้านกำลังทำงานอยู่';
    }
    if (e.type == DioExceptionType.badResponse) {
      return 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (${e.response?.statusCode ?? 500})';
    }
    return e.message ?? 'แต่งรูปภาพไม่สำเร็จ';
  }
}
