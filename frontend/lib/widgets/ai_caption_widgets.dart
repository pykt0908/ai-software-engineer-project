import 'dart:io';

import 'package:flutter/material.dart';

import '../services/ai_caption_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet: pick style → generate → choose a caption (or regenerate).
Future<String?> showAiCaptionSuggestionSheet(
  BuildContext context, {
  required File imageFile,
  CaptionStyle initialStyle = CaptionStyle.cute,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _AiCaptionSuggestionSheet(
      imageFile: imageFile,
      initialStyle: initialStyle,
    ),
  );
}

class AiCaptionGenerateButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  const AiCaptionGenerateButton({
    super.key,
    required this.enabled,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !loading && onPressed != null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canTap ? onPressed : null,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          loading ? 'กำลังสร้าง...' : '✨ Generate with AI',
          style: AppTypography.bodyBold.copyWith(
            color: canTap ? AppColors.primary : AppColors.textPlaceholder,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: canTap ? AppColors.primary : AppColors.borderSubtle,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class CaptionStyleSelector extends StatelessWidget {
  final CaptionStyle selected;
  final ValueChanged<CaptionStyle> onChanged;
  final bool enabled;

  const CaptionStyleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: CaptionStyle.values.map((style) {
        final active = style == selected;
        return GestureDetector(
          onTap: enabled ? () => onChanged(style) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surfaceTertiary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.borderSubtle,
              ),
            ),
            child: Text(
              style.labelTh,
              style: AppTypography.bodySm.copyWith(
                color: active ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AiCaptionSuggestionSheet extends StatefulWidget {
  final File imageFile;
  final CaptionStyle initialStyle;

  const _AiCaptionSuggestionSheet({
    required this.imageFile,
    required this.initialStyle,
  });

  @override
  State<_AiCaptionSuggestionSheet> createState() =>
      _AiCaptionSuggestionSheetState();
}

class _AiCaptionSuggestionSheetState extends State<_AiCaptionSuggestionSheet> {
  late CaptionStyle _style;
  List<String> _captions = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _style = widget.initialStyle;
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final captions = await AiCaptionService().generate(
        imageFile: widget.imageFile,
        style: _style,
      );
      if (!mounted) return;
      setState(() {
        _captions = captions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'AI Caption',
            style: AppTypography.bodyBold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'เลือกสไตล์แล้วเลือก caption ที่ชอบ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          CaptionStyleSelector(
            selected: _style,
            enabled: !_loading,
            onChanged: (style) {
              setState(() => _style = style);
              _generate();
            },
          ),
          const SizedBox(height: 16),
          if (_loading) ...[
            _buildShimmer(),
            const SizedBox(height: 8),
            _buildShimmer(),
            const SizedBox(height: 8),
            _buildShimmer(),
          ] else if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceTertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error!,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _generate,
                    child: Text(
                      'ลองใหม่',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ..._captions.map((caption) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.surfaceTertiary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(caption),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              caption,
                              style: AppTypography.bodyRegular,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loading ? null : _generate,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  'สุ่มใหม่',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
