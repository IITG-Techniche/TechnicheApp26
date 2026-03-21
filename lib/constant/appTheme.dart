import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Colors ───────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF002B5B);
  static const Color accentBlue = Color(0xFF175BCC);
  static const Color backgroundGray = Color(0xFFF5F5F5); 
  static const Color textMain = Color(0XFF232930);
  static const Color textSecondary = Color(0xFF6D7985);
  static const Color textMuted = Color(0xFFAFAFAF);

  // Still keeping the old neon colors
  static const Color neonCyan = Color(0xFF00FFF7);
  static const Color neonMagenta = Color(0xFFFF00F7);
  static const Color darkBackground = Color(0xFF18122B);

  // ── Legacy Getters for Backward Compatibility ────────────────
  static const Color primaryColor = primaryBlue;
  static const Color secondaryColor = accentBlue;
  static const Color scaffoldBackgroundColor = backgroundGray;
  static const String fontFamily = 'General Sans'; // Default for the app now

  // ── Font Families ──────────────────────────────────────────
  static const String fontUnivers = 'Univers';
  static const String fontGeneralSans = 'General Sans';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGray,
      fontFamily: fontGeneralSans, // Default font for body
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: Colors.white,
        onSurface: textMain,
        background: backgroundGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textMain),
        titleTextStyle: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: textMain,
          height: 1.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          color: textMain,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textMain,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: textMain,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 16,
          color: textMain,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 14,
          color: textMain,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textMain,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontGeneralSans,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontGeneralSans,
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme; 
}
