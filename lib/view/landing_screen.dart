import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = '/landing-screen';

  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: kDebugMode,
        debugDisplayAlways: kDebugMode,
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
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
          // ensure content sits below status bar and app bar
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
                      child: _ImageCarousel(),
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
                          title: 'CA Portal',
                          description: 'Manage tasks and track your progress',
                          imagePath: 'assets/ca_icon.png',
                          color: const Color(0xFF23242B),
                          onTap: () => _handleAuthNavigation(context),
                        ),
                        _gridItem(
                          title: 'Technothlon',
                          description:
                              'See unique question papers of Technothlon!',
                          imagePath: 'assets/techno_logo.jpg',
                          color: const Color(0xFF23242B),
                          onTap: () => Navigator.pushNamed(
                              context, '/technothlon-screen'),
                        ),
                        _gridItem(
                          title: 'Events',
                          description:
                              'Stay updated with the latest fest information',
                          imagePath: 'assets/techniche_events.png',
                          color: const Color(0xFF23242B),
                          onTap: () =>
                              Navigator.pushNamed(context, '/techniche-screen'),
                        ),
                        _gridItem(
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
          Navigator.pushNamed(context, BottomNavBar.routeName);
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

  Widget _gridItem({
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
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
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

// AnimatedGradientBackground Widget
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
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

// ImageCarousel Widget
class _ImageCarousel extends StatefulWidget {
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final List<String> imageUrls = [
    'assets/robo.jpg',
    'assets/aqua.png',
    'assets/micro.jpg',
    'assets/track.jpg',
    'assets/escalade.jpg',
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
    setState(() => _current = next);
    _cycleImages();
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
                await launchUrl(Uri.parse(links[i]));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to launch URL: \$e')),
                  );
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF23242B),
                child: Image.asset(
                  imageUrls[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white.withOpacity(0.92),
                  colorBlendMode: BlendMode.modulate,
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
