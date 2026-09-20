import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Warm Chromatic Accents
  static const Color primary = Color(0xFFF97316); // Vibrant brand orange
  static const Color primaryDark = Color(0xFFC2410C); // Pressed / deep burnt orange
  static const Color primaryLight = Color(0xFFFFDBCA);
  static const Color secondary = Color(0xFFFDBA74); // Soft peach accent
  static const Color tertiary = Color(0xFFAC3400);

  // Surfaces & Canvas
  static const Color surfaceCanvas = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFAFAFA);
  static const Color surfaceTertiary = Color(0xFFF4F4F5);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);

  // Borders & Dividers (Hairline 0.5px - 1px)
  static const Color borderSubtle = Color(0xFFE4E4E7);
  static const Color borderMuted = Color(0xFFDBDBDB);

  // Typography / Neutral Colors
  static const Color textPrimary = Color(0xFF262626); // Authentic softened off-black
  static const Color textSecondary = Color(0xFF737373); // Muted secondary text
  static const Color textPlaceholder = Color(0xFFA1A1AA);

  // Story Rings & Gradients
  static const Color storyGradientStart = Color(0xFFF97316);
  static const Color storyGradientEnd = Color(0xFFFBBF24);

  // Interactive Accents
  static const Color interactiveLike = Color(0xFFEF4444); // Heart like red
  static const Color error = Color(0xFFEF4444); // Error alert red
  static const Color linkBlue = Color(0xFF1877F2); // Social / facebook link
  static const Color verifiedBadge = Color(0xFFF97316); // Brand verified badge

  // Story Gradient Decoration
  static const LinearGradient storyGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [storyGradientStart, storyGradientEnd],
  );

  static const LinearGradient storyGradient45 = LinearGradient(
    begin: Alignment(-0.7, -0.7),
    end: Alignment(0.7, 0.7),
    colors: [storyGradientStart, storyGradientEnd],
  );
}
