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
    final cardWidth = (screenWidth * 0.90).clamp(320.0, 480.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar with ABOUT US Title & Optional Back Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(44, 16, 24, 8),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.12)
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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
                        behavior: HitTestBehavior.opaque,
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
                          child: SvgPicture.asset(
                            'assets/hero/meetheads/mainhead.svg',
                            width: cardWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. LEGACY FOLDER CARD
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
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
                          child: SvgPicture.asset(
                            'assets/hero/meetheads/legacy.svg',
                            width: cardWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. OUR SOCIALS INTERACTIVE GRAPHIC BUILT WITH SPECIFIED ASSETS
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
    final height = width * 1.0;
    final iconSize = width * 0.13;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Central Social Background Image
          Image.asset(
            isDark ? 'assets/socialdark.png' : 'assets/socialbright.png',
            width: width * 0.52,
            fit: BoxFit.contain,
          ),

          // 2. OUR SOCIALS Title Header Asset (OUR SOCIALS.png) - Top Center
          Positioned(
            top: height * 0.12,
            child: Image.asset(
              'assets/OUR SOCIALS.png',
              width: width * 0.65,
              fit: BoxFit.contain,
            ),
          ),

          // 3. Five Social Buttons in a Circle around the central image:
          // [1] X / Twitter (Far Left)
          Positioned(
            left: width * 0.08,
            top: height * 0.44,
            child: _buildSocialAssetButton(
              size: iconSize,
              assetPath: 'assets/x.png',
              fallbackIcon: Icons.close_rounded,
              url: 'https://x.com/techniche_iitg',
            ),
          ),

          // [2] LinkedIn (Bottom Left)
          Positioned(
            left: width * 0.20,
            top: height * 0.70,
            child: _buildSocialAssetButton(
              size: iconSize,
              assetPath: 'assets/linkdin.png',
              fallbackIcon: Icons.business_center_rounded,
              url: 'https://www.linkedin.com/company/techniche-iitg/',
            ),
          ),

          // [3] Instagram (Bottom Center)
          Positioned(
            top: height * 0.82,
            child: _buildSocialAssetButton(
              size: iconSize,
              assetPath: 'assets/instagram.png',
              fallbackIcon: Icons.camera_alt_rounded,
              url: 'https://www.instagram.com/techniche.iitg/',
            ),
          ),

          // [4] YouTube (Bottom Right)
          Positioned(
            right: width * 0.20,
            top: height * 0.70,
            child: _buildSocialAssetButton(
              size: iconSize,
              assetPath: 'assets/youtube.png',
              fallbackIcon: Icons.play_arrow_rounded,
              url: 'https://www.youtube.com/@technicheiitg',
            ),
          ),

          // [5] Facebook (Far Right)
          Positioned(
            right: width * 0.08,
            top: height * 0.44,
            child: _buildSocialAssetButton(
              size: iconSize,
              assetPath: 'assets/facebook.png',
              fallbackIcon: Icons.facebook_rounded,
              url: 'https://www.facebook.com/techniche.iitg/',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAssetButton({
    required double size,
    required String assetPath,
    required IconData fallbackIcon,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Icon(
                fallbackIcon,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
