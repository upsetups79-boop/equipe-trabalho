import 'package:flutter/material.dart';

class AppStyles {
  static const Map<String, Color> shiftColors = {
    'Manhã': Colors.blue,
    'Noite': Colors.indigo,
  };

  static const Map<String, IconData> shiftIcons = {
    'Manhã': Icons.wb_sunny,
    'Noite': Icons.nights_stay,
  };

  static Color getShiftColor(String shift) {
    return shiftColors[shift] ?? Colors.grey;
  }

  static IconData getShiftIcon(String shift) {
    return shiftIcons[shift] ?? Icons.access_time;
  }

  static Color getColorFromHex(String hexColor) {
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
