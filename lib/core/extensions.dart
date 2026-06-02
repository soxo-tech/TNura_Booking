import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String get maskedPhoneNumber {
    return "XXXXX-XXX${substring(length - 2, length)}";
  }
}

extension IntExtension on int {
  String formatTime() {
    // 0:00
    return "0:${toString().padLeft(2, '0')}";
  }
}

extension ColorExtension on String? {
  LinearGradient parseGradient() {
    if (this == null || this!.isEmpty) {
      return AppColors.defaultPackageGradient;
    }

    List<Color> colors = [];

    // Extract hex colors like #69C8CF
    final hexRegex = RegExp(r'#([A-Fa-f0-9]{6})');
    final hexMatches = hexRegex.allMatches(this!);
    colors.addAll(
      hexMatches.map(
        (match) => Color(int.parse('0xFF${match.group(1)!.toUpperCase()}')),
      ),
    );

    // Extract rgb or rgba values
    final rgbRegex =
        RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)');
    final rgbMatches = rgbRegex.allMatches(this!);

    for (final match in rgbMatches) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      final a = match.group(4) != null
          ? (double.parse(match.group(4)!) * 255).round()
          : 255;

      colors.add(Color.fromARGB(a, r, g, b));
    }

    if (colors.isEmpty) {
      return AppColors.defaultPackageGradient;
    }

    return LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
