import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/ai_image_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_snackbar.dart';

/// Shows the AI Photo Studio as a modal bottom sheet.
/// Returns the edited [File] if accepted, or null if cancelled/discarded.
Future<File?> showAiPhotoStudioSheet(
  BuildContext context, {
  required File imageFile,
}) {
  return showModalBottomSheet<File?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AiPhotoStudioSheet(originalFile: imageFile),
  );
}

enum _StudioMode {
  enhance,
  aiPrompt,
  customPrompt,
}

class _AiPhotoStudioSheet extends StatefulWidget {
  final File originalFile;

  const _AiPhotoStudioSheet({required this.originalFile});

  @override
  State<_AiPhotoStudioSheet> createState() => _AiPhotoStudioSheetState();
}

class _AiPhotoStudioSheetState extends State<_AiPhotoStudioSheet> {
  _StudioMode _currentMode = _StudioMode.enhance;

  // Mode A: Enhance Presets
  AiEnhancePreset _selectedPreset = kAiEnhancePresets[0];

  // Mode B: Custom Prompt
  final TextEditingController _customPromptController = TextEditingController();

  // Mode C: AI Prompt Generator
  final TextEditingController _userIntentController = TextEditingController();
  String _selectedStyle = 'warm';
  bool _isGeneratingPrompt = false;

  // Processing state
  bool _isProcessingImage = false;
  String _processingMessage = '';
  File? _editedFile;
  AiImageEditResult? _lastResult;

  // Before/After comparison
  bool _showOriginalInPreview = false;

  final List<String> _promptSuggestions = [
    'ทำให้ภาพสว่างและอบอุ่นขึ้นแบบ Home Cafe',
    'เพิ่มแสงแดดยามเช้าส่องผ่านหน้าต่าง ละมุนตา',
    'ขับสีขนแมวและประกายในดวงตาให้คมชัด',
    'ปรับโทนสีแนวภาพยนตร์ Cinematic ฟุ้งเบาๆ',
  ];

  final List<Map<String, String>> _styleOptions = [
    {'id': 'warm', 'label': 'อบอุ่น (Warm)'},
    {'id': 'cute', 'label': 'น่ารัก (Cute)'},
    {'id': 'bright', 'label': 'สว่างใส (Bright)'},
    {'id': 'cinematic', 'label': 'ภาพยนตร์ (Cinematic)'},
    {'id': 'studio', 'label': 'สตูดิโอ (Studio)'},
  ];

  @override
  void dispose() {
    _customPromptController.dispose();
    _userIntentController.dispose();
    super.dispose();
  }

  Future<void> _handleGeneratePrompt() async {
    if (_isGeneratingPrompt || _isProcessingImage) return;

    setState(() {
      _isGeneratingPrompt = true;
    });

    try {
      final response = await AiImageService().generateEditPrompt(
        imageFile: widget.originalFile,
        userIntent: _userIntentController.text.trim(),
        style: _selectedStyle,
      );

      if (!mounted) return;
      setState(() {
        _isGeneratingPrompt = false;
        _customPromptController.text = response.prompt;
      });
      AppSnackBar.success(context, 'AI สร้าง prompt สำเร็จ! สามารถแก้ไขได้');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGeneratingPrompt = false;
      });
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _handleApplyEdit({String? directPresetId}) async {
    if (_isProcessingImage) return;

    String promptToUse = '';
    String operation = 'edit';
    String? presetToUse;

    if (_currentMode == _StudioMode.enhance || directPresetId != null) {
      final presetId = directPresetId ?? _selectedPreset.id;
      final p = kAiEnhancePresets.firstWhere((x) => x.id == presetId);
      presetToUse = p.id;
      promptToUse = 'Enhance cat photo with ${p.titleTh} effect';
      operation = 'enhance';
    } else {
      promptToUse = _customPromptController.text.trim();
      if (promptToUse.isEmpty) {
        AppSnackBar.error(context, 'กรุณาใส่คำสั่งแต่งภาพ หรือให้ AI ช่วยคิด');
        return;
      }
    }

    setState(() {
      _isProcessingImage = true;
      _processingMessage = 'กำลังเนรมิตภาพแมวด้วย AI...';
    });

    try {
      final result = await AiImageService().editImage(
        imageFile: widget.originalFile,
        prompt: promptToUse,
        operation: operation,
        preset: presetToUse,
      );

      // Download result image to local temp File for instant rendering & usage
      setState(() {
        _processingMessage = 'กำลังโหลดภาพผลลัพธ์...';
      });

      final localFile =
          await AiImageService().downloadImageToTempFile(result.resultUrl);

      if (!mounted) return;
      setState(() {
        _isProcessingImage = false;
        _editedFile = localFile;
        _lastResult = result;
        _showOriginalInPreview = false;
      });
      AppSnackBar.success(context, 'แต่งภาพด้วย AI สำเร็จ!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingImage = false;
      });
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _useThisImage() {
    if (_editedFile != null) {
      Navigator.of(context).pop(_editedFile);
    }
  }

  void _discardEdit() {
    setState(() {
      _editedFile = null;
      _lastResult = null;
      _showOriginalInPreview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasResult = _editedFile != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'ปิด',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'AI Photo Studio',
                            style: AppTypography.bodyBold.copyWith(fontSize: 17),
                          ),
                        ],
                      ),
                      Text(
                        hasResult
                            ? 'เปรียบเทียบและเลือกใช้งานภาพที่แต่งแล้ว'
                            : 'เลือกโหมดการแต่งภาพแมวด้วย AI',
                        style: AppTypography.captionTimestamp.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasResult)
                  TextButton(
                    onPressed: _useThisImage,
                    child: Text(
                      'ใช้รูปนี้',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview Box (Aspect ratio 1:1)
                  _buildImagePreview(hasResult),
                  const SizedBox(height: 14),

                  if (hasResult) ...[
                    _buildResultControls(),
                  ] else ...[
                    // Mode selector segment
                    _buildModeSelector(),
                    const SizedBox(height: 14),

                    // Mode content
                    if (_currentMode == _StudioMode.enhance)
                      _buildEnhanceMode()
                    else if (_currentMode == _StudioMode.aiPrompt)
                      _buildAiPromptMode()
                    else
                      _buildCustomPromptMode(),

                    const SizedBox(height: 16),
                    _buildApplyButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool hasResult) {
    final activeFile =
        (hasResult && !_showOriginalInPreview) ? _editedFile! : widget.originalFile;

    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Current image display
            if (kIsWeb)
              Image.network(
                activeFile.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceSecondary,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.textPlaceholder),
                  ),
                ),
              )
            else
              Image.file(
                activeFile,
                fit: BoxFit.cover,
              ),

            // Badge indicating original vs AI result
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasResult && !_showOriginalInPreview
                        ? AppColors.primary
                        : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasResult && !_showOriginalInPreview
                          ? Icons.auto_awesome
                          : Icons.image,
                      size: 13,
                      color: hasResult && !_showOriginalInPreview
                          ? AppColors.primary
                          : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hasResult
                          ? (_showOriginalInPreview
                              ? 'ต้นฉบับ (Original)'
                              : 'ภาพแต่งด้วย AI')
                          : 'ต้นฉบับ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Before / After toggle button (when edit result exists)
            if (hasResult)
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showOriginalInPreview = !_showOriginalInPreview;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.compare_arrows,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _showOriginalInPreview
                                ? 'กดเพื่อดู AI Result'
                                : 'กดเพื่อดูต้นฉบับ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Loading overlay while processing
            if (_isProcessingImage)
              Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _processingMessage,
                        style: AppTypography.bodyBold.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'กำลังรักษาสายพันธุ์และลวดลายของน้องแมว 🐾',
                        style: AppTypography.captionTimestamp.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ผลการแปลงภาพด้วย AI',
                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                  ),
                  const Spacer(),
                  if (_lastResult?.provider != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _lastResult!.provider,
                        style: AppTypography.captionTimestamp.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (_lastResult?.prompt.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  _lastResult!.prompt,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _discardEdit,
                icon: const Icon(Icons.undo, size: 16),
                label: const Text('ลองใหม่'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _useThisImage,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('ใช้รูปนี้ในโพสต์'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(
            mode: _StudioMode.enhance,
            title: '✨ แต่งด่วน',
          ),
          _buildTabItem(
            mode: _StudioMode.aiPrompt,
            title: '🤖 AI คิดคำสั่ง',
          ),
          _buildTabItem(
            mode: _StudioMode.customPrompt,
            title: '✍️ คำสั่งเอง',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required _StudioMode mode, required String title}) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceCanvas : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.labelSm.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mode A: Enhance Presets
  Widget _buildEnhanceMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เลือกพรีเซ็ตการปรับแต่ง (One-Tap Enhance)',
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.3,
          ),
          itemCount: kAiEnhancePresets.length,
          itemBuilder: (context, index) {
            final preset = kAiEnhancePresets[index];
            final isSelected = _selectedPreset.id == preset.id;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPreset = preset;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      preset.icon,
                      size: 22,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            preset.titleTh,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            preset.subtitleTh,
                            style: AppTypography.captionTimestamp.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Mode B: Custom Prompt
  Widget _buildCustomPromptMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เขียนคำสั่งที่ต้องการให้ AI ปรับแต่งรูปภาพ',
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customPromptController,
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(
            hintText: 'เช่น ทำให้ภาพสว่างขึ้นและพื้นหลังละมุนตา...',
            hintStyle: AppTypography.bodyRegular
                .copyWith(color: AppColors.textPlaceholder),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 10),
        Text(
          'ตัวอย่างคำสั่งแนะนำ:',
          style: AppTypography.captionTimestamp.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _promptSuggestions.map((suggestion) {
            return InkWell(
              onTap: () {
                setState(() {
                  _customPromptController.text = suggestion;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  suggestion,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Mode C: AI Prompt Generator
  Widget _buildAiPromptMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ระบุความต้องการสั้นๆ แล้วให้ AI ช่วยร่าง Prompt',
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _userIntentController,
          decoration: InputDecoration(
            hintText: 'เช่น อยากให้ดูน่ารักและอบอุ่นเหมือนอยู่ในคาเฟ่',
            hintStyle: AppTypography.bodyRegular
                .copyWith(color: AppColors.textPlaceholder),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 10),
        Text(
          'สไตล์ที่ต้องการ:',
          style: AppTypography.captionTimestamp.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _styleOptions.map((opt) {
            final active = _selectedStyle == opt['id'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedStyle = opt['id']!;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  opt['label']!,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: active ? Colors.white : AppColors.textPrimary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isGeneratingPrompt ? null : _handleGeneratePrompt,
            icon: _isGeneratingPrompt
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 16),
            label: Text(
              _isGeneratingPrompt
                  ? 'AI กำลังวิเคราะห์ภาพและสร้าง Prompt...'
                  : '✨ วิเคราะห์ภาพและสร้าง Prompt ด้วย AI',
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_customPromptController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Prompt ที่ AI สร้างให้ (ตรวจและแก้ไขได้):',
            style: AppTypography.captionTimestamp.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _customPromptController,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppTypography.bodySm,
          ),
        ],
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessingImage ? null : () => _handleApplyEdit(),
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          _currentMode == _StudioMode.enhance
              ? '✨ ปรับแต่งภาพด้วยพรีเซ็ต "${_selectedPreset.titleTh}"'
              : '✨ เนรมิตภาพด้วย AI (Apply AI Edit)',
          style: AppTypography.bodyBold.copyWith(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
