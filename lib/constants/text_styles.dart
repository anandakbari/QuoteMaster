import 'package:flutter/material.dart';
import 'package:quote_master/constants/colors.dart';

class AppTextStyles {
  // App title styles
  static const TextStyle appTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle splashTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 16,
    color: Color(0xB3FFFFFF), // White with 70% opacity
  );

  // Quote styles
  static const TextStyle quoteText = TextStyle(
    fontSize: 12,
    color: AppColors.textDark,
  );

  static const TextStyle quoteAuthor = TextStyle(
    fontSize: 11,
    fontStyle: FontStyle.italic,
    color: AppColors.textMedium,
  );

  // Button text styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  // Loading text style
  static const TextStyle loadingText = TextStyle(
    fontSize: 14,
    color: Color(0xCCFFFFFF), // White with 80% opacity
  );

  // Header text style
  static const TextStyle headerText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
