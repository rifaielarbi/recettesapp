import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF2BB673);
  static const Color orange = Color(0xFFFF7A00);
  static const Color textDark = Color(0xFF2C3A3C);
  static const Color card = Color(0xFFF7F7F7);

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

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.green,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        margin: const EdgeInsets.all(8),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black87,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.green.withOpacity(0.2),
        backgroundColor: Colors.grey.shade100,
        labelStyle: const TextStyle(color: Colors.black87),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.dark,
        surface: const Color(0xFF16181D),
        background: const Color(0xFF0F1115),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      cardColor: const Color(0xFF16181D),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF16181D),
        selectedItemColor: AppColors.green,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16181D),
        surfaceTintColor: const Color(0xFF16181D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        margin: const EdgeInsets.all(8),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white70,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2126),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: const ChipThemeData(
        selectedColor: Color(0x402BB673),
        backgroundColor: Color(0xFF1E2126),
        labelStyle: TextStyle(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2D34)),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
