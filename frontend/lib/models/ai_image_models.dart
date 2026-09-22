import 'package:flutter/material.dart';

class AiEnhancePreset {
  final String id;
  final String titleTh;
  final String subtitleTh;
  final IconData icon;

  const AiEnhancePreset({
    required this.id,
    required this.titleTh,
    required this.subtitleTh,
    required this.icon,
  });
}

const List<AiEnhancePreset> kAiEnhancePresets = [
  AiEnhancePreset(
    id: 'improve_lighting',
    titleTh: 'สว่างสดใส',
    subtitleTh: 'ปรับแสงและเงาให้สว่างนุ่มนวล',
    icon: Icons.wb_sunny_outlined,
  ),
  AiEnhancePreset(
    id: 'warm_cozy',
    titleTh: 'คาเฟ่อบอุ่น',
    subtitleTh: 'โทนอุ่นสไตล์ Home Cafe',
    icon: Icons.coffee_outlined,
  ),
  AiEnhancePreset(
    id: 'vivid_colors',
    titleTh: 'สีสันสดใส',
    subtitleTh: 'เน้นสีขนและดวงตาให้โดดเด่น',
    icon: Icons.palette_outlined,
  ),
  AiEnhancePreset(
    id: 'improve_sharpness',
    titleTh: 'สตูดิโอคมชัด',
    subtitleTh: 'คมชัดทุกเส้นขนและรายละเอียด',
    icon: Icons.camera_outlined,
  ),
  AiEnhancePreset(
    id: 'vintage_cat',
    titleTh: 'ฟิล์มวินเทจ',
    subtitleTh: 'สไตล์ภาพฟิล์มคลาสสิกอบอุ่น',
    icon: Icons.filter_vintage_outlined,
  ),
  AiEnhancePreset(
    id: 'soft_purr',
    titleTh: 'ละมุนฟุ้ง',
    subtitleTh: 'แสงนุ่มละมุน ชวนฝัน',
    icon: Icons.auto_awesome_outlined,
  ),
];

class AiPromptResponse {
  final String prompt;
  final String style;
  final List<String> suggestedGuardrails;

  AiPromptResponse({
    required this.prompt,
    required this.style,
    this.suggestedGuardrails = const [],
  });

  factory AiPromptResponse.fromJson(Map<String, dynamic> json) {
    return AiPromptResponse(
      prompt: json['prompt'] as String? ?? '',
      style: json['style'] as String? ?? 'natural',
      suggestedGuardrails: (json['suggestedGuardrails'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class AiImageEditResult {
  final String jobId;
  final String status;
  final String prompt;
  final String provider;
  final String resultUrl;
  final int? mediaId;

  AiImageEditResult({
    required this.jobId,
    required this.status,
    required this.prompt,
    required this.provider,
    required this.resultUrl,
    this.mediaId,
  });

  factory AiImageEditResult.fromJson(Map<String, dynamic> json) {
    final media = json['resultMedia'] as Map<String, dynamic>? ?? {};
    return AiImageEditResult(
      jobId: json['jobId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      prompt: json['prompt']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'ai',
      resultUrl: media['url']?.toString() ?? '',
      mediaId: media['id'] is int ? media['id'] as int : null,
    );
  }
}
