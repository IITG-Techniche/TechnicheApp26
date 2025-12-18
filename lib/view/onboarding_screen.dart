import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/constant/sharedPerfence.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/landing_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  double _opacity = 1.0;
  bool _isTransitioning = false;
  final PageController _pageCtrl = PageController();
  int _current = 0;

  // one controller per slide:
  late final List<AnimationController> _animCtrls;

  final List<Map<String, String>> _pages = [
    {
      "title": "Let the Chaos Begin",
      "subtitle": "IIT Guwahati’s Premier Techno-Management Fest",
      "lottie": "assets/onboarding/welcome.json",
    },
    {
      "title": "Campus Ambassador Portal",
      "subtitle": "Submit tasks & earn your way to the top of leaderboard",
      "lottie": "assets/onboarding/portal.json",
    },
    {
      "title": "Events Page",
      "subtitle": "Register for events, workshops and competitions",
      "lottie": "assets/onboarding/events.json",
    },
    {
      "title": "Guwahati Half Marathon",
      "subtitle": "Run for a Better Tomorrow",
      "lottie": "assets/onboarding/ghm.json",
    },
    {
      "title": "Technothlon PYQs",
      "subtitle": "Practice past question papers & hone your skills",
      "lottie": "assets/onboarding/pyq.json",
    },
  ];

  @override
  void initState() {
    super.initState();

    // create one AnimationController per page:
    _animCtrls = List.generate(_pages.length, (_) {
      return AnimationController(vsync: this)
        ..duration = const Duration(milliseconds: 0) // will get set onLoaded
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {}
        });
    });

    // whenever page changes, restart that page's animation:
    _pageCtrl.addListener(() {
      final idx = _pageCtrl.page?.round() ?? 0;
      if (idx != _current) {
        setState(() => _current = idx);
        _playCurrent();
      }
    });
  }

  void _playCurrent() {
    final ctrl = _animCtrls[_current];
    ctrl
      ..stop()
      ..reset()
      ..duration = ctrl.duration // already set by onLoaded
      ..forward(from: 0)
      ..value = 0
      ..stop()
      ..forward();
  }

  Future<void> _finishOnboarding() async {
    if (_isTransitioning) return;
    setState(() {
      _opacity = 0.0;
      _isTransitioning = true;
    });
    await Future.delayed(const Duration(milliseconds: 350));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPreferenceConstants.seenOnboarding, true);

    String? token = prefs.getString('ca_token');
    if (token != null && token.isNotEmpty) {
      if (mounted) {
        await ref.read(caAuthControllerProvider).fetchUserData(context);
        if (mounted) {
          Navigator.pushReplacementNamed(context, CaBottomNavBar.routeName);
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, LandingScreen.routeName);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _animCtrls) c.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: Stack(children: [
          // Background Lottie animation (wrapped in RepaintBoundary for perf)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.75,
                child: RepaintBoundary(
                  child: Lottie.asset(
                    'assets/stroke.json',
                    fit: BoxFit.cover,
                    repeat: true,
                    options: LottieOptions(enableMergePaths: true),
                  ),
                ),
              ),
            ),
          ),

          // the PageView “carousel”
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _pages.length,
            itemBuilder: (ctx, i) {
              final p = _pages[i];
              final ctrl = _animCtrls[i];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie with its dedicated controller (RepaintBoundary for perf):
                  RepaintBoundary(
                    child: Lottie.asset(
                      p['lottie']!,
                      controller: ctrl,
                      height: 250,
                      repeat: false,
                      options: LottieOptions(enableMergePaths: true),
                      onLoaded: (comp) {
                        ctrl.duration = comp.duration;
                        if (i == _current) _playCurrent();
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    p['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p['subtitle']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              );
            },
          ),

          // Arrows near the Next/Get Started button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left Arrow
                if (_current > 0)
                  Positioned(
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left,
                          size: 40, color: Colors.white70),
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),

                // Center Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    backgroundColor: const Color(0xFF222831),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black54,
                  ),
                  onPressed: () {
                    if (_current == _pages.length - 1) {
                      _finishOnboarding();
                    } else {
                      _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _current == _pages.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                // Right Arrow
                if (_current < _pages.length - 1)
                  Positioned(
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right,
                          size: 40, color: Colors.white70),
                      onPressed: () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
