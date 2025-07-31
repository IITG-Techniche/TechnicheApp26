import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/view/landing_screen.dart';
import 'package:amazon_clone/view/onboarding_screen.dart';
import 'splash_screen.dart';

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({Key? key}) : super(key: key);

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _showSplashAndNavigate();
  }

  Future<void> _showSplashAndNavigate() async {
    // 4-second splash
    await Future.delayed(const Duration(seconds: 4));

    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      // First-time user → onboarding
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
      return;
    }

    // Otherwise proceed with auth/token logic
    try {
      String? token = prefs.getString("token");
      if (token != null && token.isNotEmpty) {
        if (mounted) {
          await AuthController().fetchUserData(context);
          Navigator.pushReplacementNamed(context, BottomNavBar.routeName);
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, LandingScreen.routeName);
        }
      }
    } catch (e) {
      // On error -> landing
      if (mounted) {
        Navigator.pushReplacementNamed(context, LandingScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
