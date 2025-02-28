import 'dart:math';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // List of background colors
  final List<Color> _colors = [
    const Color(0xFFFFD166), // Yellow
    const Color(0xFF06D6A0), // Green
    const Color(0xFF118AB2), // Blue
    const Color(0xFFEF476F), // Pink
    const Color(0xFF9381FF), // Purple
    const Color(0xFFF8961E), // Orange
    const Color(0xFF70C1B3), // Teal
    const Color(0xFFB5838D), // Mauve
    const Color(0xFFE9C46A), // Gold
    const Color(0xFF84A59D), // Sage
  ];

  int _colorIndex = 0;
  Color get currentColor => _colors[_colorIndex];

  // Get a new random color different from the current one
  void changeColor() {
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(_colors.length);
    } while (newIndex == _colorIndex && _colors.length > 1);

    _colorIndex = newIndex;
    notifyListeners();
  }

  // Get a specific color by index
  Color getColorByIndex(int index) {
    return _colors[index % _colors.length];
  }

  // Get the list of all available colors
  List<Color> get allColors => _colors;
}
