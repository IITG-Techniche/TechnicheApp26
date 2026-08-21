import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/constant/appTheme.dart';
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
        userInitial = userState.name.trim()[0].toUpperCase();
      } else if (userState.email.trim().isNotEmpty) {
        userInitial = userState.email.trim()[0].toUpperCase();
      } else {
        userInitial = 'U';
      }
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 430,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF090E25) : const Color(0xFFE4F0FF),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  isDark ? 'assets/hero/hero.png' : 'assets/hero/heroLight.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/hero.png',
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
                              const Color(0xFF070B19).withOpacity(0.45),
                              const Color(0xFF070B19).withOpacity(0.25),
                              const Color(0xFF070B19).withOpacity(0.75),
                            ]
                          : [
                              Colors.white.withOpacity(0.20),
                              Colors.transparent,
                              Colors.white.withOpacity(0.20),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Circle Initial / Guest Icon
                    Builder(builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isLoggedIn
                              ? Text(
                                  userInitial,
                                  style: const TextStyle(
                                    color: Color(0xFF202127),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF202127),
                                  size: 22,
                                ),
                        ),
                      );
                    }),
                    // Icons
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            color: isDark ? Colors.white : const Color(0xFF10152B),
                            size: 24,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/merch'),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          icon: Icon(
                            Icons.help_outline_rounded,
                            color: isDark ? Colors.white : const Color(0xFF10152B),
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, HelpCenterScreen.routeName);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Image.asset(
                  isDark
                      ? 'assets/hero/heroLogo.png'
                      : 'assets/hero/heroLogoLight.png',
                  width: screenWidth * .80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  isDark
                      ? 'assets/hero/heroText.png'
                      : 'assets/hero/heroTextLight.png',
                  width: screenWidth * .68,
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
                          foreground:
                              isDark ? const Color(0xFF08165D) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Transform.rotate(
                        angle: .025,
                        child: _buildHeroLabel(
                          text: 'Annual Techno-Management Festival',
                          background: isDark
                              ? const Color(0xFF2B53B4)
                              : const Color(0xFFF2F6FF),
                          foreground:
                              isDark ? Colors.white : const Color(0xFF08165D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Transform.rotate(
                        angle: .005,
                        child: _buildHeroLabel(
                          text: '28th to 30th August 2026',
                          background: isDark
                              ? const Color(0xFFD4E6FC)
                              : const Color(0xFF294C9A),
                          foreground:
                              isDark ? const Color(0xFF08165D) : Colors.white,
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
    );
  }
}

