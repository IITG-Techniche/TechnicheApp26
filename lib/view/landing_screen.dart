import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/utils/ca_bottom_nav_bar.dart';
import 'package:amazon_clone/view/map_screen.dart';
import 'package:amazon_clone/view/utilities_screen.dart';
import 'package:amazon_clone/view/legacy_screen.dart';
import 'package:amazon_clone/controller/authController.dart';
// Ensure you are importing the correct, new navigation bar
import 'package:amazon_clone/utils/bottom_nav_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amazon_clone/services/notification_service.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = '/landing-screen';
  const LandingScreen({Key? key}) : super(key: key);
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

/// Retro transition: scale + slight slide + fade + glow + scanlines
class RetroTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const RetroTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  double _clamp(double v, {double min = 0.0, double max = 1.0}) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Smoothed value
        final double t = Curves.easeInOut.transform(animation.value);
        final double scale = 0.94 + 0.12 * t; // subtle pop-in
        final double opacity = _clamp(t);
        // slight vertical slide (from below)
        final Offset offset = Offset(0, (1 - t) * 18);

        // glow peaks around the midpoint of transition
        final double glowPeak =
            (1.0 - ((t - 0.5).abs() * 2.0)).clamp(0.0, 1.0); // 0..1
        final double glowOpacity = 0.06 * glowPeak;

        // scanline intensity (subtle)
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
                  // The main child (the new screen)
                  child,
                  // Glow overlay (subtle cyan tint)
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
                          // Using blend via color with low opacity is sufficient
                        ),
                      ),
                    ),
                  ),
                  // Scanline overlay for retro effect
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
      },
      child: child,
    );
  }
}

/// Draws thin horizontal scanlines across the screen (very subtle)
class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.6
      ..isAntiAlias = false;

    // spacing between lines (controls density)
    const double spacing = 6.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    // If your notification service needs context or is async, running after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep your log for debugging
      if (kDebugMode) {
        // ignore: avoid_print
        print("LandingScreen: Triggering notification setup.");
      }
      // Expected method in your NotificationService — change if different
      NotificationService().initializeAndHandleNotifications();
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleAuthNavigation(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      bool isAuth = await AuthController().isUserAuthenticated();
      if (context.mounted) Navigator.of(context).pop();
      if (isAuth) {
        bool valid = await AuthController().validateTokenAndFetchUser(context);
        if (valid && context.mounted) {
          Navigator.pushNamed(context, CaBottomNavBar.routeName);
        } else if (context.mounted) {
          Navigator.pushNamed(context, AuthScreen.routeName);
        }
      } else if (context.mounted) {
        Navigator.pushNamed(context, AuthScreen.routeName);
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error accessing CA portal.')),
        );
        Navigator.pushNamed(context, AuthScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      // 0: Map
      const MapScreen(),
      // 1: Home
      _buildHomeContent(context),
      // 2: Legacy
      LegacyPage(),
      // 3: Utilities
      const UtilitiesScreen(),
    ];

    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: kDebugMode,
        debugDisplayAlways: kDebugMode,
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            // place previous children behind the incoming one for depth
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
            key: ValueKey<int>(_selectedIndex),
            child: screens.elementAt(_selectedIndex),
          ),
        ),
        bottomNavigationBar: GlowingBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            GlowingBottomNavBarItem(
              icon: Icons.map_sharp,
              label: 'Map',
            ),
            GlowingBottomNavBarItem(
              icon: Icons.home_filled,
              label: 'Home',
            ),
            GlowingBottomNavBarItem(
              icon: Icons.history_edu,
              label: 'Legacy',
            ),
            GlowingBottomNavBarItem(
              icon: Icons.workspace_premium_sharp,
              label: 'Utilities',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: SizedBox(
          width: screenWidth * 0.4,
          child: Image.asset(
            'assets/logo_withoutBG.png',
            fit: BoxFit.contain,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                children: [
                  Flexible(
                    flex: 4,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double borderSize = constraints.maxWidth;
                          final double imageMaxSize =
                              borderSize * 0.90; // 90% of border size
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Lottie border, always square
                              SizedBox(
                                width: borderSize,
                                height: borderSize,
                                child: Lottie.asset(
                                  'assets/scifibg.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                              // Carousel, keeps image aspect
                              SizedBox(
                                width: imageMaxSize,
                                height: imageMaxSize,
                                child: const _ImageCarousel(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    flex: 6,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.95,
                      children: [
                        _gridItem(
                          context: context,
                          title: 'CA Portal',
                          description: 'Manage tasks and track your progress',
                          imagePath: 'assets/ca_icon.png',
                          color: const Color(0xFF23242B),
                          onTap: () => _handleAuthNavigation(context),
                        ),
                        _gridItem(
                          context: context,
                          title: 'Technothlon',
                          description:
                              'See unique question papers of Technothlon!',
                          imagePath: 'assets/techno_logo.jpg',
                          color: const Color(0xFF23242B),
                          onTap: () => Navigator.pushNamed(
                              context, '/technothlon-screen'),
                        ),
                        _gridItem(
                          context: context,
                          title: 'Events',
                          description:
                              'Stay updated with the latest fest information',
                          imagePath: 'assets/techniche_events.png',
                          color: const Color(0xFF23242B),
                          onTap: () =>
                              Navigator.pushNamed(context, '/techniche-screen'),
                        ),
                        _gridItem(
                          context: context,
                          title: 'GHM',
                          description: 'Track your steps and participate',
                          imagePath: 'assets/ghm_logo.jpg',
                          color: const Color(0xFF23242B),
                          onTap: () =>
                              Navigator.pushNamed(context, '/ghm-selection'),
                        ),
                      ],
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

  Widget _gridItem({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.10),
              blurRadius: 24,
            ),
          ],
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF35363C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.arrow_forward,
                size: 18,
                color: Colors.blueAccent.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AnimatedGradientBackground Widget (No changes)
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);
  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<List<Color>> gradients = [
    [const Color(0xFF181A20), const Color(0xFF23242B), const Color(0xFF35363C)],
    [const Color(0xFF23242B), const Color(0xFF35363C), const Color(0xFF181A20)],
    [const Color(0xFF35363C), const Color(0xFF23242B), const Color(0xFF181A20)],
    [const Color(0xFF181A20), const Color(0xFF35363C), const Color(0xFF23242B)],
  ];
  int _currentGradient = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _currentGradient = (_currentGradient + 1) % gradients.length;
              _controller.forward(from: 0);
            }
          });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextGradient = gradients[(_currentGradient + 1) % gradients.length];
    final currentGradient = gradients[_currentGradient];
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(currentGradient.length, (i) {
                return Color.lerp(
                    currentGradient[i], nextGradient[i], _animation.value)!;
              }),
            ),
          ),
        );
      },
    );
  }
}

// ImageCarousel Widget (No changes)
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel();
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final List<String> imageUrls = [
    'assets/robo.png',
    'assets/aqua.png',
    'assets/micro.png',
    'assets/tracktitans.png',
    'assets/escalade.png',
  ];
  final List<String> links = [
    'https://unstop.com/competitions/robowars-iit-guwahati-1499332',
    'https://unstop.com/competitions/aquawars-30-iit-guwahati-1479317',
    'https://unstop.com/competitions/micromouse-2025-iit-guwahati-1509198',
    'https://unstop.com/competitions/track-titans-iit-guwahati-1509142',
    'https://unstop.com/competitions/escalade-140-iit-guwahati-1477498',
  ];
  int _current = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _cycleImages();
  }

  void _cycleImages() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    int next = (_current + 1) % imageUrls.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    if (mounted) _cycleImages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: imageUrls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () async {
              try {
                final uri = Uri.parse(links[i]);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $uri';
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to launch URL: $e')),
                  );
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  imageUrls[i],
                  fit: BoxFit.cover, // crop to square
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            imageUrls.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == i ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
