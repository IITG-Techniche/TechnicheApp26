import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../model/team_data.dart';

class HeadsTeamScreen extends StatelessWidget {
  static const String routeName = '/heads-team';
  final List<HeadMember> heads;

  const HeadsTeamScreen({
    super.key,
    this.heads = kFestHeads,
  });

  Future<void> _launchLinkedIn(BuildContext context, String urlString) async {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.86).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content (Header Graphic + Cards)
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Space & Header Artwork: mainheads.png
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Header Artwork: mainheads.png
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Center(
                          child: SizedBox(
                            width: (screenWidth * 0.76).clamp(240.0, 320.0),
                            child: Image.asset(
                              'assets/hero/meetheads/mainheads.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'MEET THE TEAM',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Vertical List of Figma-Style Head Cards
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 4.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final head = heads[index];
                        return Center(
                          child: Container(
                            width: cardWidth,
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0F24),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.55),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.16),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Team / Module Name at Top
                                Text(
                                  head.teamName.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // 2. Avatar with Radial Glow Aura
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF6366F1).withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF60A5FA).withOpacity(0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: head.imageUrl.startsWith('http')
                                            ? Image.network(
                                                head.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: const Color(0xFF1E293B),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Color(0xFF6D7985),
                                                  ),
                                                ),
                                              )
                                            : Image.asset(
                                                head.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: const Color(0xFF1E293B),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Color(0xFF6D7985),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // 3. Head Name in Bold Block Lettering
                                Text(
                                  head.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // 4. Pill Button 1: Role / Designation
                                Container(
                                  width: double.infinity,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF2563EB).withOpacity(0.35),
                                        const Color(0xFF1E3A8A).withOpacity(0.55),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withOpacity(0.55),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      head.designation.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontGeneralSans,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF93C5FD),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // 5. Pill Button 2: Explore / LinkedIn
                                GestureDetector(
                                  onTap: () => _launchLinkedIn(context, head.linkedinUrl),
                                  child: Container(
                                    width: double.infinity,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF3B82F6).withOpacity(0.5),
                                          const Color(0xFF1D4ED8).withOpacity(0.7),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF60A5FA).withOpacity(0.6),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'EXPLORE',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontGeneralSans,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: heads.length,
                    ),
                  ),
                ),
              ],
            ),

            // Top-Left Elevated Corner Back Button (No Appbar text)
            Positioned(
              top: 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
