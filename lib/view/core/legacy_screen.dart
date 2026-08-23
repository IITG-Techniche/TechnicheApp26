import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../team/heads_team_screen.dart';
import 'legacy_detail_screen.dart';

class LegacyScreen extends StatelessWidget {
  static const String routeName = '/legacy';
  const LegacyScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.90).clamp(300.0, 420.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar with ABOUT US Title & Optional Back Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      'ABOUT US',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUnivers,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // 1. MEET THE TEAM FOLDER CARD (meettheteamdark.png for both Dark & Bright)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HeadsTeamScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: cardWidth,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/hero/meetheads/meettheteam.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/hero/meetheads/meettheteam.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. LEGACY FOLDER CARD (legacyindark.png for both Dark & Bright)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LegacyDetailScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: cardWidth,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/hero/meetheads/legacyindark.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'LEGACY',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. OUR SOCIALS GRAPHIC (Dark & Bright aware) & INTERACTIVE BUTTONS
                    Center(
                      child: SizedBox(
                        width: cardWidth,
                        child: Column(
                          children: [
                            // Graphic Logo
                            Image.asset(
                              isDark
                                  ? 'assets/hero/meetheads/logodark.png'
                                  : 'assets/hero/meetheads/logoinbright.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/hero/meetheads/logodark.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Interactive Social Action Bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black26
                                        : Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSocialIconButton(
                                    icon: Icons.camera_alt_outlined,
                                    tooltip: 'Instagram',
                                    color: const Color(0xFFE1306C),
                                    onTap: () => _launchUrl(
                                        'https://www.instagram.com/techniche.iitg/'),
                                  ),
                                  _buildSocialIconButton(
                                    icon: Icons.link_rounded,
                                    tooltip: 'LinkedIn',
                                    color: const Color(0xFF0A66C2),
                                    onTap: () => _launchUrl(
                                        'https://www.linkedin.com/company/techniche-iitg/'),
                                  ),
                                  _buildSocialIconButton(
                                    icon: Icons.alternate_email_rounded,
                                    tooltip: 'X (Twitter)',
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    onTap: () => _launchUrl(
                                        'https://x.com/techniche_iitg'),
                                  ),
                                  _buildSocialIconButton(
                                    icon: Icons.play_arrow_rounded,
                                    tooltip: 'YouTube',
                                    color: const Color(0xFFFF0000),
                                    onTap: () => _launchUrl(
                                        'https://www.youtube.com/@technicheiitg'),
                                  ),
                                  _buildSocialIconButton(
                                    icon: Icons.facebook_rounded,
                                    tooltip: 'Facebook',
                                    color: const Color(0xFF1877F2),
                                    onTap: () => _launchUrl(
                                        'https://www.facebook.com/techniche.iitg/'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}