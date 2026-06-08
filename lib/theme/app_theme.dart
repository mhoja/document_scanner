import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF003E7E);
  static const Color secondary = Color(0xFF00A4FF);
  static const Color background = Color(0xFFF4F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDCE3EE);
  static const Color textHigh = Color(0xFF101828);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLow = Color(0xFF64748B);
  static const Color danger = Color(0xFFEB5757);
  static const Color success = Color(0xFF027A48);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(fontSize: 18.0, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayMedium: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.w700, color: AppColors.textHigh),
        headlineSmall: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: AppColors.textHigh),
        titleLarge: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, color: AppColors.textHigh),
        titleMedium: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.textMedium),
        bodyLarge: const TextStyle(fontSize: 14.0, color: AppColors.textHigh),
        bodyMedium: const TextStyle(fontSize: 14.0, color: AppColors.textMedium),
        labelLarge: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textLow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F1F1),
        selectedColor: const Color(0xFFFFF3D6),
        labelStyle: const TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: AppColors.textHigh),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF8E96A9),
      ),
    );
  }
}
