import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/widgets/app_drawer.dart';
import 'package:techniche26/view/techno/papers_display.dart';

import 'package:techniche26/view/marathon/marathon_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techniche26/widgets/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/core/utilities_screen.dart';
import 'package:techniche26/view/core/legacy_screen.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/widgets/bottom_nav_bar.dart';
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

class _LandingScreenState extends ConsumerState<LandingScreen> {
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
    // Index 3 is Campus Ambassador — navigate directly instead of switching tab
    if (index == 3) {
      _handleAuthNavigation(context);
      return;
    }
    if (ref.read(bottomNavSelectedIndexProvider) == index) return;
    ref.read(bottomNavSelectedIndexProvider.notifier).state = index;
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
    final List<Widget> screens = <Widget>[
      const EventsScreen(isTab: true),
      LegacyPage(),
      _buildHomeContent(context),
      const SizedBox.shrink(), // CA — handled via _handleAuthNavigation, never rendered
      const UtilitiesScreen(),
    ];

    final selectedIndex = ref.watch(bottomNavSelectedIndexProvider);
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: Colors.white,
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
              GlowingBottomNavBarItem(icon: Icons.history_edu, label: 'Legacy'),
              GlowingBottomNavBarItem(icon: Icons.home_filled, label: 'Home'),
              GlowingBottomNavBarItem(
                  icon: Icons.school_rounded, label: 'CA'),
              GlowingBottomNavBarItem(
                  icon: Icons.workspace_premium_sharp, label: 'Utilities'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppTheme.backgroundGray,
        ),
        SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF002B5B),
                  image: DecorationImage(
                    image: AssetImage('assets/ghm/frame3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFAFAFAF),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (BuildContext innerContext) {
                              return GestureDetector(
                                onTap: () {
                                  Scaffold.of(innerContext).openDrawer();
                                },
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                    'assets/ghm/menu.png',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: 118.06,
                            height: 20.01,
                            child: Image.asset(
                              'assets/ghm/logo3.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        '  Explore',
                        style: TextStyle(
                            color: Color(0XFF232930),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            fontFamily: AppTheme.fontUnivers),
                      ),
                      SizedBox(height: 20),
                      _gridItem(
                        context: context,
                        title: 'Campus Ambassador',
                        description:
                            'Represent Techniche at your campus & win exciting rewards',
                        imagePath: 'assets/logo_withoutBG.png',
                        onTap: () => _handleAuthNavigation(context),
                        logo_image: 'assets/ghm/technichelogo.png',
                        logo_color: const Color(0xFF002B5B),
                        logo_name: 'Explore',
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _gridItem(
                        context: context,
                        title: 'Practice Run',
                        description:
                            'Track your runs and join the leaderboard!',
                        imagePath: 'assets/ghm/practicerun2.png',
                        onTap: () {
                          if (ModalRoute.of(context)?.isCurrent == true) {
                            Navigator.pushNamed(context, MarathonMainScreen.routeName);
                          }
                        },
                        logo_image: 'assets/ghm/runline.png',
                        logo_color: const Color(0xFF175BCC),
                        logo_name: 'Track',
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _gridItem(
                        context: context,
                        title: 'Upcoming Events',
                        description:
                            'Stay updated with the latest fest information.',
                        imagePath: 'assets/ghm/techniche2.png',
                        onTap: () => ref
                            .read(bottomNavSelectedIndexProvider.notifier)
                            .state = 0,
                        logo_image: 'assets/ghm/technichelogo.png',
                        logo_color: const Color(0xFF175BCC),
                        logo_name: 'Check Out',
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _gridItem(
                        context: context,
                        title: 'Techno PYQs',
                        description: 'Practice past year papers.',
                        imagePath: 'assets/ghm/techno2.png',
                        onTap: () => Navigator.pushNamed(
                            context, TechnothlonPyqScreen.routeName),
                        logo_image: 'assets/ghm/technichelogo.png',
                        logo_color: const Color(0xFF23242B),
                        logo_name: 'Check Out',
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      _gridItem(
                        context: context,
                        title: 'Comedy Night',
                        description: 'Register to secure your virtual entry pass for Techniche Comedy Night!',
                        imagePath: 'assets/logo_withoutBG.png',
                        onTap: () => Navigator.pushNamed(
                            context, '/comedy-night'),
                        logo_image: 'assets/ghm/technichelogo.png',
                        logo_color: const Color(0xFF8E24AA),
                        logo_name: 'Book Slot',
                      ),
                      SizedBox(height: 20),
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

  Widget _gridItem({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
    required String logo_image,
    required Color logo_color,
    required String logo_name, 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: AppTheme.backgroundGray,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE8E8E8),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Image Banner (height 152) ──
            Container(
              width: double.infinity,
              height: 152,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFF6F0EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Bottom Content ──
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: AppTheme.fontUnivers,
                          fontWeight: FontWeight.w700,
                          height: 1.07,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF6D7985),
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Button ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: ShapeDecoration(
                    color: logo_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (logo_image.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            logo_image,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        logo_name,
                        style: const TextStyle(
                          color: Color(0xFFEDEFF0),
                          fontSize: 16,
                          fontFamily: AppTheme.fontGeneralSans,
                          fontWeight: FontWeight.w600,
                          height: 1.20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
