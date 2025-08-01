import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/view/landing_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  // one controller per slide:
  late final List<AnimationController> _animCtrls;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Techniche App",
      "subtitle": "Your Gateway to the Ultimate Techno-Management Fest",
      "lottie": "assets/welcome.json",
    },
    {
      "title": "Campus Ambassador Portal",
      "subtitle": "Submit tasks & earn your way to the top of leaderboard",
      "lottie": "assets/portal.json",
    },
    {
      "title": "Events Page",
      "subtitle": "Register for events, workshops and competitions",
      "lottie": "assets/events.json",
    },
    {
      "title": "Guwahati Half Marathon",
      "subtitle": "Run for a Better Tomorrow",
      "lottie": "assets/ghm.json",
    },
    {
      "title": "Technothlon PYQs",
      "subtitle": "Practice past question papers & hone your skills",
      "lottie": "assets/pyq.json",
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
          if (status == AnimationStatus.completed) {
            // do nothing (one-shot)
          }
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    String? token = prefs.getString("token");
    if (token != null && token.isNotEmpty) {
      await AuthController().fetchUserData(context);
      Navigator.pushReplacementNamed(context, BottomNavBar.routeName);
    } else {
      Navigator.pushReplacementNamed(context, LandingScreen.routeName);
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
      body: Stack(children: [
        const AnimatedGradientBackground(),

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
                // Lottie with its dedicated controller:
                Lottie.asset(
                  p['lottie']!,
                  controller: ctrl,
                  height: 250,
                  repeat: false,
                  onLoaded: (comp) {
                    ctrl.duration = comp.duration;
                    if (i == _current) _playCurrent();
                  },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
    );
  }
}
