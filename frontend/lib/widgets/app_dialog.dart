import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared InstaCat-styled confirmation / alert dialog.
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;
  final bool isConfirmLoading;
  final bool barrierDismissible;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.iconColor,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.onCancel,
    this.onConfirm,
    this.isDestructive = false,
    this.isConfirmLoading = false,
    this.barrierDismissible = true,
  });

  /// Shows a themed confirm dialog. Returns `true` if confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor ??
            (isDestructive ? AppColors.error : AppColors.primary),
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    return result == true;
  }

  static Future<T?> showCustom<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ??
        (isDestructive ? AppColors.error : AppColors.primary);

    return AlertDialog(
      backgroundColor: AppColors.surfaceCanvas,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: content ??
          (message != null
              ? Text(
                  message!,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                )
              : null),
      actions: [
        TextButton(
          onPressed: isConfirmLoading
              ? null
              : (onCancel ?? () => Navigator.pop(context, false)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            cancelLabel,
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isConfirmLoading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                (isDestructive ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.5),
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            minimumSize: const Size(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isConfirmLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  confirmLabel,
                  style: AppTypography.bodyBold.copyWith(color: Colors.white),
                ),
        ),
      ],
    );
  }
}

/// Shared dialog field decoration matching InstaCat forms.
InputDecoration appDialogInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.surfaceTertiary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
    ),
  );
}
