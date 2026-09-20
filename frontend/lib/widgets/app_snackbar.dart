import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppSnackBarType { info, success, error }

/// Themed floating snackbars matching InstaCat brand.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      build(
        message,
        type: type,
        duration: duration,
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: AppSnackBarType.info);

  static SnackBar build(
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final Color bg;
    final IconData icon;
    switch (type) {
      case AppSnackBarType.success:
        bg = AppColors.primary;
        icon = Icons.check_circle_outline;
      case AppSnackBarType.error:
        bg = AppColors.error;
        icon = Icons.error_outline;
      case AppSnackBarType.info:
        bg = AppColors.textPrimary;
        icon = Icons.info_outline;
    }

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
      action: action,
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmBold.copyWith(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
