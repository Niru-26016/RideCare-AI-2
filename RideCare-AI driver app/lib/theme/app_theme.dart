import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Base
  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Brand
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoDark = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFF818CF8);

  // Status
  static const Color emerald = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color amber = Color(0xFFFBBF24);
  static const Color amberDark = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color roseDark = Color(0xFFE11D48);

  // Gradients
  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.indigo,
      secondary: AppColors.indigoLight,
      surface: AppColors.surface,
      error: AppColors.rose,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.indigo, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}
