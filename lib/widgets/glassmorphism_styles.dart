import 'dart:ui';
import 'package:flutter/material.dart';

/// Centralized glassmorphism styling utilities for the Techniche app
class GlassmorphismStyles {
  // Color Palette
  static const Color backgroundGradientStart = Color(0xFF1a0533); // Deep purple
  static const Color backgroundGradientEnd = Color(0xFF0d1b2a); // Dark blue
  static const Color accentCyan = Color(0xFF00F5FF);
  static const Color accentPink = Color(0xFFFF00FF);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Card colors
  static Color cardBackground = Colors.white.withOpacity(0.1);
  static Color cardBorder = Colors.white.withOpacity(0.2);

  // Animation constants
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration tabTransitionDuration = Duration(milliseconds: 250);
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Background gradient for the entire screen
  static BoxDecoration get screenBackground => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundGradientStart,
            backgroundGradientEnd,
          ],
        ),
      );

  /// Glassmorphism card decoration
  static BoxDecoration glassCardDecoration({
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? cardBorder,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Gradient overlay for cards with images
  static BoxDecoration imageOverlayGradient({
    double borderRadius = 16,
    List<Color>? colors,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors ??
            [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.8),
            ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  /// Neon glow effect for accents
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.5}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity * 0.6),
        blurRadius: 12,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withOpacity(intensity * 0.3),
        blurRadius: 24,
        spreadRadius: 4,
      ),
    ];
  }

  /// Tab indicator decoration
  static BoxDecoration tabIndicatorDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [accentCyan, accentPurple],
      ),
      boxShadow: neonGlow(accentCyan, intensity: 0.4),
    );
  }

  /// Coming soon pulse decoration
  static BoxDecoration comingSoonDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: accentPurple.withOpacity(0.5),
        width: 1.5,
      ),
    );
  }
}

/// Glassmorphism blur wrapper widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.borderRadius = 16,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: GlassmorphismStyles.glassCardDecoration(
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
