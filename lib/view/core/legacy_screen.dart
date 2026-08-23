import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      HapticFeedback.lightImpact();
    } catch (_) {}

    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        debugPrint('Failed to open URL $urlString: $e');
      }
    }
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
                    // 1. MEET THE TEAM FOLDER CARD
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
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'MEET THE TEAM',
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

                    const SizedBox(height: 12),

                    // 2. LEGACY FOLDER CARD
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

                    const SizedBox(height: 16),

                    // 3. OUR SOCIALS INTERACTIVE GRAPHIC WITH DIRECT TAP TARGETS
                    Center(
                      child: SizedBox(
                        width: cardWidth,
                        child: _buildInteractiveSocialsGraphic(context, isDark, cardWidth),
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

  Widget _buildInteractiveSocialsGraphic(BuildContext context, bool isDark, double width) {
    final height = width * (372 / 355);
    final buttonSize = width * 0.17; // Generous tap target

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Socials Vector / Image Graphic
          SvgPicture.asset(
            isDark
                ? 'assets/hero/meetheads/socialsindark.svg'
                : 'assets/hero/meetheads/socialinbright.svg',
            width: width,
            height: height,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Image.asset(
              isDark
                  ? 'assets/hero/meetheads/logodark.png'
                  : 'assets/hero/meetheads/logoinbright.png',
              width: width,
              height: height,
              fit: BoxFit.contain,
            ),
          ),

          // 2. Clickable Hotspots overlay directly placed on the 5 icons:
          // [1] Instagram (Left)
          Positioned(
            left: width * 0.10,
            top: height * 0.44,
            width: buttonSize,
            height: buttonSize,
            child: Tooltip(
              message: 'Instagram',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: const Color(0xFFE1306C).withOpacity(0.4),
                  highlightColor: const Color(0xFFE1306C).withOpacity(0.2),
                  onTap: () => _launchUrl('https://www.instagram.com/techniche.iitg/'),
                ),
              ),
            ),
          ),

          // [2] LinkedIn (Bottom-Left)
          Positioned(
            left: width * 0.20,
            top: height * 0.63,
            width: buttonSize,
            height: buttonSize,
            child: Tooltip(
              message: 'LinkedIn',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: const Color(0xFF0A66C2).withOpacity(0.4),
                  highlightColor: const Color(0xFF0A66C2).withOpacity(0.2),
                  onTap: () => _launchUrl('https://www.linkedin.com/company/techniche-iitg/'),
                ),
              ),
            ),
          ),

          // [3] X / Twitter (Bottom-Center)
          Positioned(
            left: width * 0.415,
            top: height * 0.69,
            width: buttonSize,
            height: buttonSize,
            child: Tooltip(
              message: 'X (Twitter)',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withOpacity(0.4),
                  highlightColor: Colors.white.withOpacity(0.2),
                  onTap: () => _launchUrl('https://x.com/techniche_iitg'),
                ),
              ),
            ),
          ),

          // [4] YouTube (Bottom-Right)
          Positioned(
            left: width * 0.63,
            top: height * 0.63,
            width: buttonSize,
            height: buttonSize,
            child: Tooltip(
              message: 'YouTube',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: const Color(0xFFFF0000).withOpacity(0.4),
                  highlightColor: const Color(0xFFFF0000).withOpacity(0.2),
                  onTap: () => _launchUrl('https://www.youtube.com/@technicheiitg'),
                ),
              ),
            ),
          ),

          // [5] Facebook (Right)
          Positioned(
            left: width * 0.73,
            top: height * 0.44,
            width: buttonSize,
            height: buttonSize,
            child: Tooltip(
              message: 'Facebook',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: const Color(0xFF1877F2).withOpacity(0.4),
                  highlightColor: const Color(0xFF1877F2).withOpacity(0.2),
                  onTap: () => _launchUrl('https://www.facebook.com/techniche.iitg/'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}