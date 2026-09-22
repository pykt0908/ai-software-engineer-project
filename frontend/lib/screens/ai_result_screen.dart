import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/ai_image_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';

enum ComparisonMode {
  splitSlider,
  sideBySide,
}

class AiResultScreen extends StatefulWidget {
  final File originalFile;
  final File editedFile;
  final AiImageEditResult result;
  final String initialPrompt;

  const AiResultScreen({
    super.key,
    required this.originalFile,
    required this.editedFile,
    required this.result,
    required this.initialPrompt,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  late File _currentEditedFile;
  late String _currentPrompt;
  late AiImageEditResult _currentResult;

  ComparisonMode _comparisonMode = ComparisonMode.splitSlider;
  double _sliderPosition = 0.5; // 0.0 to 1.0
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _currentEditedFile = widget.editedFile;
    _currentPrompt = widget.initialPrompt;
    _currentResult = widget.result;
  }

  Future<void> _handleTryAgain() async {
    if (_isRegenerating) return;

    setState(() {
      _isRegenerating = true;
    });

    try {
      final newResult = await AiImageService().editImage(
        imageFile: widget.originalFile,
        prompt: _currentPrompt,
        operation: 'edit',
      );

      final newLocalFile =
          await AiImageService().downloadImageToTempFile(newResult.resultUrl);

      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
        _currentResult = newResult;
        _currentEditedFile = newLocalFile;
      });
      AppSnackBar.success(context, 'สร้างภาพใหม่สำเร็จ!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
      });
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _useThisPhoto() {
    Navigator.of(context).pop(_currentEditedFile);
  }

  void _editPrompt() {
    // Return to Studio with current prompt
    Navigator.of(context).pop();
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
                        _buildViewSwitcher(),
                        const SizedBox(height: 12),
                        _buildComparisonViewer(),
                        const SizedBox(height: 16),
                        _buildAiSummaryCard(),
                        const SizedBox(height: 18),
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
                'AI Result',
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
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'Ready',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _useThisPhoto,
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildSwitchTab(
                label: 'Split Slider',
                icon: Icons.compare,
                active: _comparisonMode == ComparisonMode.splitSlider,
                onTap: () {
                  setState(() {
                    _comparisonMode = ComparisonMode.splitSlider;
                  });
                },
              ),
              _buildSwitchTab(
                label: 'Side by Side',
                icon: Icons.view_column,
                active: _comparisonMode == ComparisonMode.sideBySide,
                onTap: () {
                  setState(() {
                    _comparisonMode = ComparisonMode.sideBySide;
                  });
                },
              ),
            ],
          ),
        ),
        if (_comparisonMode == ComparisonMode.splitSlider)
          const Row(
            children: [
              Icon(Icons.touch_app, size: 13, color: AppColors.primary),
              SizedBox(width: 3),
              Text(
                'Drag slider to inspect',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSwitchTab({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.primary : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonViewer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _comparisonMode == ComparisonMode.splitSlider
              ? _buildSplitSliderView()
              : _buildSideBySideView(),
        ),
      ),
    );
  }

  /// Interactive Split Slider Before/After Comparison
  Widget _buildSplitSliderView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;
        final dividerX = totalWidth * _sliderPosition;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              final newPos =
                  (details.localPosition.dx / totalWidth).clamp(0.05, 0.95);
              _sliderPosition = newPos;
            });
          },
          onTapDown: (details) {
            setState(() {
              final newPos =
                  (details.localPosition.dx / totalWidth).clamp(0.05, 0.95);
              _sliderPosition = newPos;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background: AI Result (full size)
              _buildImageWidget(_currentEditedFile),

              // Foreground: Original Image (Clipped overlay based on divider position)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: dividerX,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: totalWidth,
                    maxHeight: totalHeight,
                    minWidth: totalWidth,
                    minHeight: totalHeight,
                    child: _buildImageWidget(widget.originalFile),
                  ),
                ),
              ),

              // Original Badge (top-left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.white70,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Original',
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

              // AI Result Badge (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2410C).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'AI Result',
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

              // Vertical Divider line with shadow
              Positioned(
                left: dividerX - 1,
                top: 0,
                bottom: 0,
                width: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable Center Circular Handle
              Positioned(
                left: dividerX - 18,
                top: totalHeight / 2 - 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.unfold_more,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Regenerating loader
              if (_isRegenerating)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'กำลังสร้างภาพใหม่...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Side-by-side comparison mode
  Widget _buildSideBySideView() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageWidget(widget.originalFile),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Original',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(width: 2, color: Colors.white),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageWidget(_currentEditedFile),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'AI Result',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(File file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
      );
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
    );
  }

  Widget _buildAiSummaryCard() {
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
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Enhanced',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _currentResult.provider.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Improved lighting, rich color tones and soft fur details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Prompt Used Quote Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.format_quote,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Prompt Used',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _editPrompt,
                      child: const Row(
                        children: [
                          Icon(Icons.edit,
                              size: 12, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text(
                            'Edit Prompt',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  child: Text(
                    '"$_currentPrompt"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action: Use This Photo
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _useThisPhoto,
            icon: const Icon(Icons.check_circle,
                size: 20, color: Colors.white),
            label: const Text(
              'Use This Photo',
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
        const SizedBox(height: 10),

        // Secondary Actions Row: Try Again & Edit Prompt
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: _isRegenerating ? null : _handleTryAgain,
                  icon: const Icon(Icons.replay,
                      size: 16, color: Color(0xFF4B5563)),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _editPrompt,
                  icon: const Icon(Icons.edit_note,
                      size: 16, color: AppColors.primary),
                  label: const Text(
                    'Edit Prompt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC2410C),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF7ED),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFED7AA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
