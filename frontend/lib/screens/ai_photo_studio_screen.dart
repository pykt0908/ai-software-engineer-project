import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/ai_image_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import 'ai_result_screen.dart';

class AiPhotoStudioScreen extends StatefulWidget {
  final File originalFile;

  const AiPhotoStudioScreen({
    super.key,
    required this.originalFile,
  });

  @override
  State<AiPhotoStudioScreen> createState() => _AiPhotoStudioScreenState();
}

class _AiPhotoStudioScreenState extends State<AiPhotoStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _intentController = TextEditingController();

  String _selectedPresetId = 'enhance';
  String _selectedStyle = 'warm';
  bool _isGeneratingPrompt = false;
  bool _isApplyingEdit = false;

  final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'enhance',
      'label': 'Enhance',
      'icon': Icons.auto_fix_high,
      'color': AppColors.primary,
      'preset': 'improve_lighting',
      'prompt':
          'Enhance lighting, improve fur textures, balance colors and create a clean vibrant cat photo.',
    },
    {
      'id': 'brighten',
      'label': 'Brighten',
      'icon': Icons.light_mode,
      'color': Colors.amber,
      'preset': 'improve_lighting',
      'prompt':
          'Brighten the photo with soft natural sunlight, clear shadows and gentle highlights.',
    },
    {
      'id': 'warm',
      'label': 'Warm',
      'icon': Icons.wb_sunny,
      'color': AppColors.primary,
      'preset': 'warm_cozy',
      'prompt':
          'Create a warm cozy home atmosphere with soft amber lighting and inviting tones.',
    },
    {
      'id': 'cute',
      'label': 'Cute',
      'icon': Icons.pets,
      'color': Colors.pink,
      'preset': 'soft_purr',
      'prompt':
          'Make the cat look adorable with twinkling eyes, soft dreamy background and cheerful mood.',
    },
    {
      'id': 'cinematic',
      'label': 'Cinematic',
      'icon': Icons.movie,
      'color': Colors.purple,
      'preset': 'vintage_cat',
      'prompt':
          'Cinematic lighting style with soft bokeh background and rich artistic tones.',
    },
    {
      'id': 'studio',
      'label': 'Studio',
      'icon': Icons.camera_alt,
      'color': Colors.blue,
      'preset': 'improve_sharpness',
      'prompt':
          'Studio cat portrait with ultra-crisp fur details and balanced professional lighting.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Default prompt from first quick action
    _promptController.text = _quickActions[0]['prompt'] as String;
  }

  @override
  void dispose() {
    _promptController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  void _onSelectQuickAction(Map<String, dynamic> action) {
    setState(() {
      _selectedPresetId = action['id'] as String;
      _promptController.text = action['prompt'] as String;
    });
  }

  void _resetPrompt() {
    setState(() {
      _selectedPresetId = 'enhance';
      _promptController.text = _quickActions[0]['prompt'] as String;
    });
  }

  Future<void> _generatePromptWithAi() async {
    final userIntent = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PromptGeneratorSheet(
        initialIntent: _intentController.text,
        initialStyle: _selectedStyle,
        onIntentChanged: (intent, style) {
          _intentController.text = intent;
          _selectedStyle = style;
        },
      ),
    );

    if (userIntent == null || !mounted) return;

    setState(() {
      _isGeneratingPrompt = true;
    });

    try {
      final response = await AiImageService().generateEditPrompt(
        imageFile: widget.originalFile,
        userIntent: _intentController.text.trim(),
        style: _selectedStyle,
      );

      if (!mounted) return;
      setState(() {
        _isGeneratingPrompt = false;
        _promptController.text = response.prompt;
      });
      AppSnackBar.success(context, 'สร้าง prompt ด้วย AI สำเร็จ!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGeneratingPrompt = false;
      });
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _applyAiEdit() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      AppSnackBar.error(context, 'กรุณาระบุคำสั่งแต่งภาพ');
      return;
    }

    setState(() {
      _isApplyingEdit = true;
    });

    try {
      final activeAction = _quickActions.firstWhere(
        (a) => a['id'] == _selectedPresetId,
        orElse: () => _quickActions[0],
      );

      final result = await AiImageService().editImage(
        imageFile: widget.originalFile,
        prompt: prompt,
        operation: 'edit',
        preset: activeAction['preset'] as String?,
      );

      final localFile =
          await AiImageService().downloadImageToTempFile(result.resultUrl);

      if (!mounted) return;
      setState(() {
        _isApplyingEdit = false;
      });

      // Navigate to AI Result Preview Screen
      final acceptedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) => AiResultScreen(
            originalFile: widget.originalFile,
            editedFile: localFile,
            result: result,
            initialPrompt: prompt,
          ),
        ),
      );

      if (acceptedFile != null && mounted) {
        Navigator.of(context).pop(acceptedFile);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isApplyingEdit = false;
      });
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: Column(
              children: [
                _buildTopNavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPhotoPreview(),
                        const SizedBox(height: 16),
                        _buildQuickActionsSection(),
                        const SizedBox(height: 16),
                        _buildPromptEditorSection(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF374151),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'ย้อนกลับ',
          ),
          const SizedBox(width: 4),
          Row(
            children: [
              const Text(
                'AI Photo Studio',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetPrompt,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (kIsWeb)
                Image.network(
                  widget.originalFile.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.broken_image,
                        color: Color(0xFF9CA3AF)),
                  ),
                )
              else
                Image.file(
                  widget.originalFile,
                  fit: BoxFit.cover,
                ),

              // Original Photo Badge (Top-left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 13, color: Color(0xFFFBBF24)),
                      SizedBox(width: 5),
                      Text(
                        'Original Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom AI Glow Line indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFB923C),
                        Color(0xFFFCD34D),
                        Color(0xFFF97316),
                      ],
                    ),
                  ),
                ),
              ),

              // Processing overlay
              if (_isApplyingEdit)
                Container(
                  color: Colors.black.withValues(alpha: 0.65),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3.5,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'กำลังเนรมิตภาพแมวด้วย AI...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'กำลังรักษาสายพันธุ์และลวดลายของน้องแมว 🐾',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'AI QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Text(
              '1-Tap Enhance',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickActions.map((action) {
              final isSelected = _selectedPresetId == action['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _onSelectQuickAction(action),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          action['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptEditorSection() {
    final charCount = _promptController.text.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Describe how you want to edit this photo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AI Prompt',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom styled text container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Make my cat brighter, sharper and more adorable while keeping natural fur texture...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 14, color: Color(0xFFF3F4F6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$charCount/200 chars',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _promptController.clear();
                        });
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.clear,
                              size: 13, color: Color(0xFF9CA3AF)),
                          SizedBox(width: 2),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Generate Prompt with AI Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isGeneratingPrompt ? null : _generatePromptWithAi,
              icon: _isGeneratingPrompt
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome,
                      size: 16, color: AppColors.primary),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isGeneratingPrompt
                        ? 'กำลังวิเคราะห์ภาพ...'
                        : '✨ Generate Prompt with AI',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Auto',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: const BorderSide(color: Color(0xFFFED7AA)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isApplyingEdit ? null : _applyAiEdit,
            icon: const Icon(Icons.auto_awesome,
                size: 20, color: Colors.white),
            label: const Text(
              '✨ Apply AI Edit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Use Original (Skip AI)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptGeneratorSheet extends StatefulWidget {
  final String initialIntent;
  final String initialStyle;
  final void Function(String intent, String style) onIntentChanged;

  const _PromptGeneratorSheet({
    required this.initialIntent,
    required this.initialStyle,
    required this.onIntentChanged,
  });

  @override
  State<_PromptGeneratorSheet> createState() => _PromptGeneratorSheetState();
}

class _PromptGeneratorSheetState extends State<_PromptGeneratorSheet> {
  late TextEditingController _intentCtrl;
  late String _style;

  final List<Map<String, String>> _styles = [
    {'id': 'warm', 'label': 'อบอุ่น (Warm)'},
    {'id': 'cute', 'label': 'น่ารัก (Cute)'},
    {'id': 'bright', 'label': 'สว่างใส (Bright)'},
    {'id': 'cinematic', 'label': 'ภาพยนตร์ (Cinematic)'},
    {'id': 'studio', 'label': 'สตูดิโอ (Studio)'},
  ];

  @override
  void initState() {
    super.initState();
    _intentCtrl = TextEditingController(text: widget.initialIntent);
    _style = widget.initialStyle;
  }

  @override
  void dispose() {
    _intentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'AI Prompt Assistant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ระบุความต้องการเพื่อให้ AI วิเคราะห์ภาพและร่างคำสั่งแต่งภาพที่ดีที่สุด',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _intentCtrl,
            decoration: InputDecoration(
              hintText: 'เช่น อยากให้ภาพดูอบอุ่น น่ารัก สว่างสดใส',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 14),
          const Text(
            'เลือกสไตล์:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _styles.map((s) {
              final isSel = _style == s['id'];
              return InkWell(
                onTap: () => setState(() => _style = s['id']!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                widget.onIntentChanged(_intentCtrl.text, _style);
                Navigator.of(context).pop(_intentCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'สร้าง Prompt',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
