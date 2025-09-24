import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF2BB673);
  static const Color orange = Color(0xFFFF7A00);
  static const Color textDark = Color(0xFF2C3A3C);
  static const Color card = Color(0xFFF7F7F7);
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String pasta = 'assets/images/pasta.png';
  static const String tacos = 'assets/images/tacos.png';
  static const String soup = 'assets/images/soup.png';
}

class AppTextStyles {
  static const TextStyle titleXL = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}