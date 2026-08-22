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
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
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
      color: isDark ? const Color(0xFF090E25) : Colors.white,
      child: Center(
        child: SizedBox(
          width: screenWidth > 368 ? 368 : screenWidth,
          height: 337,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Hero Background Image (368 x 337)
              Positioned.fill(
                child: Image.asset(
                  isDark ? 'assets/hero/hero.png' : 'assets/hero/heroLight.png',
                  width: 368,
                  height: 337,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/hero.png',
                    width: 368,
                    height: 337,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Lighting overlay tuned per theme
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
                              Colors.white.withOpacity(0.45),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Foreground Top Bar & Hero Branding
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Action Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile Circle Initial (Size: 36 x 36)
                          Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                width: 36,
                                height: 36,
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
                                  style: const TextStyle(
                                    color: Color(0xFF202127),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'General Sans',
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Actions: Shop (48x48), Help (48x48), Notification (48x48)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Shop Button (48 x 48)
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF10152B),
                                    size: 24,
                                  ),
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/merch'),
                                ),
                              ),
                              // Help Button (48 x 48)
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.help_outline_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF10152B),
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, HelpCenterScreen.routeName);
                                  },
                                ),
                              ),
                              // Notification Bell Button (48 x 48)
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.notifications_none_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF10152B),
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Techniche Hero Logo
                      Image.asset(
                        isDark
                            ? 'assets/hero/heroLogo.png'
                            : 'assets/hero/heroLogoLight.png',
                        width: (screenWidth * .75).clamp(240.0, 310.0),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // Hero Taglines
                      Image.asset(
                        isDark
                            ? 'assets/hero/heroText.png'
                            : 'assets/hero/heroTextLight.png',
                        width: (screenWidth * .65).clamp(200.0, 260.0),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Column(
                          children: [
                            Transform.rotate(
                              angle: -.05,
                              child: _buildHeroLabel(
                                text: "IIT Guwahati’s",
                                background: isDark
                                    ? const Color(0xFFD4E6FC)
                                    : const Color(0xFF3F5EBC),
                                foreground: isDark
                                    ? const Color(0xFF08165D)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Transform.rotate(
                              angle: .025,
                              child: _buildHeroLabel(
                                text: 'Annual Techno-Management Festival',
                                background: isDark
                                    ? const Color(0xFF2B53B4)
                                    : const Color(0xFFF2F6FF),
                                foreground: isDark
                                    ? Colors.white
                                    : const Color(0xFF08165D),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Transform.rotate(
                              angle: .005,
                              child: _buildHeroLabel(
                                text: '28th to 30th August 2026',
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
        ),
      ),
    );
  }
}
