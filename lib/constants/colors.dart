import 'package:flutter/material.dart';

class AppColors {
  // Colors from the design
  static const Color background = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF9381FF); // Splash screen purple
  static const Color accent = Color(0xFF06D6A0); // Quote screen green
  static const Color liked = Color(0xFFEF476F); // Liked quotes header pink

  // Quote card colors - making these brighter for background use
  static const Color quoteYellow = Color(0xFFFFD166);
  static const Color quoteGreen = Color(0xFF06D6A0);
  static const Color quoteBlue = Color(0xFF118AB2);
  static const Color quotePurple = Color(0xFF9381FF);

  // Text colors
  static const Color textDark = Color(0xFF333333);
  static const Color textMedium = Color(0xFF666666);
  static const Color white = Colors.white;

  // Quote card colors list for cycling through colors
  static List<Color> quoteCardColors = [
    quoteGreen,
    quoteBlue,
    quoteYellow,
    quotePurple,
  ];
}
