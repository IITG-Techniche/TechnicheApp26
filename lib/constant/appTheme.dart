import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00FFF7); // Neon Cyan
  static const Color secondaryColor = Color(0xFFFF00F7); // Neon Magenta
  static const Color scaffoldBackgroundColor = Color(0xFF18122B); // Deep Purple
  static const Color surfaceColor = Color(0xFF232946); // Dark Blue
  static const Color errorColor = Color(0xFFFF1744);

  // Specific UI Colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color cardColor = Color(0xFF23242B);
  static const Color textColorSecondary = Color(0xFFB8C1EC);

  // Font
  static const String fontFamily = 'Orbitron';

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.black,
        secondary: primaryColor,
        onSecondary: Colors.black,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 8,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: primaryColor,
          shadows: [
            Shadow(blurRadius: 7.5, color: primaryColor, offset: Offset(0, 0)),
          ],
        ),
        iconTheme: IconThemeData(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: scaffoldBackgroundColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(primaryColor),
          foregroundColor: WidgetStateProperty.all(scaffoldBackgroundColor),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: primaryColor, width: 2),
          )),
          shadowColor: WidgetStateProperty.all(primaryColor),
          elevation: WidgetStateProperty.all(12),
          textStyle: WidgetStateProperty.all(const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2,
            shadows: [
              Shadow(blurRadius: 5, color: primaryColor, offset: Offset(0, 0)),
            ],
          )),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: primaryColor,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 6, color: primaryColor, offset: Offset(0, 0)),
          ],
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: primaryColor,
          shadows: [
            Shadow(blurRadius: 9, color: primaryColor, offset: Offset(0, 0)),
          ],
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          color: primaryColor,
          shadows: [
            Shadow(blurRadius: 6, color: primaryColor, offset: Offset(0, 0)),
          ],
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          color: textColorSecondary,
        ),
      ),
    );
  }
}
