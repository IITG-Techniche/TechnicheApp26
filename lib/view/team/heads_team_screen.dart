import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../model/team_data.dart';

class HeadsTeamScreen extends StatefulWidget {
  static const String routeName = '/heads-team';
  final List<HeadMember> heads;
  final List<TeamMember> developers;
  final int initialTabIndex;

  const HeadsTeamScreen({
    super.key,
    this.heads = kFestHeads,
    this.developers = kDevTeamMembers,
    this.initialTabIndex = 0,
  });

  @override
  State<HeadsTeamScreen> createState() => _HeadsTeamScreenState();
}

class _HeadsTeamScreenState extends State<HeadsTeamScreen> {
  late int _selectedTab; // 0 = Heads, 1 = Developers

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

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
            // Scrollable Content (Header Graphic + Toggle + Cards)
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Artwork: mainheadsdark.png
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // Tapping the main artwork alternates between Heads and Developers
                          setState(() {
                            _selectedTab = _selectedTab == 0 ? 1 : 0;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
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
                                    'MEET THE TEAM',
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
                      ),

                      const SizedBox(height: 8),

                      // Category Selector Pills: [Heads | App Developers]
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCategoryTab('Heads', 0, isDark),
                              _buildCategoryTab('App Developers', 1, isDark),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Vertical List of Cards (Heads or Developers)
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 4.0),
                  sliver: _selectedTab == 0
                      ? _buildHeadsList(cardWidth, cardBgColor, borderColor, teamTitleColor, nameColor, isDark)
                      : _buildDevelopersList(cardWidth, cardBgColor, borderColor, teamTitleColor, nameColor, isDark),
                ),
              ],
            ),

            // Top-Left Elevated Corner Back Button
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

  Widget _buildCategoryTab(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontGeneralSans,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadsList(
    double cardWidth,
    Color cardBgColor,
    Color borderColor,
    Color teamTitleColor,
    Color nameColor,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final head = widget.heads[index];
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
                  // Team Title
                  Text(
                    head.teamName.toUpperCase(),
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

                  // Avatar with Glow Aura
                  _buildAvatar(head.imageUrl, isDark),

                  const SizedBox(height: 18),

                  // Name
                  Text(
                    head.name.toUpperCase(),
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

                  // Pill 1: Designation
                  _buildRolePill(head.designation.toUpperCase(), isDark),

                  const SizedBox(height: 10),

                  // Pill 2: Explore / LinkedIn
                  _buildExplorePill(
                    label: 'EXPLORE',
                    icon: Icons.link_rounded,
                    isDark: isDark,
                    onTap: () => _launchUrl(context, head.linkedinUrl),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: widget.heads.length,
      ),
    );
  }

  Widget _buildDevelopersList(
    double cardWidth,
    Color cardBgColor,
    Color borderColor,
    Color teamTitleColor,
    Color nameColor,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final member = widget.developers[index];
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
                  // Team Title
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

                  // Avatar with Glow Aura
                  _buildAvatar(member.imageUrl, isDark),

                  const SizedBox(height: 18),

                  // Name
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

                  // Pill 1: Role
                  _buildRolePill(member.role.toUpperCase(), isDark),

                  const SizedBox(height: 10),

                  // Pill 2: Explore
                  _buildExplorePill(
                    label: 'EXPLORE',
                    icon: Icons.code_rounded,
                    isDark: isDark,
                    onTap: () {
                      if (member.linkedinUrl.isNotEmpty) {
                        _launchUrl(context, member.linkedinUrl);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
        childCount: widget.developers.length,
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, bool isDark) {
    return Container(
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
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
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
                    imageUrl,
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
    );
  }

  Widget _buildRolePill(String roleText, bool isDark) {
    return Container(
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
          roleText,
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
    );
  }

  Widget _buildExplorePill({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              icon,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
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
    );
  }
}
