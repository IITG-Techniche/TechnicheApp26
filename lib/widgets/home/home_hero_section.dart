import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/providers/user_provider.dart';
import 'package:techniche26/view/core/help_center_screen.dart';

class HomeHeroSection extends ConsumerWidget {
  final bool isDark;

  const HomeHeroSection({
    super.key,
    required this.isDark,
  });

  Widget _buildHeroLabel({
    required String text,
    required Color background,
    required Color foreground,
    required double fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // Responsive ratios based on standard 390 x 844 design canvas
    final double widthRatio = (screenWidth / 390.0).clamp(0.85, 1.25);
    final double profileSize = 38.0 * widthRatio;
    final double actionButtonSize = 44.0 * widthRatio;
    final double heroHeight = (screenWidth * (337.0 / 368.0)).clamp(300.0, 420.0);

    final userState = ref.watch(userProvider);
    final bool isLoggedIn = userState.isAuthenticated;
    String userInitial = '';
    if (isLoggedIn) {
      if (userState.name.trim().isNotEmpty) {
        final parts = userState.name.trim().split(' ');
        if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          userInitial =
              '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
        } else {
          userInitial = userState.name.trim()[0].toUpperCase();
        }
      } else if (userState.email.trim().isNotEmpty) {
        userInitial = userState.email.trim()[0].toUpperCase();
      } else {
        userInitial = 'AB';
      }
    } else {
      userInitial = 'AB';
    }

    return Container(
      width: double.infinity,
      height: heroHeight,
      color: isDark ? const Color(0xFF090E25) : Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Full-Width Hero Background Image with Decreased Opacity
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.65 : 0.40,
              child: Image.asset(
                isDark ? 'assets/hero/hero.png' : 'assets/hero/heroLight.png',
                width: double.infinity,
                height: heroHeight,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/hero.png',
                  width: double.infinity,
                  height: heroHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Lighting Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF070B19).withOpacity(0.35),
                          const Color(0xFF070B19).withOpacity(0.15),
                          const Color(0xFF070B19).withOpacity(0.75),
                        ]
                      : [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.55),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Foreground Content: Top Action Bar & Branding
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                30.0 * widthRatio,
                20.0 * widthRatio,
                30.0 * widthRatio,
                8.0 * widthRatio,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Button: (38 x 38 ratio)
                      Builder(builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            width: profileSize,
                            height: profileSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userInitial,
                              style: TextStyle(
                                color: const Color(0xFF202127),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0 * widthRatio,
                                fontFamily: 'General Sans',
                              ),
                            ),
                          ),
                        );
                      }),

                      // Right Action Buttons: Shop (44x44) & Help (44x44)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shop Button
                          SizedBox(
                            width: actionButtonSize,
                            height: actionButtonSize,
                            child: IconButton(
                              padding: const EdgeInsets.all(4.0),
                              icon: Icon(
                                Icons.shopping_bag_outlined,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF10152B),
                                size: 24.0 * widthRatio,
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/merch'),
                            ),
                          ),
                          SizedBox(width: 4.0 * widthRatio),
                          // Help Button
                          SizedBox(
                            width: actionButtonSize,
                            height: actionButtonSize,
                            child: IconButton(
                              padding: const EdgeInsets.all(4.0),
                              icon: Icon(
                                Icons.help_outline_rounded,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF10152B),
                                size: 24.0 * widthRatio,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, HelpCenterScreen.routeName);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 18.0 * widthRatio),

                  // Techniche Hero Logo
                  Image.asset(
                    isDark
                        ? 'assets/hero/heroLogo.png'
                        : 'assets/hero/heroLogoLight.png',
                    width: (screenWidth * 0.78).clamp(240.0, 320.0),
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 12.0 * widthRatio),

                  // Hero Taglines
                  Image.asset(
                    isDark
                        ? 'assets/hero/heroText.png'
                        : 'assets/hero/heroTextLight.png',
                    width: (screenWidth * 0.68).clamp(200.0, 270.0),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Column(
                      children: [
                        Transform.rotate(
                          angle: -.05,
                          child: _buildHeroLabel(
                            text: "IIT Guwahati’s",
                            fontSize: 11.0 * widthRatio,
                            background: isDark
                                ? const Color(0xFFD4E6FC)
                                : const Color(0xFF3F5EBC),
                            foreground: isDark
                                ? const Color(0xFF08165D)
                                : Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0 * widthRatio),
                        Transform.rotate(
                          angle: .025,
                          child: _buildHeroLabel(
                            text: 'Annual Techno-Management Festival',
                            fontSize: 11.0 * widthRatio,
                            background: isDark
                                ? const Color(0xFF2B53B4)
                                : const Color(0xFFF2F6FF),
                            foreground: isDark
                                ? Colors.white
                                : const Color(0xFF08165D),
                          ),
                        ),
                        SizedBox(height: 5.0 * widthRatio),
                        Transform.rotate(
                          angle: .005,
                          child: _buildHeroLabel(
                            text: '28th to 30th August 2026',
                            fontSize: 11.0 * widthRatio,
                            background: isDark
                                ? const Color(0xFFD4E6FC)
                                : const Color(0xFF294C9A),
                            foreground: isDark
                                ? const Color(0xFF08165D)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
