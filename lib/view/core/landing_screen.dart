import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/utils/app_drawer.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/events_screen.dart';
import 'package:techniche26/view/utilities_screen.dart';
import 'package:techniche26/view/legacy_screen.dart';
import 'package:techniche26/view/map_screen.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/utils/bottom_nav_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:techniche26/services/notification_service.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/providers/navigation_provider.dart';

class LandingScreen extends ConsumerStatefulWidget {
  static const String routeName = '/landing-screen';
  final int initialTab;
  final String? initialVenue;

  const LandingScreen({
    super.key,
    this.initialTab = 2,
    this.initialVenue,
  });

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class RetroTransition extends AnimatedWidget {
  final Widget child;

  const RetroTransition({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  double _clamp(double v, {double min = 0.0, double max = 1.0}) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final double t = Curves.easeInOut.transform(animation.value);
    final double scale = 0.94 + 0.12 * t;
    final double opacity = _clamp(t);
    final Offset offset = Offset(0, (1 - t) * 18);
    final double glowPeak = (1.0 - ((t - 0.5).abs() * 2.0)).clamp(0.0, 1.0);
    final double glowOpacity = 0.06 * glowPeak;
    final double scanlineOpacity = 0.06 * glowPeak;

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              child,
              IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: glowOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.withOpacity(0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.9],
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: scanlineOpacity,
                  child: const CustomPaint(
                    painter: ScanlinePainter(),
                    size: Size.infinite,
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

class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.6
      ..isAntiAlias = false;
    const double spacing = 6.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandingScreenState extends ConsumerState<LandingScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(bottomNavSelectedIndexProvider.notifier).state =
            widget.initialTab;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print("LandingScreen: Triggering notification setup.");
      }
      NotificationService().initializeAndHandleNotifications();
    });
  }

  void _onItemTapped(int index) {
    if (ref.read(bottomNavSelectedIndexProvider) == index) return;
    ref.read(bottomNavSelectedIndexProvider.notifier).state = index;
  }

  Widget _buildHeroLabel({
    required String text,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _handleAuthNavigation(BuildContext context) async {
    // Perform a quick local check for stored session
    bool isAuth = await ref.read(caAuthControllerProvider).isCaUserAuthenticated();
    
    if (context.mounted) {
      if (isAuth) {
        // Navigate immediately - background sync will happen inside the CA Portal
        Navigator.pushNamed(context, CaBottomNavBar.routeName);
      } else {
        // Go to auth screen if no local session exists
        Navigator.pushNamed(context, CaAuthScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> screens = <Widget>[
      const EventsScreen(isTab: true),
      const LegacyPage(),
      _buildHomeContent(context, isDark),
      MapScreen(initialVenue: widget.initialVenue),
      const UtilitiesScreen(),
    ];

    final selectedIndex = ref.watch(bottomNavSelectedIndexProvider);
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF070B19) : Colors.white,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[

                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RetroTransition(animation: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(selectedIndex),
            child: screens.elementAt(selectedIndex),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: GlowingBottomNavBar(
            currentIndex: selectedIndex,
            onTap: _onItemTapped,
            items: [
              GlowingBottomNavBarItem(
                  icon: Icons.event_note_sharp, label: 'Events'),
              GlowingBottomNavBarItem(icon: Icons.schedule, label: 'Schedule'),
              GlowingBottomNavBarItem(icon: Icons.home_filled, label: 'Home'),
              GlowingBottomNavBarItem(
                  icon: Icons.map_rounded, label: 'Map'),
              GlowingBottomNavBarItem(
                  icon: Icons.workspace_premium_sharp, label: 'Utilities'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textPrimary = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);
    final pillBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header / Top Banner ──
          Stack(
            children: [
              ClipPath(
                clipper: CloudBottomClipper(),
                child: Container(
                  width: double.infinity,
                  height: 430,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF090E25) : const Color(0xFFE4F0FF),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/home_header_bg.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF0A122C).withOpacity(0.4),
                                      const Color(0xFF070B19).withOpacity(0.8),
                                    ]
                                  : [
                                      const Color(0xFFE4F0FF).withOpacity(0.2),
                                      const Color(0xFFFFFFFF).withOpacity(0.7),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          // Profile Circle Initial
                          Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                width: 56,
                                height: 56,
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
                                child: const Text(
                                  'AB',
                                  style: TextStyle(
                                    color: Color(0xFF202127),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Icons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : const Color(0xFF10152B), size: 34),
                                onPressed: () => Navigator.pushNamed(context, '/merch'),
                              ),
                              IconButton(
                                icon: Icon(Icons.help_outline_rounded, color: isDark ? Colors.white : const Color(0xFF10152B), size: 34),
                                onPressed: () {
                                  ref.read(bottomNavSelectedIndexProvider.notifier).state = 4;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: .64,
                          child: Image.asset(
                            'assets/logo_withoutBG.png',
                            width: screenWidth * .72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Transform.rotate(
                        angle: -.05,
                        child: _buildHeroLabel(
                          text: "IIT Guwahati’s",
                          background: isDark ? const Color(0xFFD4E6FC) : const Color(0xFF3F5EBC),
                          foreground: isDark ? const Color(0xFF08165D) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Transform.rotate(
                        angle: .025,
                        child: _buildHeroLabel(
                          text: 'Annual Techno-Management Festival',
                          background: isDark ? const Color(0xFF2B53B4) : const Color(0xFFF2F6FF),
                          foreground: isDark ? Colors.white : const Color(0xFF08165D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Transform.rotate(
                        angle: .005,
                        child: _buildHeroLabel(
                          text: '28th to 30th August 2026',
                          background: isDark ? const Color(0xFFD4E6FC) : const Color(0xFF294C9A),
                          foreground: isDark ? const Color(0xFF08165D) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Upcoming Events ──
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 2.0, bottom: 15.0),
            child: Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textSecondary,
                fontFamily: AppTheme.fontUnivers,
              ),
            ),
          ),
          SizedBox(
            height: 380,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildUpcomingEventCard(
                  context,
                  title: 'Aquawars',
                  image: 'assets/robo.png',
                  date: '12 August | 12 pm',
                  venue: 'Bhupen Hazarika Auditorium',
                  isDark: isDark,
                ),
                _buildUpcomingEventCard(
                  context,
                  title: 'Robowars',
                  image: 'assets/robo.png',
                  date: '13 August | 10 am',
                  venue: 'Cricket Ground',
                  isDark: isDark,
                ),
                _buildUpcomingEventCard(
                  context,
                  title: 'Escalade',
                  image: 'assets/robo.png',
                  date: '14 August | 02 pm',
                  venue: 'Old SAC',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // ── Campus Ambassador Program Card ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E294A), const Color(0xFF0F162A)]
                      : [const Color(0xFFD4E6FC), const Color(0xFFEEF5FD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Ambassador\nProgram',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.2,
                      fontFamily: 'General Sans',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Represent Techniche at your campus & win exciting rewards',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      fontFamily: 'General Sans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // White container wrapping avatars & joined count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOverlapAvatar('assets/arya-app.jpg'),
                            _buildOverlapAvatar('assets/ayush-app.jpg'),
                            _buildOverlapAvatar('assets/dhruv-app.jpg'),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4F0FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '+37 Joined',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF175BCC),
                                  fontFamily: 'General Sans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Join Now button
                      ElevatedButton(
                        onPressed: () => _handleAuthNavigation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3D96),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Join Now',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'General Sans'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // ── Techniche Merchandise Card ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155).withOpacity(0.4) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Text Content
                  Positioned(
                    left: 24,
                    top: 28,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Techniche',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                                fontFamily: 'General Sans',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Merchandise',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: textPrimary,
                                fontFamily: AppTheme.fontUnivers,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/merch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B3D96),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Explore Collection',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'General Sans'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Background/watermark text
                  Positioned(
                    right: 40,
                    top: 55,
                    child: Opacity(
                      opacity: isDark ? 0.25 : 0.18,
                      child: const Text(
                        'GLITCHED\nGOOD BOY',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2B53B4),
                          height: 1.1,
                          fontFamily: 'Univers',
                        ),
                      ),
                    ),
                  ),
                  // Floating Animated T-shirt
                  const Positioned(
                    right: 10,
                    top: 10,
                    bottom: 10,
                    child: _FloatingMerchShirt(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // ── Featured Events ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                    fontFamily: AppTheme.fontUnivers,
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeaturedEventTile(
                  title: 'Robowars',
                  desc: 'Witness the ultimate clash of steel and circuits! Sparks will fly!',
                  category: 'Robotics',
                  isDark: isDark,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  pillBg: pillBg,
                ),
                _buildFeaturedEventTile(
                  title: 'Aquawars',
                  desc: 'Autonomous aquatic robots navigating a series of complex underwater obstacles.',
                  category: 'Robotics',
                  isDark: isDark,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  pillBg: pillBg,
                ),
                _buildFeaturedEventTile(
                  title: 'Escalade',
                  desc: 'A premier startup pitch competition showing groundbreaking business ideas.',
                  category: 'Robotics',
                  isDark: isDark,
                  cardBg: cardBg,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  pillBg: pillBg,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // ── Our Sponsors ──
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 12.0),
            child: Text(
              'Our Sponsors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textSecondary,
                fontFamily: AppTheme.fontUnivers,
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const BouncingScrollPhysics(),
              children: List.generate(5, (index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E294A), const Color(0xFF0F162A)]
                          : [const Color(0xFFDCE8F8), const Color(0xFFEAF2FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(
    BuildContext context, {
    required String title,
    required String image,
    required String date,
    required String venue,
    required bool isDark,
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return Container(
      width: 270,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay gradient to make ROBOWARS text legible
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // ROBOWARS header text at the top
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: const Text(
              'ROBOWARS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontFamily: 'Univers',
              ),
            ),
          ),
          // Floating Info card at the bottom
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B53B4),
                            fontFamily: 'General Sans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            fontFamily: 'General Sans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                venue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                  fontFamily: 'General Sans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bell button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4F0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: Color(0xFF0D256B),
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

  Widget _buildOverlapAvatar(String asset) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      widthFactor: 0.6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: AssetImage(asset),
        ),
      ),
    );
  }

  Widget _buildFeaturedEventTile({
    required String title,
    required String desc,
    required String category,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color pillBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155).withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Event dummy placeholder image (grey square)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF175BCC),
                      fontFamily: 'General Sans',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    fontFamily: 'General Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontFamily: 'General Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Cloud Bottom Clipper ──
class CloudBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final edge = size.height - 92;
    path.lineTo(0, edge);
    path.cubicTo(
      size.width * .12,
      edge + 28,
      size.width * .20,
      edge + 42,
      size.width * .18,
      size.height - 42,
    );
    path.cubicTo(
      size.width * .33,
      size.height - 100,
      size.width * .50,
      size.height - 8,
      size.width * .58,
      size.height - 42,
    );
    path.cubicTo(
      size.width * .67,
      size.height - 98,
      size.width * .84,
      size.height - 100,
      size.width * .82,
      size.height - 42,
    );
    path.cubicTo(
      size.width * .80,
      edge + 42,
      size.width * .89,
      edge + 28,
      size.width,
      edge,
    );


    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _FloatingMerchShirt extends StatefulWidget {
  const _FloatingMerchShirt({Key? key}) : super(key: key);

  @override
  State<_FloatingMerchShirt> createState() => _FloatingMerchShirtState();
}

class _FloatingMerchShirtState extends State<_FloatingMerchShirt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/shirt.png'),
                fit: BoxFit.contain,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent,
                  blurRadius: 35,
                  spreadRadius: -15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
