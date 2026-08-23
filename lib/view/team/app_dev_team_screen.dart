import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../model/team_data.dart';

class AppDevTeamScreen extends StatelessWidget {
  static const String routeName = '/app-dev-team';
  final List<TeamMember> members;

  const AppDevTeamScreen({
    super.key,
    this.members = kDevTeamMembers,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
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
    final cardWidth = (screenWidth * 0.86).clamp(280.0, 360.0);

    final backgroundColor = isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA);
    final cardBgColor = isDark ? const Color(0xFF0A0F24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3B82F6).withOpacity(0.55) : const Color(0xFF3B82F6);
    final teamTitleColor = isDark ? Colors.white : const Color(0xFF1D4ED8);
    final nameColor = isDark ? Colors.white : const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Center(
                          child: SizedBox(
                            width: (screenWidth * 0.76).clamp(240.0, 320.0),
                            child: Image.asset(
                              isDark
                                  ? 'assets/hero/meetheads/mainheadsdark.png'
                                  : 'assets/hero/meetheads/meettheteaminbright.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'MEET THE DEVELOPERS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
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

                // Vertical List of Figma-Style Developer Cards
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 4.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = members[index];
                        return Center(
                          child: Container(
                            width: cardWidth,
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26.0),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: borderColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0xFF3B82F6).withOpacity(0.16)
                                      : const Color(0xFF3B82F6).withOpacity(0.08),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Team / Department Name at Top
                                Text(
                                  member.teamName.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: teamTitleColor,
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
                                        isDark
                                            ? const Color(0xFF6366F1).withOpacity(0.4)
                                            : const Color(0xFF93C5FD).withOpacity(0.35),
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
                                          color: const Color(0xFF60A5FA).withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: member.imageUrl.startsWith('http')
                                            ? Image.network(
                                                member.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: isDark ? const Color(0xFF6D7985) : Colors.grey.shade600,
                                                  ),
                                                ),
                                              )
                                            : Image.asset(
                                                member.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: isDark ? const Color(0xFF6D7985) : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // 3. Developer Name in Bold Block Lettering
                                Text(
                                  member.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontUnivers,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: nameColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // 4. Pill Button 1: Role
                                Container(
                                  width: double.infinity,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF2563EB).withOpacity(0.35),
                                              const Color(0xFF1E3A8A).withOpacity(0.55),
                                            ]
                                          : [
                                              const Color(0xFFDBEAFE),
                                              const Color(0xFFEFF6FF),
                                            ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF3B82F6).withOpacity(0.55)
                                          : const Color(0xFF93C5FD),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.role.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontGeneralSans,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // 5. Pill Button 2: Explore / LinkedIn
                                GestureDetector(
                                  onTap: () {
                                    if (member.linkedinUrl.isNotEmpty) {
                                      _launchUrl(context, member.linkedinUrl);
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                const Color(0xFF3B82F6).withOpacity(0.5),
                                                const Color(0xFF1D4ED8).withOpacity(0.7),
                                              ]
                                            : [
                                                const Color(0xFFDBEAFE),
                                                const Color(0xFFEFF6FF),
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF60A5FA).withOpacity(0.6)
                                            : const Color(0xFF93C5FD),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.code_rounded,
                                          size: 16,
                                          color: isDark ? Colors.white : const Color(0xFF1D4ED8),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'EXPLORE',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontGeneralSans,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF1D4ED8),
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
                      childCount: members.length,
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
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? Colors.white : Colors.black87,
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
