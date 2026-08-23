import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    final backgroundColor = isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA);
    final cardBgColor = isDark ? const Color(0xFF0A0F24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3B82F6).withOpacity(0.55) : const Color(0xFF3B82F6);
    final teamTitleColor = isDark ? Colors.white : const Color(0xFF1D4ED8);
    final nameColor = isDark ? Colors.white : const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with clean back button and header graphic
            _buildHeaderSection(context, isDark, screenWidth),

            const SizedBox(height: 12),

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

            const SizedBox(height: 20),

            // Horizontal scroll PageView of Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _selectedTab == 0 ? widget.heads.length : widget.developers.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (_selectedTab == 0) {
                    final head = widget.heads[index];
                    return _buildTeamCard(
                      teamName: head.teamName,
                      name: head.name,
                      imageUrl: head.imageUrl,
                      role: head.designation,
                      linkedinUrl: head.linkedinUrl,
                      cardBgColor: cardBgColor,
                      borderColor: borderColor,
                      teamTitleColor: teamTitleColor,
                      nameColor: nameColor,
                      isDark: isDark,
                    );
                  } else {
                    final dev = widget.developers[index];
                    return _buildTeamCard(
                      teamName: dev.teamName,
                      name: dev.name,
                      imageUrl: dev.imageUrl,
                      role: dev.role,
                      linkedinUrl: dev.linkedinUrl,
                      cardBgColor: cardBgColor,
                      borderColor: borderColor,
                      teamTitleColor: teamTitleColor,
                      nameColor: nameColor,
                      isDark: isDark,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDark, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // MEET THE TEAM Artwork
          SizedBox(
            width: (screenWidth * 0.65).clamp(200.0, 260.0),
            child: isDark
                ? Image.asset(
                    'assets/hero/meetheads/meettheteamindark.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => SvgPicture.asset(
                      'assets/hero/meetheads/mainhead.svg',
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/hero/meetheads/meettheteaminbright.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => SvgPicture.asset(
                      'assets/hero/meetheads/mainhead.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        });
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

  Widget _buildTeamCard({
    required String teamName,
    required String name,
    required String imageUrl,
    required String role,
    required String linkedinUrl,
    required Color cardBgColor,
    required Color borderColor,
    required Color teamTitleColor,
    required Color nameColor,
    required bool isDark,
  }) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF3B82F6).withOpacity(0.12)
                  : const Color(0xFF3B82F6).withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Team Title
              Text(
                teamName.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontUnivers,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: teamTitleColor,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // Avatar with Glow Aura
              _buildAvatar(imageUrl, name, isDark),

              const SizedBox(height: 12),

              // Name
              Text(
                name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontUnivers,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: nameColor,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Pill 1: Designation/Role
              _buildRolePill(role.toUpperCase(), isDark),

              const SizedBox(height: 10),

              // Pill 2: Explore / LinkedIn
              _buildExplorePill(
                label: 'EXPLORE',
                icon: Icons.link_rounded,
                isDark: isDark,
                onTap: () => _launchUrl(context, linkedinUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String name, bool isDark) {
    return Container(
      width: 120,
      height: 120,
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
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE),
            border: Border.all(
              color: const Color(0xFF60A5FA).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'D',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUnivers,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  )
                : (imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackInitial(name, isDark),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackInitial(name, isDark),
                      )),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackInitial(String name, bool isDark) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'D',
        style: TextStyle(
          fontFamily: AppTheme.fontUnivers,
          fontSize: 38,
          fontWeight: FontWeight.w900,
          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
        ),
      ),
    );
  }

  Widget _buildRolePill(String roleText, bool isDark) {
    return Container(
      width: double.infinity,
      height: 32,
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
        height: 32,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? Colors.white : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
