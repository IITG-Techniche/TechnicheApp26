import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── 2026 Official Color Palettes ─────────────────────────────────

  // Light Mode Palette
  static const Color lightPageBg = Color(0xFFF7F7F7); // rgb(247, 247, 247)
  static const Color lightCardsBg = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color lightChip = Color(0xFFCADEF5); // rgb(202, 223, 245)
  static const Color lightTextPrimary = Color(0xFF191919); // rgb(25, 25, 25)
  static const Color lightTextSecondary = Color(0xFF808080); // rgb(128, 128, 128)

  // Dark Mode Palette
  static const Color darkPageBg = Color(0xFF050510); // rgb(5, 5, 16)
  static const Color darkCardsBg = Color(0xFF1A1A2E); // rgb(26, 26, 46)
  static const Color darkChip = Color(0xFF4C7AAB); // rgb(76, 122, 171)
  static const Color darkTextPrimary = Color(0xFFE8E8F0); // rgb(232, 232, 240)
  static const Color darkTextSecondary = Color(0xFF9090A8); // rgb(144, 144, 168)

  // Brand Accent & Gradients
  static const Color primaryBlue = Color(0xFF4A63BA); // #4A63BA
  static const Color darkBlueAccent = Color(0xFF1A3385); // #1A3385
  static const Color accentBlue = Color(0xFF4C7AAB);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A63BA), Color(0xFF1A3385)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient buttonGradient = primaryGradient;

  // ── Backward Compatibility Constants ────────────────────────────
  static const Color backgroundGray = lightPageBg;
  static const Color textMain = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextSecondary;
  static const Color primaryColor = primaryBlue;
  static const Color secondaryColor = accentBlue;
  static const Color darkBackground = darkPageBg;
  static const Color neonCyan = Color(0xFF00FFF7);
  static const Color neonMagenta = Color(0xFFFF00F7);

  // ── Font Families ──────────────────────────────────────────────
  static const String fontUnivers = 'Univers';
  static const String fontGeneralSans = 'General Sans';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightPageBg,
      cardColor: lightCardsBg,
      fontFamily: fontGeneralSans,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: lightCardsBg,
        onSurface: lightTextPrimary,
        background: lightPageBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardsBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16.0,
        actionsPadding: EdgeInsets.only(right: 8.0),
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: lightTextPrimary,
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
          color: lightTextPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: lightTextPrimary,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: lightTextPrimary,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 16,
          color: lightTextPrimary,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 14,
          color: lightTextPrimary,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: lightTextPrimary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkPageBg,
      cardColor: darkCardsBg,
      fontFamily: fontGeneralSans,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkCardsBg,
        onSurface: darkTextPrimary,
        background: darkPageBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardsBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16.0,
        actionsPadding: EdgeInsets.only(right: 8.0),
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: darkTextPrimary,
          height: 1.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          color: darkTextPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: darkTextPrimary,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontFamily: fontUnivers,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: darkTextPrimary,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 16,
          color: darkTextPrimary,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontGeneralSans,
          fontSize: 14,
          color: darkTextPrimary,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontFamily: fontGeneralSans,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: darkTextPrimary,
        ),
      ),
    );
  }
}
