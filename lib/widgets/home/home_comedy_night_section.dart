import 'package:flutter/material.dart';
import '../../constant/appTheme.dart';
import '../../view/home/comedy_night_screen.dart';

class HomeComedyNightSection extends StatelessWidget {
  final bool isDark;

  const HomeComedyNightSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ComedyNightScreen.routeName);
        },
        child: Container(
          width: double.infinity,
          height: 215,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF0F172A)]
                  : [const Color(0xFFE8F1FC), const Color(0xFFF7FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppTheme.primaryBlue.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.35)
                    : AppTheme.primaryBlue.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Ambient Glowing Circle Backdrop (Right Side)
              Positioned(
                right: -10,
                top: 20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentBlue.withOpacity(isDark ? 0.35 : 0.20),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Watermark Icon
              Positioned(
                right: 12,
                bottom: 12,
                child: Icon(
                  Icons.theater_comedy_rounded,
                  size: 135,
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : AppTheme.primaryBlue.withOpacity(0.05),
                ),
              ),

              // Title & Subtitle (Top Left)
              Positioned(
                left: 22,
                top: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SPECIAL NIGHT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                            fontFamily: AppTheme.fontGeneralSans,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comedy Night',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: AppTheme.fontUnivers,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '29th Aug 2026 • Main Auditorium',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontFamily: AppTheme.fontGeneralSans,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Button (Bottom Left)
              Positioned(
                left: 22,
                bottom: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Pass',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: AppTheme.fontGeneralSans,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),

              // Right Highlight Badge Graphic
              Positioned(
                right: 22,
                top: 36,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.darkCardsBg
                        : AppTheme.lightCardsBg,
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.theater_comedy_rounded,
                      color: isDark ? AppTheme.accentBlue : AppTheme.primaryBlue,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
